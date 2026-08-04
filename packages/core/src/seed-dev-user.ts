import { db } from './db'; // packages/core 内の db エクスポートのパス
import { users } from './db/schema'; // users スキーマ
import { hashPassword } from '@app/plugins-auth-local';
// packages/core にハッシュ関数（または bcrypt/argon2）があればそれを使用

async function main() {
    const email = 'mako65jp@gmail.com';
    const password = '1234'; // お好みのパスワード

    // もし core 内にハッシュ関数があれば使い、無ければ使っているライブラリでハッシュ化
    const hashedPassword = await hashPassword(password);

    await db.insert(users).values({
        email,
        passwordHash: hashedPassword,
        name: '開発ユーザー',
    }).onConflictDoNothing();

    console.log(`✅ User created: ${email}`);
    process.exit(0);
}

main().catch((err) => {
    console.error('❌ Failed:', err);
    process.exit(1);
});
