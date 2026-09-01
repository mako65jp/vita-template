import { createApp } from '@apps/api/index';
import { drizzle as drizzlePglite } from 'drizzle-orm/pglite'
import { PGlite } from '@electric-sql/pglite'
import * as fs from 'fs';
import * as path from 'path';
import * as schema from '@shared/db/schema';
import { Database } from '@shared/db';

// 💡 1本に結合された巨大な全マイグレーションSQL文字列をキャッシュする
let pgliteMegaSql: string | null = null;

const getCombinedMigrationSql = (): string => {
    if (pgliteMegaSql) return pgliteMegaSql;

    const migrationsDir = '/workspace/shared/db/drizzle';
    if (!fs.existsSync(migrationsDir)) {
        throw new Error(`マイグレーションフォルダが見つかりません: ${migrationsDir}`);
    }

    const files = fs.readdirSync(migrationsDir);
    const sqlFiles = files
        .filter(file => file.endsWith('.sql'))
        .sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));

    // 💡 すべてのSQLファイルを改行コードで結び、1本の巨大なSQLとしてメモリに保持
    pgliteMegaSql = sqlFiles.map(file => fs.readFileSync(path.join(migrationsDir, file), 'utf8')).join('\n');
    return pgliteMegaSql;
}

/**
 * 💡 【真の並行安全・極限インメモリスピード】テスト環境切り出しファクトリ関数
 */
export async function createTestEnv() {
    const client = new PGlite({
        relaxedDurability: true, // WASM内の同期ディスクI/Oを完全にオフにします
    });

    // 💡 【解決の核心】
    // forループによる `await` の数珠繋ぎ（連続呼び出し）を完全に廃止。
    // 巨大な1本のSQL文字列にすることで、非同期のイベント待ち（Promise解決）の発生回数を
    // ケース開始ごとに「たった1回」に限定します。
    // WASMのインメモリ解析が一瞬で終わるため、他ファイルのイベントループを一切ブロックしなくなります。
    const megaSql = getCombinedMigrationSql();
    await client.exec(megaSql);

    // 3. この環境専用に完全にロックされた Drizzle と使い捨て App を構築して返却
    const testDb: Database = drizzlePglite(client, { schema });
    const testApp = await createApp(testDb);
    // const close = async (): Promise<void> => { await client.close(); }

    return {
        app: testApp,
        db: testDb,
        pglite: client
    };
}
