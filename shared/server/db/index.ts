import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

import { env, isTest } from '@shared/functions';
import * as schema from '@shared/schemas';

// 即時関数を使い、初期化ロジックの結果をそのまま const に代入する
const { activeQueryClient, db } = (() => {

    // 本番・開発環境のみ実際に接続する
    if (!isTest) {
        const client = postgres(env.DATABASE_URL);
        const drizzleDb = drizzle(client, { schema });
        return { activeQueryClient: client, db: drizzleDb };
    }

    // テスト環境の場合は、ダミー（またはモック）を返す
    // ※ 完全に型を合わせるため、空オブジェクトを Drizzle の型にキャスト
    return {
        activeQueryClient: undefined as any,
        db: {} as ReturnType<typeof drizzle<typeof schema>>
    };
})();

export { activeQueryClient, db };

// 1. スキーマオブジェクト全体を export
export { schema };

// 2. 個別のテーブルも直接参照できるように directly re-export
export * from '@shared/schemas';
