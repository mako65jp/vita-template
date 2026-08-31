import { drizzle, NodePgClient, NodePgDatabase } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { IMemoryDb, newDb, IBackup } from 'pg-mem' // 💡 IBackup を追加
import * as fs from 'fs';
import * as path from 'path';

// 全てのスキーマをエクスポートしているファイルをインポート
import * as schema from './schema';

export type Database = NodePgDatabase<typeof schema>;

// 本番/開発環境用の Drizzle インスタンスを作成
export const createProductionDb = (connectionString: string): NodePgDatabase<typeof schema> => {
    const pool = new Pool({
        connectionString,
        max: 20,
    })
    // 型安全性を高めるため、スキーマを渡して初期化
    return drizzle(pool, { schema })
}


// テスト実行中に、同じDBインスタンスを使い回せるように参照を保持する変数
let cachedTestDb: Database | null = null;
let currentRawMemDb: IMemoryDb | null = null; // 後からTRUNCATE等をするための脱出口

// 💡 スキーマ適用直後の「まっさらなDB状態」を記憶するグローバルバックアップ
let dbBaseBackup: IBackup | null = null;


// テスト環境用の Drizzle インスタンス (pg-mem) を作成
export const createTestDb = (): NodePgDatabase<typeof schema> => {

    // 💡 【重要】すでに Drizzle インスタンスが作成されている場合の処理
    if (cachedTestDb) {
        if (dbBaseBackup) {
            // 2回目以降の呼び出し時は、既存のコネクション参照を「維持したまま」、データだけを初期状態に一瞬で巻き戻す
            dbBaseBackup.restore();
        }
        // 参照エラーを起こさないよう、完全に辻褄の合った既存のインスタンスをそのまま返す
        return cachedTestDb;
    }


    // 1. メモリDBを作成（本当に最初の1回だけ実行される）
    const dbMem = newDb()

    // マイグレーションSQLの読み込み先 (コンテナ内の絶対パス)
    const migrationsDir = '/workspace/shared/db/drizzle';
    if (!fs.existsSync(migrationsDir)) {
        throw new Error(`マイグレーションフォルダが見つかりません: ${migrationsDir}`);
    }

    const files = fs.readdirSync(migrationsDir);
    const sqlFiles = files
        .filter(file => file.endsWith('.sql'))
        .sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));

    for (const file of sqlFiles) {
        const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
        dbMem.public.none(sql);
    }

    // 💡 スキーマ構築が完了した「初期データ0件」の状態をバックアップとして保存
    dbBaseBackup = dbMem.backup();

    // 後からTRUNCATE等をするための脱出口を確保
    currentRawMemDb = dbMem;


    // 2. pg-mem から「本物のpgパッケージを模したクラス群」を取得
    const pgAdapter = dbMem.adapters.createPg();

    // 3. pg-mem が生成した本物の「Clientクラス」を使ってインスタンスを生成
    const client = new pgAdapter.Client();

    // 4. クエリを発行できるように内部的な仮想コネクションを確立
    client.connect();

    // =========================================================================
    // ★【最重要】Drizzle ORM の rowMode: 'array' 特有のバグを物理的に回避する防衛網
    // （元のコードのハックを1文字も変えずに完全維持しています）
    // =========================================================================
    const originalQuery = client.query;
    client.query = function (config: any, values: any, callback: any) {
        let queryRowsMode: string | undefined = undefined;
        let normalizedConfig = config;

        if (typeof config === 'object' && config !== null) {
            queryRowsMode = config.rowMode;
            normalizedConfig = { ...config };
            delete normalizedConfig.rowMode;
            if (normalizedConfig.name) delete normalizedConfig.name;
            if (normalizedConfig.types) delete normalizedConfig.types;
            normalizedConfig.getTypeParser = (id: any) => (val: any) => val;
        }

        try {
            (client as any).getTypeParser = (id: any) => (val: any) => val;
        } catch (e) { }

        const result = originalQuery.call(client, normalizedConfig, values, callback);

        if (result && typeof result.then === 'function') {
            return result.then((res: any) => {
                if (queryRowsMode === 'array' && res && Array.isArray(res.rows)) {
                    res.rows = res.rows.map((row: any) => Object.values(row));
                }
                return res;
            });
        }

        if (queryRowsMode === 'array' && result && Array.isArray(result.rows)) {
            result.rows = result.rows.map((row: any) => Object.values(row));
        }
        return result;
    } as any;
    // =========================================================================

    // 5. Drizzle に本物のプロパティを兼ね備えた client を NodePgClient としてキャストして渡す
    cachedTestDb = drizzle(client as unknown as NodePgClient, { schema });
    return cachedTestDb;
}


// import { drizzle, NodePgClient, NodePgDatabase } from 'drizzle-orm/node-postgres'
// import { env } from '@shared/functions';
// import pg, { Pool } from 'pg'
// import { IMemoryDb, newDb } from 'pg-mem'
// import * as fs from 'fs';
// import * as path from 'path';

// // 全てのスキーマをエクスポートしているファイルをインポート
// import * as schema from './schema';

// export type Database = NodePgDatabase<typeof schema>;

// // driverに応じた Drizzle インスタンス生成
// export const createDb = (driver: 'pg' | 'pgmem') => {
//     if (driver === 'pg') {
//         return createProductionDb(env.DATABASE_URL);
//     } else {
//         // pg-memでインメモリDBを初期化
//         return createTestDb();
//     }
// }

