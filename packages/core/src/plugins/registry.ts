// packages/core/src/plugins/registry.ts
import { Hono } from 'hono';

export interface PluginNavItem {
    id: string;             // タブ選択等で識別するためのID (例: 'users')
    label: string;          // 表示名
    path: string;           // パス
    icon?: string;          // アイコン
    roles?: string[];       // 表示権限 (例: ['admin'])。未指定時は全ユーザー表示
}

export interface PluginManifest {
    id: string;             // 一意キー (例: 'user-management')
    name: string;           // 表示名
    description?: string;   // 説明
    routes?: Hono;          // プラグインが提供する Hono ルーター（UI専用登録時は省略可能）
    navItems?: PluginNavItem[]; // フロントエンド表示用メニュー情報
    requiredRole?: string;  // 💡 API 全体に適用するアクセス制限ロール (例: 'admin')
}

export class PluginRegistry {
    private static plugins = new Map<string, PluginManifest>();

    static clear() {
        this.plugins = new Map<string, PluginManifest>();
    }

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

