import { db, users } from './index';
import { hashPassword } from '@app/plugins-auth-local';
import { eq } from 'drizzle-orm';

export async function seed() {
    console.log('🌱 開発用データを投入中...');

    const adminEmail = 'admin@example.com';
    const [existing] = await db.select().from(users).where(eq(users.email, adminEmail));

    if (!existing) {
        const passwordHash = await hashPassword('password123');
        await db.insert(users).values({
            name: '管理者ユーザー',
            email: adminEmail,
            passwordHash,
            role: 'admin',
            isActive: true,
        });
        console.log('✅ 管理者ユーザーを作成しました: admin@example.com / password123');
    } else {
        console.log('ℹ️ 管理者ユーザーは既に存在します');
    }
}

// 実行と終了の制御
async function main() {
    try {
        await seed();
        console.log('🎉 シード処理が完了しました');
    } catch (err) {
        console.error('❌ シード処理に失敗しました:', err);
        process.exitCode = 1;
    } finally {
        // 必要に応じてここで db.client.end() などの切断処理を行うか、直接プロセスを終了します
        process.exit();
    }
}

main();
