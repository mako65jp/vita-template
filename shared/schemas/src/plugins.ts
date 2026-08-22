import { boolean, pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

// プラグイン管理テーブル
export const plugins = pgTable('plugins', {
    id: text('id').primaryKey(), // 例: 'user-management'
    name: text('name').notNull(), // 表示名: 'ユーザー管理'
    description: text('description'), // 説明
    enabled: boolean('enabled').default(true).notNull(), // 有効/無効フラグ
    updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

import { InferSelectModel, InferInsertModel } from 'drizzle-orm';

export type Plugin = InferSelectModel<typeof plugins>;
export type NewPlugin = InferInsertModel<typeof plugins>;
