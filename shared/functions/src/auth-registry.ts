
export interface AuthUser {
    id: string | number;
    email?: string;
    name: string;
    role?: string;
}

export interface AuthPlugin {
    name: string;
    authenticate(credentials: Record<string, any>): Promise<AuthUser>;
}

/**
 * 認証プラグインのレジストリ管理
 */
export class AuthPluginRegistry {
    private plugins = new Map<string, AuthPlugin>();

    register(plugin: AuthPlugin) {
        this.plugins.set(plugin.name, plugin);
    }

    get(name: string): AuthPlugin {
        const plugin = this.plugins.get(name);
        if (!plugin) {
            throw new Error(`認証プラグイン "${name}" が登録されていません。`);
        }
        return plugin;
    }
}

