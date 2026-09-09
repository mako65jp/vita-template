import { beforeEach, describe, expect, it, vi } from 'vitest';

import { loadFeatureModules } from './hono-auto-loader';
import { Hono } from 'hono';
import type { AppEnv } from '../types';
import type { ServerPluginManifest } from '@shared/plugin';
import { glob } from 'glob';
import { getActivePlugins } from '../utils/auto-loader-helper';
import { authMiddleware } from '../middlewares/auth-middleware';
import { rbacMiddleware } from '../middlewares/rbac-middleware';

vi.mock('glob');
vi.mock('../utils/auto-loader-helper');
vi.mock('../middlewares/auth-middleware', () => ({
    authMiddleware: vi.fn(() => 'auth-middleware'),
}));

vi.mock('../middlewares/rbac-middleware', () => ({
    rbacMiddleware: vi.fn(() => 'rbac-middleware'),
}));

vi.mock('@shared/functions', () => ({
    env: {
        JWT_SECRET: 'test-secret',
    },
    isTest: false,
}));

vi.mock('@shared/server-utils', () => ({
    getProjectRootDir: vi.fn(() => '/project'),
    resolveFromProjectRoot: vi.fn((...paths: string[]) =>
        `/project/${paths.join('/')}`
    ),
}));

function createPlugin(
    overrides: Partial<ServerPluginManifest> = {}
): ServerPluginManifest {
    return {
        id: 'users',
        name: 'User Management',
        routes: new Hono<AppEnv>(),
        ...overrides,
    };
}

describe('loadFeatureModules', () => {
    let app: any;
    let db: any;

    beforeEach(() => {
        vi.clearAllMocks();

        app = {
            use: vi.fn(),
            route: vi.fn(),
        };

        db = {};
    });

    describe('plugin mount', () => {
        it('有効なプラグインをマウントできる', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(app.use).toHaveBeenCalledWith(
                '/api/users/*',
                expect.anything()
            );

            expect(app.route).toHaveBeenCalledWith(
                '/api/users',
                plugin.routes
            );
        });

        it('requiredRole がある場合は RBAC を適用する', async () => {
            const adminPlugin = createPlugin({
                id: 'admin',
                name: 'Admin',
                requiredRole: 'admin',
            });

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: adminPlugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(rbacMiddleware).toHaveBeenCalledWith([
                'admin',
            ]);

            expect(app.use).toHaveBeenCalledTimes(2);
        });

        it('requiredRole が無い場合は RBAC を適用しない', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(rbacMiddleware).not.toHaveBeenCalled();
        });

        it('routes が undefined の場合はマウントしない', async () => {
            const noRoutePlugin = createPlugin({
                routes: undefined,
            });
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: noRoutePlugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(app.route).not.toHaveBeenCalled();
        });

        it('無効なプラグインはスキップする', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: false,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(app.route).not.toHaveBeenCalled();
            expect(app.use).not.toHaveBeenCalled();
        });
    });

    describe('middleware', () => {
        it('authMiddleware に JWT_SECRET を渡す', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(authMiddleware).toHaveBeenCalledWith(
                'test-secret'
            );
        });
    });

    describe('plugin status', () => {
        it('getActivePlugins に DB を渡す', async () => {
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(getActivePlugins).toHaveBeenCalledWith(
                db
            );
        });
    });

    describe('module loading', () => {
        it('glob に pattern と rootDir を渡す', async () => {
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([]);

            await loadFeatureModules(
                app,
                'plugins/**/*.ts',
                db
            );

            expect(glob).toHaveBeenCalledWith(
                'plugins/**/*.ts',
                {
                    cwd: '/project',
                }
            );
        });

        it('プラグインファイルが存在しなくても例外にならない', async () => {
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([]);

            await expect(
                loadFeatureModules(
                    app,
                    '**/*.module.ts',
                    db
                )
            ).resolves.not.toThrow();
        });
    });
});
