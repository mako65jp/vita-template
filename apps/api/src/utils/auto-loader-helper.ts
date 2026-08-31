import { Database } from '@shared/db';
import { schema } from '@shared/db';
import { PluginRegistry } from '@shared/functions';

export async function getActivePlugins(db: Database) {
    const dbPluginsMap = new Map<string, boolean>();
    try {
        const dbPlugins = await db.select().from(schema.plugins);
        dbPlugins.forEach((p: { id: string; enabled: any }) => {
            dbPluginsMap.set(p.id, Boolean(p.enabled));
        });
    } catch (error) {
        console.warn('[Plugin Helper] DB query failed or table not found. Defaulting all plugins to enabled.');
    }

    return PluginRegistry.getAll().map((plugin) => {
        const isEnabled = dbPluginsMap.has(plugin.id)
            ? dbPluginsMap.get(plugin.id)!
            : true;

        return {
            plugin,
            isEnabled,
        };
    });
}
