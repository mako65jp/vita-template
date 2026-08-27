import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { db, users } from '@shared/server';
import { ValidationError, BadRequestError, NotFoundError } from '@shared/errors';
import { hashPassword } from '@plugins/auth-local';
import { eq } from 'drizzle-orm';

export const userRoutes = new Hono();

// ログインユーザー ID の取得ヘルパー
function getCurrentUserId(c: any): number | null {
    const user = c.get('user');
    if (!user) return null;
    const rawId = user.sub ?? user.id;
    return rawId ? Number(rawId) : null;
}

// 1. ユーザー一覧取得
userRoutes.get('/', async (c) => {
    const userList = await db.select({
        id: users.id,
        name: users.name,
        email: users.email,
        role: users.role,
        isActive: users.isActive,
        createdAt: users.createdAt,
    }).from(users);

    return c.json({ users: userList });
});

// 2. ユーザー新規追加
const createUserSchema = z.object({
    name: z.string().min(1, '名前は必須です'),
    email: z.string().email('有効なメールアドレスを入力してください'),
    password: z.string().min(8, 'パスワードは８文字以上です'),
    role: z.enum(['admin', 'user']),
});

userRoutes.post(
    '/',
    zValidator('json', createUserSchema, (result) => {
        if (!result.success) {
            const invalidParams = result.error.issues.map((issue) => ({
                name: issue.path.join('.'),
                reason: issue.message,
            }));
            throw new ValidationError(invalidParams);
        }
    }),
    async (c) => {
        const body = c.req.valid('json');

        const [existingUser] = await db.select().from(users).where(eq(users.email, body.email));
        if (existingUser) {
            throw new BadRequestError('指定されたメールアドレスは既に登録されています');
        }

        const password = body.password;  //`InitPass_${Math.random().toString(36).slice(-8)}`;
        const passwordHash = await hashPassword(password);

        const [newUser] = await db.insert(users).values({
            name: body.name,
            email: body.email,
            passwordHash,
            role: body.role,
            isActive: true,
        }).returning({
            id: users.id,
            name: users.name,
            email: users.email,
            role: users.role,
            isActive: users.isActive,
            createdAt: users.createdAt
        });
        console.log('[debug]CreateUser\n' + newUser.email + '/' + password);

        return c.json({ user: newUser }, 201);
    }
);

// 3. ロール変更
const updateRoleSchema = z.object({
    role: z.enum(['user', 'admin']),
});

userRoutes.patch(
    '/:id/role',
    zValidator('json', updateRoleSchema),
    async (c) => {
        const id = Number(c.req.param('id'));
        const currentUserId = getCurrentUserId(c);
        const { role } = c.req.valid('json');

        if (currentUserId === id && role !== 'admin') {
            throw new BadRequestError('自分自身の管理者権限を変更することはできません');
        }

        const updatedUsers = await db
            .update(users)
            .set({ role })
            .where(eq(users.id, id))
            .returning({
                id: users.id,
                name: users.name,
                email: users.email,
                role: users.role,
                isActive: users.isActive,
            });

        if (updatedUsers.length === 0) {
            throw new NotFoundError('ユーザーが見つかりません');
        }

        return c.json({ user: updatedUsers[0] });
    }
);

// 4. アカウント有効化/無効化
const updateStatusSchema = z.object({
    isActive: z.boolean(),
});

userRoutes.patch(
    '/:id/status',
    zValidator('json', updateStatusSchema),
    async (c) => {
        const id = Number(c.req.param('id'));
        const currentUserId = getCurrentUserId(c);
        const { isActive } = c.req.valid('json');

        if (currentUserId === id && isActive === false) {
            throw new BadRequestError('自分自身のアカウントを無効化することはできません');
        }

        const updatedUsers = await db
            .update(users)
            .set({ isActive })
            .where(eq(users.id, id))
            .returning({
                id: users.id,
                name: users.name,
                email: users.email,
                role: users.role,
                isActive: users.isActive,
            });

        if (updatedUsers.length === 0) {
            throw new NotFoundError('ユーザーが見つかりません');
        }

        return c.json({ user: updatedUsers[0] });
    }
);

// 5. ユーザー削除
userRoutes.delete('/:id', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);

    if (currentUserId === id) {
        throw new BadRequestError('自分自身のアカウントを削除することはできません');
    }

    const deletedUsers = await db
        .delete(users)
        .where(eq(users.id, id))
        .returning({
            id: users.id,
            name: users.name,
            email: users.email,
        });

    if (deletedUsers.length === 0) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ message: 'ユーザーを削除しました', user: deletedUsers[0] });
});
