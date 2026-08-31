import { createApp } from './apps/api/src/index'; // HonoのcreateAppのパスに合わせてください
import { createTestDb } from '@shared/db';

/**
 * テストケースごとに「完全に独立したクリーンなDB」を持った
 * Honoアプリのインスタンスを新しく生成して返す関数
 */
export async function createTestEnv() {

    const testDb = createTestDb();
    const testApp = await createApp(testDb);

    return {
        app: testApp,
        db: testDb
    };
}
