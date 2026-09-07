import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
    getActiveAuthPlugin,
    resetActiveRegistry,
    setActiveRegistry,
} from './auth-service';

import {
    AuthPlugin,
    AuthPluginRegistry,
} from '@shared/functions';

describe('auth-service', () => {
    beforeEach(() => {
        resetActiveRegistry();
        vi.restoreAllMocks();
    });

    describe('setActiveRegistry', () => {
        it('設定した registry が利用される', () => {
            const plugin: AuthPlugin = {
                name: 'local',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            setActiveRegistry(registry);

            const result = getActiveAuthPlugin('local');

            expect(result).toBe(plugin);
        });
    });

    describe('getActiveAuthPlugin', () => {
        it('local プラグインを取得できる', () => {
            const plugin: AuthPlugin = {
                name: 'local',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            setActiveRegistry(registry);

            const result = getActiveAuthPlugin('local');

            expect(result).toBe(plugin);
        });

        it('ad プラグインを取得できる', () => {
            const plugin: AuthPlugin = {
                name: 'ad',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            setActiveRegistry(registry);

            const result = getActiveAuthPlugin('ad');

            expect(result).toBe(plugin);
        });

        it('registry.get が呼び出される', () => {
            const plugin: AuthPlugin = {
                name: 'local',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            const getSpy = vi.spyOn(registry, 'get');

            setActiveRegistry(registry);

            getActiveAuthPlugin('local');

            expect(getSpy).toHaveBeenCalledTimes(1);
            expect(getSpy).toHaveBeenCalledWith('local');
        });

        it('registry が未初期化の場合は例外を送出する', () => {
            expect(() =>
                getActiveAuthPlugin('local'),
            ).toThrowError(
                'AuthRegistry インスタンスが初期化されていません。',
            );
        });

        it('未登録プラグインの場合は registry の例外を伝播する', () => {
            const registry = new AuthPluginRegistry();

            setActiveRegistry(registry);

            expect(() =>
                getActiveAuthPlugin('unknown'),
            ).toThrowError(
                '認証プラグイン "unknown" が登録されていません。',
            );
        });

        it('空文字のプラグイン名を扱える', () => {
            const plugin: AuthPlugin = {
                name: '',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            setActiveRegistry(registry);

            const result = getActiveAuthPlugin('');

            expect(result).toBe(plugin);
        });

        it('特殊文字を含むプラグイン名を扱える', () => {
            const plugin: AuthPlugin = {
                name: 'ldap-test_plugin@v1',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            setActiveRegistry(registry);

            const result = getActiveAuthPlugin(
                'ldap-test_plugin@v1',
            );

            expect(result).toBe(plugin);
        });

        it('大文字小文字を区別する', () => {
            const plugin: AuthPlugin = {
                name: 'Local',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            setActiveRegistry(registry);

            expect(
                getActiveAuthPlugin('Local'),
            ).toBe(plugin);

            expect(() =>
                getActiveAuthPlugin('local'),
            ).toThrowError(
                '認証プラグイン "local" が登録されていません。',
            );
        });

        it('同名プラグインは後勝ちになる', () => {
            const oldPlugin: AuthPlugin = {
                name: 'local',
                authenticate: vi.fn(),
            };

            const newPlugin: AuthPlugin = {
                name: 'local',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(oldPlugin);
            registry.register(newPlugin);

            setActiveRegistry(registry);

            const result = getActiveAuthPlugin('local');

            expect(result).toBe(newPlugin);
        });
    });

    describe('resetActiveRegistry', () => {
        it('registry をリセットできる', () => {
            const plugin: AuthPlugin = {
                name: 'local',
                authenticate: vi.fn(),
            };

            const registry = new AuthPluginRegistry();

            registry.register(plugin);

            setActiveRegistry(registry);

            resetActiveRegistry();

            expect(() =>
                getActiveAuthPlugin('local'),
            ).toThrowError(
                'AuthRegistry インスタンスが初期化されていません。',
            );
        });

        it('複数回 reset しても問題ない', () => {
            resetActiveRegistry();
            resetActiveRegistry();

            expect(() =>
                getActiveAuthPlugin('local'),
            ).toThrowError(
                'AuthRegistry インスタンスが初期化されていません。',
            );
        });
    });
});


// import { beforeEach, describe, expect, it, vi } from 'vitest';

// import {
//     getActiveAuthPlugin,
//     resetActiveRegistry,
//     setActiveRegistry,
// } from './auth-service';

// import type {
//     AuthPlugin,
//     AuthPluginRegistry,
// } from '@shared/functions';

// describe('auth-service', () => {
//     beforeEach(() => {
//         resetActiveRegistry();
//         vi.clearAllMocks();
//     });

//     describe('setActiveRegistry', () => {
//         it('設定した registry が利用される', () => {
//             const plugin: AuthPlugin = {
//                 name: 'local',
//                 authenticate: vi.fn(),
//             };

//             const registry = {
//                 get: vi.fn().mockReturnValue(plugin),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             const result = getActiveAuthPlugin('local');

//             expect(result).toBe(plugin);
//             expect(registry.get).toHaveBeenCalledWith('local');
//         });
//     });

//     describe('getActiveAuthPlugin', () => {
//         it('local プラグインを取得できる', () => {
//             const plugin: AuthPlugin = {
//                 name: 'local',
//                 authenticate: vi.fn(),
//             };

//             const registry = {
//                 get: vi.fn().mockReturnValue(plugin),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             const result = getActiveAuthPlugin('local');

//             expect(registry.get).toHaveBeenCalledTimes(1);
//             expect(registry.get).toHaveBeenCalledWith('local');
//             expect(result).toBe(plugin);
//         });

//         it('ad プラグインを取得できる', () => {
//             const plugin: AuthPlugin = {
//                 name: 'ad',
//                 authenticate: vi.fn(),
//             };

//             const registry = {
//                 get: vi.fn().mockReturnValue(plugin),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             const result = getActiveAuthPlugin('ad');

//             expect(registry.get).toHaveBeenCalledWith('ad');
//             expect(result).toBe(plugin);
//         });

//         it('registry が未初期化の場合は例外を送出する', () => {
//             expect(() =>
//                 getActiveAuthPlugin('local')
//             ).toThrowError(
//                 'AuthRegistry インスタンスが初期化されていません。'
//             );
//         });

//         it('registry.get の例外をそのまま伝播する', () => {
//             const registry = {
//                 get: vi.fn(() => {
//                     throw new Error('Plugin not found');
//                 }),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             expect(() =>
//                 getActiveAuthPlugin('local')
//             ).toThrowError('Plugin not found');

//             expect(registry.get).toHaveBeenCalledWith('local');
//         });

//         it('空文字の providerName を渡せる', () => {
//             const plugin: AuthPlugin = {
//                 name: '',
//                 authenticate: vi.fn(),
//             };

//             const registry = {
//                 get: vi.fn().mockReturnValue(plugin),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             const result = getActiveAuthPlugin('');

//             expect(registry.get).toHaveBeenCalledWith('');
//             expect(result).toBe(plugin);
//         });

//         it('特殊文字を含む providerName を渡せる', () => {
//             const plugin: AuthPlugin = {
//                 name: 'ldap-test_plugin@v1',
//                 authenticate: vi.fn(),
//             };

//             const registry = {
//                 get: vi.fn().mockReturnValue(plugin),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             const result = getActiveAuthPlugin(
//                 'ldap-test_plugin@v1'
//             );

//             expect(registry.get).toHaveBeenCalledWith(
//                 'ldap-test_plugin@v1'
//             );
//             expect(result).toBe(plugin);
//         });

//         it('存在しない providerName の結果をそのまま返す', () => {
//             const registry = {
//                 get: vi.fn().mockReturnValue(undefined),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             const result = getActiveAuthPlugin('unknown');

//             expect(registry.get).toHaveBeenCalledWith('unknown');
//             expect(result).toBeUndefined();
//         });

//         it('大文字小文字を区別して registry.get に渡す', () => {
//             const plugin: AuthPlugin = {
//                 name: 'Local',
//                 authenticate: vi.fn(),
//             };

//             const registry = {
//                 get: vi.fn().mockReturnValue(plugin),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             const result = getActiveAuthPlugin('Local');

//             expect(registry.get).toHaveBeenCalledWith('Local');
//             expect(result).toBe(plugin);
//         });
//     });

//     describe('resetActiveRegistry', () => {
//         it('registry をリセットできる', () => {
//             const registry = {
//                 get: vi.fn(),
//             } as unknown as AuthPluginRegistry;

//             setActiveRegistry(registry);

//             resetActiveRegistry();

//             expect(() =>
//                 getActiveAuthPlugin('local')
//             ).toThrowError(
//                 'AuthRegistry インスタンスが初期化されていません。'
//             );
//         });

//         it('複数回 reset しても問題ない', () => {
//             resetActiveRegistry();
//             resetActiveRegistry();

//             expect(() =>
//                 getActiveAuthPlugin('local')
//             ).toThrowError(
//                 'AuthRegistry インスタンスが初期化されていません。'
//             );
//         });
//     });
// });


// // import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
// // import { getActiveAuthPlugin, setActiveRegistry } from './auth-service';
// // import { AuthPluginRegistry } from '@shared/functions';
// // import { LocalAuthPlugin } from '@plugins/auth-local';
// // import { ActiveDirectoryAuthPlugin } from '@plugins/auth-ad';

// // describe('auth-service', () => {

// //     beforeEach(() => {
// //         // 💡 毎ケースの開始時は、メモリを完全にまっさらにクリア（初期化）するだけに留めます。
// //         // ここでの中途半端な register や setActiveRegistry の先走りが全てのバグの元凶でした。
// //         setActiveRegistry(null as unknown as AuthPluginRegistry);
// //     });

// //     afterEach(() => {
// //         // 各ケースの終了後に環境変数のモックを確実にクリーンアップ
// //         vi.unstubAllEnvs();
// //     });

// //     it('1. Registry インスタンスが初期化されていない場合、明確な初期化エラーをスローすること', () => {
// //         // まっさらな状態のまま呼び出して、期待通りのエラー防衛線が走るかを厳密に検証
// //         expect(() => getActiveAuthPlugin()).toThrowError(
// //             'AuthRegistry インスタンスが初期化されていません。'
// //         );
// //     });

// //     it('2. AUTH_PROVIDER が "local" の場合、レジストリから local 用のプラグインインスタンスが正しく切り出されること', () => {
// //         // 💡 【大正解の順序】すべてをこのケース内で、独立して直列に実行します。

// //         // 1. まず、このケースが検証したい環境変数を「一番最初」に上書き固定する
// //         vi.stubEnv('AUTH_PROVIDER', 'local');

// //         // 2. その環境変数のコンテキストの元で、レジストリとプラグインを新しく組み立てる
// //         const registry = new AuthPluginRegistry();
// //         const mockDb = {} as any;
// //         const localPlugin = new LocalAuthPlugin(mockDb);
// //         const adPlugin = new ActiveDirectoryAuthPlugin();

// //         registry.register(localPlugin);
// //         registry.register(adPlugin);

// //         // 3. 最後に、満を持してレジストリをアクティブ化（これで正しいキャッシュが焼き付きます）
// //         setActiveRegistry(registry);

// //         const activePlugin = getActiveAuthPlugin();

// //         expect(activePlugin.name).toBe('local');
// //         expect(activePlugin).toBe(localPlugin); // 参照が完全に同一であることを確認
// //     });

// //     it('3. AUTH_PROVIDER が "ad" の場合、レジストリから ad 用のプラグインインスタンスが正しく切り出されること', () => {
// //         // 💡 【大正解の順序】ケース2のゴミ（キャッシュ）を1ミリも引き継がせないための完全隔離実行

// //         // 1. まず、このケースのための環境変数を「一番最初」に "ad" に上書き固定する
// //         vi.stubEnv('AUTH_PROVIDER', 'ad');

// //         // 2. まっさらな状態から、もう一度新しくレジストリを生成する（使い捨て）
// //         const registry = new AuthPluginRegistry();
// //         const mockDb = {} as any;
// //         const localPlugin = new LocalAuthPlugin(mockDb);
// //         const adPlugin = new ActiveDirectoryAuthPlugin();

// //         registry.register(localPlugin);
// //         registry.register(adPlugin);

// //         // 3. 環境変数が "ad" になった状態で、レジストリをアクティブ化（これで ad が正しく引き当たります）
// //         setActiveRegistry(registry);

// //         const activePlugin = getActiveAuthPlugin();

// //         expect(activePlugin.name).toBe('ad');
// //         expect(activePlugin).toBe(adPlugin); // 参照が完全に同一であることを確認
// //     });
// // });
