import { env, AuthPlugin, AuthPluginRegistry } from '@shared/functions';

// 💡 修正ポイント: アプリ起動時にセットされる、アクティブなレジストリのインスタンスへの参照を保持する
let activeRegistry: AuthPluginRegistry | null = null;

export function setActiveRegistry(registry: AuthPluginRegistry) {
    activeRegistry = registry;
}

/**
 * 環境変数に応じたアクティブな認証プラグインを取得する
 */
export function getActiveAuthPlugin(): AuthPlugin {
    const providerName = env.AUTH_PROVIDER; // 'local' または 'ad'

    // 💡 インスタンスがセットされている場合は、そこから安全に get する
    if (activeRegistry) {
        return activeRegistry.get(providerName);
    }

    // バックマウント（もしどうしてもstaticのまま動かしたい箇所への一時的な防衛線）
    throw new Error('AuthRegistry インスタンスが初期化されていません。');
}


// import { env, AuthPlugin, AuthPluginRegistry } from '@shared/functions';

// /**
//  * 環境変数に応じたアクティブな認証プラグインを取得する
//  */
// export function getActiveAuthPlugin(): AuthPlugin {
//     const providerName = env.AUTH_PROVIDER; // 'local' または 'ad'
//     return AuthPluginRegistry.get(providerName);
// }
