// 
// このファイルは codegen.ts で、自動生成されました
// 
import { Database } from '../database';
import * as schema from '../schema';
import { eq } from 'drizzle-orm';

// Plugins リポジトリ
export function createPluginRepository(db: Database) {
  return {
    async findById(id: typeof schema.plugins.$inferSelect.id) {
      return await db.query.plugins.findFirst({ where: eq(schema.plugins.id, id) });
    }
  };
}

// Users リポジトリ
export function createUserRepository(db: Database) {
  return {
    async findById(id: typeof schema.users.$inferSelect.id) {
      return await db.query.users.findFirst({ where: eq(schema.users.id, id) });
    }
  };
}
