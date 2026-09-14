import { eq } from 'drizzle-orm';
import { users } from '@shared/db';
import { AuthPlugin, AuthUser } from '@shared/functions';
import { verifyPassword } from './src/auth-utils';
import { Database } from '@shared/db';

export class LocalAuthPlugin implements AuthPlugin {
    // クラスプロパティとして db を宣言
    private db: Database;
    constructor(db: Database) {
        this.db = db;
    }
    name = 'local';
    async authenticate(credentials: Record<string, any>): Promise<AuthUser> {
        const { email, password } = credentials; // ログインIDとして email を想定
        if (!email || !password) {
            throw new Error('メールアドレスとパスワードを入力してください。');
        }

        const user = await this.db.query.users.findFirst({
            where: eq(users.email, email),
        });

        if (!user) {
            throw new Error('Invalid local credentials');
        }

        const isPasswordValid = await verifyPassword(password, user.passwordHash);
        if (!isPasswordValid) {
            throw new Error('Invalid local credentials');
        }

        return {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
        };
    }
}

export * from './src/auth-utils';
