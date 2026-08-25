import { eq } from 'drizzle-orm';
import { db, users } from '@shared/server';
import { AuthPlugin, AuthUser } from '@shared/functions';
import { verifyPassword } from './src/auth-utils';

export class LocalAuthPlugin implements AuthPlugin {
    name = 'local';

    async authenticate(credentials: Record<string, any>): Promise<AuthUser> {
        const { email, password } = credentials; // ログインIDとして email を想定
        if (!email || !password) {
            throw new Error('メールアドレスとパスワードを入力してください。');
        }

        const user = await db.query.users.findFirst({
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
