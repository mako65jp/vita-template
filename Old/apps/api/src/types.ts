import type { Database } from '@shared/db';
import type { AuthPluginRegistry, AuthUser } from '@shared/functions';
import type { PluginRegistry } from '@shared/plugin';

export type AppEnv = {
    Variables: {
        dbInstance: Database;
        user?: AuthUser;
    };
};

export interface AppServices {
    pluginRegistry: PluginRegistry;
    authRegistry: AuthPluginRegistry;
    dbInstance: Database;
}
