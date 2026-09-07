import { beforeEach, describe, expect, it, vi } from 'vitest';

import { LocalAuthPlugin } from './index';
import { verifyPassword } from './src/auth-utils';

vi.mock('./src/auth-utils', () => ({
    verifyPassword: vi.fn(),
}));

describe('LocalAuthPlugin', () => {
    let mockDb: any;

    beforeEach(() => {
        vi.clearAllMocks();

        mockDb = {
            query: {
                users: {
                    findFirst: vi.fn(),
                },
            },
        };
    });

    describe('name', () => {
        it('local を返す', () => {
            const plugin = new LocalAuthPlugin(mockDb);

            expect(plugin.name).toBe('local');
        });
    });

    describe('authenticate', () => {
        it('認証成功時に AuthUser を返す', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            const dbUser = {
                id: 1,
                email: 'test@example.com',
                name: 'テストユーザー',
                role: 'admin',
                passwordHash: 'hashed-password',
            };

            mockDb.query.users.findFirst.mockResolvedValue(
                dbUser,
            );

            vi.mocked(verifyPassword).mockResolvedValue(
                true,
            );

            const result = await plugin.authenticate({
                email: 'test@example.com',
                password: 'password',
            });

            expect(
                mockDb.query.users.findFirst,
            ).toHaveBeenCalledTimes(1);

            expect(
                verifyPassword,
            ).toHaveBeenCalledWith(
                'password',
                'hashed-password',
            );

            expect(result).toEqual({
                id: 1,
                email: 'test@example.com',
                name: 'テストユーザー',
                role: 'admin',
            });
        });

        it('email が未指定の場合は例外', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            await expect(
                plugin.authenticate({
                    password: 'password',
                }),
            ).rejects.toThrow(
                'メールアドレスとパスワードを入力してください。',
            );
        });

        it('password が未指定の場合は例外', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            await expect(
                plugin.authenticate({
                    email: 'test@example.com',
                }),
            ).rejects.toThrow(
                'メールアドレスとパスワードを入力してください。',
            );
        });

        it('email と password が未指定の場合は例外', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            await expect(
                plugin.authenticate({}),
            ).rejects.toThrow(
                'メールアドレスとパスワードを入力してください。',
            );
        });

        it('email が空文字の場合は例外', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            await expect(
                plugin.authenticate({
                    email: '',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'メールアドレスとパスワードを入力してください。',
            );
        });

        it('password が空文字の場合は例外', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            await expect(
                plugin.authenticate({
                    email: 'test@example.com',
                    password: '',
                }),
            ).rejects.toThrow(
                'メールアドレスとパスワードを入力してください。',
            );
        });

        it('ユーザーが存在しない場合は例外', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            mockDb.query.users.findFirst.mockResolvedValue(
                undefined,
            );

            await expect(
                plugin.authenticate({
                    email: 'test@example.com',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'Invalid local credentials',
            );

            expect(
                verifyPassword,
            ).not.toHaveBeenCalled();
        });

        it('パスワード不一致の場合は例外', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            mockDb.query.users.findFirst.mockResolvedValue({
                id: 1,
                email: 'test@example.com',
                name: 'テストユーザー',
                role: 'admin',
                passwordHash: 'hashed-password',
            });

            vi.mocked(verifyPassword).mockResolvedValue(
                false,
            );

            await expect(
                plugin.authenticate({
                    email: 'test@example.com',
                    password: 'wrong-password',
                }),
            ).rejects.toThrow(
                'Invalid local credentials',
            );

            expect(
                verifyPassword,
            ).toHaveBeenCalledTimes(1);
        });

        it('DB例外をそのまま伝播する', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            mockDb.query.users.findFirst.mockRejectedValue(
                new Error('DB Error'),
            );

            await expect(
                plugin.authenticate({
                    email: 'test@example.com',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'DB Error',
            );
        });

        it('verifyPassword 例外をそのまま伝播する', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            mockDb.query.users.findFirst.mockResolvedValue({
                id: 1,
                email: 'test@example.com',
                name: 'テストユーザー',
                role: 'admin',
                passwordHash: 'hashed-password',
            });

            vi.mocked(verifyPassword).mockRejectedValue(
                new Error('Hash Error'),
            );

            await expect(
                plugin.authenticate({
                    email: 'test@example.com',
                    password: 'password',
                }),
            ).rejects.toThrow(
                'Hash Error',
            );
        });

        it('role が undefined の場合でも認証成功する', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            mockDb.query.users.findFirst.mockResolvedValue({
                id: 1,
                email: 'test@example.com',
                name: 'テストユーザー',
                role: undefined,
                passwordHash: 'hashed-password',
            });

            vi.mocked(verifyPassword).mockResolvedValue(
                true,
            );

            const result = await plugin.authenticate({
                email: 'test@example.com',
                password: 'password',
            });

            expect(result).toEqual({
                id: 1,
                email: 'test@example.com',
                name: 'テストユーザー',
                role: undefined,
            });
        });

        it('email が undefined のユーザーでも AuthUser を生成できる', async () => {
            const plugin = new LocalAuthPlugin(mockDb);

            mockDb.query.users.findFirst.mockResolvedValue({
                id: 1,
                email: undefined,
                name: 'テストユーザー',
                role: 'user',
                passwordHash: 'hashed-password',
            });

            vi.mocked(verifyPassword).mockResolvedValue(
                true,
            );

            const result = await plugin.authenticate({
                email: 'test@example.com',
                password: 'password',
            });

            expect(result).toEqual({
                id: 1,
                email: undefined,
                name: 'テストユーザー',
                role: 'user',
            });
        });
    });
});
