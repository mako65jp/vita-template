import { drizzle as drizzleNodePg, NodePgDatabase } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { PgDatabase } from 'drizzle-orm/pg-core'

// 全てのスキーマをエクスポートしているファイルをインポート
import * as schema from './schema';


// =========================================================================
// 💡 本番（NodePg）とテスト（Pglite）のどちらの型も受け入れられるようにユニオン型で定義
// export type Database = any; // NodePgDatabase<typeof schema> | PgliteDatabase<typeof schema>;
export type Database = PgDatabase<any, typeof schema>;

// =========================================================================
// 本番/開発環境用の Drizzle インスタンスを作成
export const createProductionDb = (connectionString: string): NodePgDatabase<typeof schema> => {
    const pool = new Pool({
        connectionString,
        max: 20,
    })
    return drizzleNodePg(pool, { schema })
}
