// packages/core/src/plugins/registry.ts
import { Hono } from 'hono';

export interface PluginManifest {
    id: string;            // 一意キー (例: 'user-management')
    name: string;          // 表示名
    description?: string;  // 説明
    routes: Hono;          // プラグインが提供する Hono ルーター
    navItems?: Array<{     // フロントエンド表示用メニュー情報
        label: string;
        path: string;
        icon?: string;
    }>;
}

export class PluginRegistry {
    private static plugins = new Map<string, PluginManifest>();

    static register(plugin: PluginManifest) {
        this.plugins.set(plugin.id, plugin);
    }

    static get(id: string): PluginManifest | undefined {
        return this.plugins.get(id);
    }

    static getAll(): PluginManifest[] {
        return Array.from(this.plugins.values());
    }
}
