export interface PluginNavItem {
    id: string;             // タブ選択等で識別するためのID (例: 'users')
    label: string;          // 表示名
    path: string;           // パス
    icon?: string;          // アイコン
    roles?: string[];       // 表示権限 (例: ['admin'])。未指定時は全ユーザー表示
}

export interface PluginManifest {
    id: string;                 // 一意キー (例: 'user-management')
    name: string;               // 表示名
    description?: string;       // 説明
    navItems?: PluginNavItem[]; // フロントエンド表示用メニュー情報
    requiredRole?: string;      // 💡 API 全体に適用するアクセス制限ロール (例: 'admin')
}

import { Hono } from 'hono';

export interface ServerPluginManifest extends PluginManifest {
    routes?: Hono<any>;
}

export class PluginRegistry {
    private readonly plugins = new Map<string, PluginManifest>();

    register(plugin: PluginManifest) {
        this.plugins.set(plugin.id, plugin);
    }

    get(id: string) {
        return this.plugins.get(id);
    }

    getAll() {
        return [...this.plugins.values()];
    }

    clear() {
        this.plugins.clear();
    }
}

export const pluginRegistry = new PluginRegistry();

