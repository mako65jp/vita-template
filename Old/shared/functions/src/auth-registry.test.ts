// auth-registry.spec.ts

import { describe, expect, it } from 'vitest';

import { AuthPlugin, AuthPluginRegistry } from './auth-registry';

describe('AuthPluginRegistry', () => {
    describe('register', () => {
        it('認証プラグインを登録できる', () => {
            const registry = new AuthPluginRegistry();

            const plugin: AuthPlugin = {
                name: 'local',
                authenticate: async () => ({
                    id: '1',
                    name: 'test-user',
                }),
            };

            registry.register(plugin);

            expect(registry.get('local')).toBe(plugin);
        });

        it('同じ name のプラグインを再登録した場合は上書きされる', () => {
            const registry = new AuthPluginRegistry();

            const oldPlugin: AuthPlugin = {
                name: 'local',
                authenticate: async () => ({
                    id: '1',
                    name: 'old-user',
                }),
            };

            const newPlugin: AuthPlugin = {
                name: 'local',
                authenticate: async () => ({
                    id: '2',
                    name: 'new-user',
                }),
            };

            registry.register(oldPlugin);
            registry.register(newPlugin);

            expect(registry.get('local')).toBe(newPlugin);
        });
    });

    describe('get', () => {
        it('登録済みプラグインを取得できる', () => {
            const registry = new AuthPluginRegistry();

            const plugin: AuthPlugin = {
                name: 'ad',
                authenticate: async () => ({
                    id: '100',
                    name: 'Active Directory User',
                }),
            };

            registry.register(plugin);

            const result = registry.get('ad');

            expect(result).toBe(plugin);
        });

        it('未登録プラグイン取得時は例外を送出する', () => {
            const registry = new AuthPluginRegistry();

            expect(() => registry.get('unknown')).toThrowError(
                '認証プラグイン "unknown" が登録されていません。',
            );
        });

        it('空文字キーで登録・取得できる', () => {
            const registry = new AuthPluginRegistry();

            const plugin: AuthPlugin = {
                name: '',
                authenticate: async () => ({
                    id: '1',
                    name: 'empty-name-plugin',
                }),
            };

            registry.register(plugin);

            expect(registry.get('')).toBe(plugin);
        });

        it('特殊文字を含むキーを取得できる', () => {
            const registry = new AuthPluginRegistry();

            const plugin: AuthPlugin = {
                name: 'ldap-test_plugin@v1',
                authenticate: async () => ({
                    id: '1',
                    name: 'special-plugin',
                }),
            };

            registry.register(plugin);

            expect(registry.get('ldap-test_plugin@v1')).toBe(plugin);
        });

        it('キーは大文字小文字を区別する', () => {
            const registry = new AuthPluginRegistry();

            const plugin: AuthPlugin = {
                name: 'Local',
                authenticate: async () => ({
                    id: '1',
                    name: 'case-sensitive',
                }),
            };

            registry.register(plugin);

            expect(registry.get('Local')).toBe(plugin);

            expect(() => registry.get('local')).toThrowError(
                '認証プラグイン "local" が登録されていません。',
            );
        });
    });

    describe('authenticate integration', () => {
        it('取得したプラグインの authenticate を実行できる', async () => {
            const registry = new AuthPluginRegistry();

            const plugin: AuthPlugin = {
                name: 'local',
                authenticate: async (credentials) => ({
                    id: '1',
                    email: credentials.email,
                    name: 'test-user',
                    role: 'admin',
                }),
            };

            registry.register(plugin);

            const authPlugin = registry.get('local');

            const user = await authPlugin.authenticate({
                email: 'test@example.com',
                password: 'password',
            });

            expect(user).toEqual({
                id: '1',
                email: 'test@example.com',
                name: 'test-user',
                role: 'admin',
            });
        });
    });
});
