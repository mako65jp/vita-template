import { env, AuthPlugin, AuthPluginRegistry } from '@shared/functions';
import { LocalAuthPlugin } from '@plugins/auth-local';
import { ActiveDirectoryAuthPlugin } from '@plugins/auth-ad';

// プラグインの自動登録
AuthPluginRegistry.register(new LocalAuthPlugin());
AuthPluginRegistry.register(new ActiveDirectoryAuthPlugin());

/**
 * 環境変数に応じたアクティブな認証プラグインを取得する
 */
export function getActiveAuthPlugin(): AuthPlugin {
    const providerName = env.AUTH_PROVIDER; // 'local' または 'ad'
    return AuthPluginRegistry.get(providerName);
}
