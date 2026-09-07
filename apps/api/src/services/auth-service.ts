import { env, AuthPlugin, AuthPluginRegistry } from '@shared/functions';

// （アプリ起動時にセットされる）アクティブなレジストリのインスタンスへの参照を保持する
let activeRegistry: AuthPluginRegistry | null = null;

export function setActiveRegistry(registry: AuthPluginRegistry) {
    activeRegistry = registry;
}

export function resetActiveRegistry(): void {
    activeRegistry = null;
}

/**
 * 保持しているアクティブな認証プラグインを取得する
 */
export function getActiveAuthPlugin(
    providerName: string = env.AUTH_PROVIDER
): AuthPlugin {
    //     const providerName = env.AUTH_PROVIDER; // 'local' または 'ad'

    // 💡 インスタンスがセットされている場合は、そこから安全に get する
    if (activeRegistry) {
        return activeRegistry.get(providerName);
    }

    // バックマウント（もしどうしてもstaticのまま動かしたい箇所への一時的な防衛線）
    throw new Error('AuthRegistry インスタンスが初期化されていません。');
}
