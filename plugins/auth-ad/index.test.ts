import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ActiveDirectoryAuthPlugin } from './index';

const { bindMock, unbindMock } = vi.hoisted(() => ({
    bindMock: vi.fn(),
    unbindMock: vi.fn(),
}));

vi.mock('ldapts', () => {
    return {
        Client: class MockClient {
            bind = bindMock;
            unbind = unbindMock;

            constructor(_: { url: string }) { }
        },
    };
});


vi.mock('@shared/functions', () => ({
    env: {
        LDAP_URL: 'ldap://example.local',
        LDAP_DOMAIN: 'example.local',
    },
}));

describe('ActiveDirectoryAuthPlugin', () => {
    beforeEach(() => {
        vi.clearAllMocks();

        bindMock.mockResolvedValue(undefined);
        unbindMock.mockResolvedValue(undefined);
    });

    describe('name', () => {
        it('ad を返す', () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            expect(plugin.name).toBe('ad');
        });
    });

    describe('authenticate', () => {
        it('usernameで認証できる', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            const result = await plugin.authenticate({
                username: 'testuser',
                password: 'password',
            });

            expect(bindMock).toHaveBeenCalledWith(
                'testuser@example.local',
                'password',
            );

            expect(result).toEqual({
                id: 'testuser',
                email: 'testuser@example.local',
                name: 'testuser',
                role: 'user',
            });

            expect(unbindMock).toHaveBeenCalledTimes(1);
        });

        it('emailで認証できる', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            const result = await plugin.authenticate({
                email: 'testuser@example.local',
                password: 'password',
            });

            expect(bindMock).toHaveBeenCalledWith(
                'testuser@example.local',
                'password',
            );

            expect(result).toEqual({
                id: 'testuser',
                email: 'testuser@example.local',
                name: 'testuser',
                role: 'user',
            });
        });

        it('usernameが未指定の場合は例外', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            await expect(
                plugin.authenticate({
                    password: 'password',
                }),
            ).rejects.toThrow(
                'ユーザー名（またはメールアドレス）とパスワードを入力してください。'
            );
        });

        it('passwordが未指定の場合は例外', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            await expect(
                plugin.authenticate({
                    username: 'testuser',
                }),
            ).rejects.toThrow(
                'ユーザー名（またはメールアドレス）とパスワードを入力してください。'
            );
        });

        it('username・password両方未指定の場合は例外', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            await expect(
                plugin.authenticate({}),
            ).rejects.toThrow(
                'ユーザー名（またはメールアドレス）とパスワードを入力してください。'
            );
        });

        it('usernameが空文字の場合は例外', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            await expect(
                plugin.authenticate({
                    username: '',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'ユーザー名（またはメールアドレス）とパスワードを入力してください。'
            );
        });

        it('passwordが空文字の場合は例外', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            await expect(
                plugin.authenticate({
                    username: 'testuser',
                    password: '',
                }),
            ).rejects.toThrow(
                'ユーザー名（またはメールアドレス）とパスワードを入力してください。'
            );
        });

        it('LDAP_URL未設定の場合は例外', async () => {
            vi.resetModules();

            vi.doMock('@shared/functions', () => ({
                env: {
                    LDAP_URL: undefined,
                    LDAP_DOMAIN: 'example.local',
                },
            }));

            const { ActiveDirectoryAuthPlugin } = await import('./index');

            const plugin = new ActiveDirectoryAuthPlugin();

            await expect(
                plugin.authenticate({
                    username: 'testuser',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'LDAP_URL または LDAP_DOMAIN が設定されていません。'
            );
        });

        it('LDAP_DOMAIN未設定の場合は例外', async () => {
            vi.resetModules();

            vi.doMock('@shared/functions', () => ({
                env: {
                    LDAP_URL: 'ldap://example.local',
                    LDAP_DOMAIN: undefined,
                },
            }));

            const { ActiveDirectoryAuthPlugin } = await import('./index');

            const plugin = new ActiveDirectoryAuthPlugin();

            await expect(
                plugin.authenticate({
                    username: 'testuser',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'LDAP_URL または LDAP_DOMAIN が設定されていません。'
            );
        });

        it('bind失敗時は認証失敗エラーを返す', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            bindMock.mockRejectedValue(
                new Error('LDAP Error'),
            );

            await expect(
                plugin.authenticate({
                    username: 'testuser',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'Active Directory authentication failed',
            );

            expect(unbindMock).toHaveBeenCalledTimes(1);
        });

        it('loginIdにメールアドレスを指定した場合はUPNへ変換する', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            await plugin.authenticate({
                email: 'john@example.local',
                password: 'password',
            });

            expect(bindMock).toHaveBeenCalledWith(
                'john@example.local',
                'password',
            );
        });

        it('unbind失敗は無視する', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            unbindMock.mockRejectedValue(
                new Error('unbind failed'),
            );

            const result = await plugin.authenticate({
                username: 'testuser',
                password: 'password',
            });

            expect(result).toEqual({
                id: 'testuser',
                email: 'testuser@example.local',
                name: 'testuser',
                role: 'user',
            });
        });

        it('email指定時は@より前をname/idに使用する', async () => {
            const plugin = new ActiveDirectoryAuthPlugin();

            const result = await plugin.authenticate({
                email: 'john.smith@example.local',
                password: 'password',
            });

            expect(result).toEqual({
                id: 'john.smith',
                email: 'john.smith@example.local',
                name: 'john.smith',
                role: 'user',
            });
        });
    });
});