// // 本番/開発環境用の Drizzle インスタンスを作成
// export const createProductionDb = (connectionString: string): NodePgDatabase<typeof schema> => {
//     const pool = new Pool({
//         connectionString,
//         max: 20,
//     })
//     // 型安全性を高めるため、スキーマを渡して初期化
//     return drizzle(pool, { schema })
// }


// // テスト実行中に、同じDBインスタンスを使い回せるように参照を保持する変数
// let cachedTestDb: Database | null = null;
// let currentRawMemDb: IMemoryDb | null = null; // 後からTRUNCATE等をするための脱出口

// // テスト環境用の Drizzle インスタンス (pg-mem) を作成
// export const createTestDb = (): NodePgDatabase<typeof schema> => {

//     // 💡 すでに作成済みのテスト用DBがあれば、新しく作らずにそれを返す（ズレの防止）
//     if (cachedTestDb) return cachedTestDb;


//     // 1. メモリDBを作成
//     const dbMem = newDb()

//     // ⚠️ 非常に重要: pg-mem の中に Drizzle のテーブル構造（スキーマ）を同期させる
//     // drizzle-kit push などの代わりに、テスト実行時にインメモリ上でマイグレーションをシミュレートします
//     // ※ DrizzleのマイグレーションSQLファイルを読み込んで dbMem.public.none(sql) するのが確実です。

//     // マイグレーションSQLの読み込み先 (コンテナ内の絶対パス)
//     const migrationsDir = '/workspace/shared/db/drizzle';
//     if (!fs.existsSync(migrationsDir)) {
//         throw new Error(`マイグレーションフォルダが見つかりません: ${migrationsDir}`);
//     }

//     const files = fs.readdirSync(migrationsDir);
//     const sqlFiles = files
//         .filter(file => file.endsWith('.sql'))
//         .sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));

//     for (const file of sqlFiles) {
//         const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
//         dbMem.public.none(sql);
//     }


//     // 2. pg-mem から「本物のpgパッケージを模したクラス群」を取得
//     // pgAdapter は { Pool: [Class], Client: [Class] } という構造になっています
//     const pgAdapter = dbMem.adapters.createPg();

//     // 3. pg-mem が生成した本物の「Clientクラス」を使ってインスタンスを生成
//     // これにより、pg.Clientが持つ内部プロパティ（port, host, ssl等）がすべて自動で生え揃います
//     const client = new pgAdapter.Client();

//     // 4. クエリを発行できるように内部的な仮想コネクションを確立
//     client.connect();

//     // =========================================================================
//     // ★【最重要】Drizzle ORM の rowMode: 'array' 特有のバグを物理的に回避する防衛網
//     // =========================================================================
//     const originalQuery = client.query;
//     client.query = function (config: any, values: any, callback: any) {
//         let queryRowsMode: string | undefined = undefined;
//         let normalizedConfig = config;

//         // Drizzle からクエリ設定オブジェクトが渡された場合
//         if (typeof config === 'object' && config !== null) {
//             queryRowsMode = config.rowMode;

//             // 💡 新しいプレーンなオブジェクトにコピーを作成
//             normalizedConfig = { ...config };

//             // 1. rowMode: 'array' を消去して pg-mem のパニックを防ぐ
//             delete normalizedConfig.rowMode;

//             // 2. ★【今回の特効薬】Drizzle が内部で pg-mem の未実装関数「getTypeParser」を
//             //    呼び出すトリガーとなる各種カスタムパーサー（nameやtypesなど）を強制的に上書き・消去します。
//             //    これにより、pg-mem の「getTypeParser is not supported」エラーの発生条件を完全に消滅させます。
//             if (normalizedConfig.name) delete normalizedConfig.name;
//             if (normalizedConfig.types) delete normalizedConfig.types;

//             // もし config 自体に型パース関数群が詰まっていた場合の安全弁
//             normalizedConfig.getTypeParser = (id: any) => (val: any) => val;
//         }

//         // 💡 インスタンス側の getTypeParser にも念のためダミーを仕込む（プロパティが書き換え可能だった場合への保険）
//         try {
//             (client as any).getTypeParser = (id: any) => (val: any) => val;
//         } catch (e) {
//             // ロックされていて書き換え不可能な場合はスキップ
//         }

//         // 3. 牙を抜いたクエリを pg-mem のクエリエンジンに安全に流し込む
//         const result = originalQuery.call(client, normalizedConfig, values, callback);

//         // 4. Promise（非同期）で結果が戻る場合の変換処理（Drizzle の期待する配列モードへ復元）
//         if (result && typeof result.then === 'function') {
//             return result.then((res: any) => {
//                 if (queryRowsMode === 'array' && res && Array.isArray(res.rows)) {
//                     res.rows = res.rows.map((row: any) => Object.values(row));
//                 }
//                 return res;
//             });
//         }

//         // 5. 同期的に結果が戻る場合のフォールバック
//         if (queryRowsMode === 'array' && result && Array.isArray(result.rows)) {
//             result.rows = result.rows.map((row: any) => Object.values(row));
//         }
//         return result;
//     } as any;
//     // =========================================================================

//     // 5. Drizzle に本物のプロパティを兼ね備えた client を NodePgClient としてキャストして渡す
//     // これにより、Drizzle側の型チェックは「完全な互換性がある」と判定し、1文字のエラーも出なくなります
//     return drizzle(client as unknown as NodePgClient, { schema });
// }
