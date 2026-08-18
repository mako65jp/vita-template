import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { rbacMiddleware } from '../middlewares/rbac-middleware';
import { ValidationError, BadRequestError, NotFoundError } from '@app/core';
import { db, users } from '@app/core/server';
import { hashPassword } from '@app/plugins-auth-local';
import { eq } from 'drizzle-orm';

export const userManagementRoutes = new Hono();

// RBAC: admin ロールのみ許可
userManagementRoutes.use('*', rbacMiddleware(['admin']));

// JWT ペイロード（sub / id）からログインユーザー ID を取得するヘルパー
function getCurrentUserId(c: any): number | null {
    const user = c.get('user');
    if (!user) return null;
    const rawId = user.sub ?? user.id;
    return rawId ? Number(rawId) : null;
}

const createUserSchema = z.object({
    name: z.string().min(1, '名前は必須です'),
    email: z.string().email('有効なメールアドレスを入力してください'),
    role: z.enum(['admin', 'user'], { message: 'ロールは admin または user を指定してください' }),
    password: z.string().min(8, 'パスワードは8文字以上で指定してください').optional(),
});

// GET /api/user-management - ユーザー一覧取得
userManagementRoutes.get('/', async (c) => {
    const userList = await db.select().from(users);
    return c.json({ users: userList });
});

// POST /api/user-management - ユーザー新規追加
userManagementRoutes.post(
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
        const body = await c.req.json<z.infer<typeof createUserSchema>>();

        const [existingUser] = await db.select().from(users).where(eq(users.email, body.email));
        if (existingUser) {
            throw new BadRequestError('指定されたメールアドレスは既に登録されています');
        }

        // パスワードが指定されている場合はそれを使用し、未指定の場合は自動生成
        const rawPassword = body.password || `InitPass_${Math.random().toString(36).slice(-8)}`;
        const passwordHash = await hashPassword(rawPassword);

        const [newUser] = await db.insert(users).values({
            name: body.name,
            email: body.email,
            passwordHash,
            role: body.role,
            isActive: true,
        }).returning();

        return c.json({ user: newUser, initialPassword: rawPassword }, 201);
    }
);

// PATCH /api/user-management/:id/status - ステータス変更
userManagementRoutes.patch('/:id/status', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);
    const { isActive } = await c.req.json<{ isActive: boolean }>();

    // 自分自身の無効化を防止
    if (currentUserId === id && isActive === false) {
        throw new BadRequestError('自分自身のアカウントを無効化することはできません');
    }

    const [updatedUser] = await db.update(users)
        .set({ isActive })
        .where(eq(users.id, id))
        .returning();

    if (!updatedUser) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ user: updatedUser });
});

// PATCH /api/user-management/:id/role - ロール変更
userManagementRoutes.patch('/:id/role', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);
    const { role } = await c.req.json<{ role: 'user' | 'admin' }>();

    // 自分自身の管理者権限の剥奪（user化）を防止
    if (currentUserId === id && role !== 'admin') {
        throw new BadRequestError('自分自身の管理者権限を変更することはできません');
    }

    const [updatedUser] = await db.update(users)
        .set({ role })
        .where(eq(users.id, id))
        .returning();

    if (!updatedUser) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ user: updatedUser });
});

// DELETE /api/user-management/:id - ユーザー削除
userManagementRoutes.delete('/:id', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);

    // 自分自身の削除を防止
    if (currentUserId === id) {
        throw new BadRequestError('自分自身のアカウントを削除することはできません');
    }

    const [deletedUser] = await db.delete(users)
        .where(eq(users.id, id))
        .returning();

    if (!deletedUser) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ message: 'ユーザーを削除しました', user: deletedUser });
});
