import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { db, users as usersTable } from '@app/core/server';
import { ValidationError, BadRequestError, NotFoundError } from '@app/core';
import { hashPassword } from '@app/plugins-auth-local';
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
        id: usersTable.id,
        name: usersTable.name,
        email: usersTable.email,
        role: usersTable.role,
        isActive: usersTable.isActive,
        createdAt: usersTable.createdAt,
    }).from(usersTable);

    return c.json({ users: userList });
});

// 2. ユーザー新規追加
const createUserSchema = z.object({
    name: z.string().min(1, '名前は必須です'),
    email: z.string().email('有効なメールアドレスを入力してください'),
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

        const [existingUser] = await db.select().from(usersTable).where(eq(usersTable.email, body.email));
        if (existingUser) {
            throw new BadRequestError('指定されたメールアドレスは既に登録されています');
        }

        const defaultPassword = `InitPass_${Math.random().toString(36).slice(-8)}`;
        const passwordHash = await hashPassword(defaultPassword);

        const [newUser] = await db.insert(usersTable).values({
            name: body.name,
            email: body.email,
            passwordHash,
            role: body.role,
            isActive: true,
        }).returning({
            id: usersTable.id,
            name: usersTable.name,
            email: usersTable.email,
            role: usersTable.role,
            isActive: usersTable.isActive,
            createdAt: usersTable.createdAt,
        });

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
            .update(usersTable)
            .set({ role })
            .where(eq(usersTable.id, id))
            .returning({
                id: usersTable.id,
                name: usersTable.name,
                email: usersTable.email,
                role: usersTable.role,
                isActive: usersTable.isActive,
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
            .update(usersTable)
            .set({ isActive })
            .where(eq(usersTable.id, id))
            .returning({
                id: usersTable.id,
                name: usersTable.name,
                email: usersTable.email,
                role: usersTable.role,
                isActive: usersTable.isActive,
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
        .delete(usersTable)
        .where(eq(usersTable.id, id))
        .returning({
            id: usersTable.id,
            name: usersTable.name,
            email: usersTable.email,
        });

    if (deletedUsers.length === 0) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ message: 'ユーザーを削除しました', user: deletedUsers[0] });
});

// import { Hono } from 'hono';
// import { z } from 'zod';
// import { zValidator } from '@hono/zod-validator';
// import { db, users as usersTable } from '@app/core/server';
// import { eq } from 'drizzle-orm';

// export const userRoutes = new Hono();

// // 1. ユーザー一覧取得
// userRoutes.get('/', async (c) => {
//     const userList = await db.select({
//         id: usersTable.id,
//         name: usersTable.name,
//         email: usersTable.email,
//         role: usersTable.role,
//         isActive: usersTable.isActive,
//         createdAt: usersTable.createdAt,
//     }).from(usersTable);

//     return c.json({ users: userList });
// });

// // 2. ロール変更
// const updateRoleSchema = z.object({
//     role: z.enum(['user', 'admin']),
// });

// userRoutes.patch(
//     '/:id/role',
//     zValidator('json', updateRoleSchema),
//     async (c) => {
//         const id = Number(c.req.param('id'));
//         const { role } = c.req.valid('json');

//         const updatedUsers = await db
//             .update(usersTable)
//             .set({ role })
//             .where(eq(usersTable.id, id))
//             .returning({
//                 id: usersTable.id,
//                 name: usersTable.name,
//                 email: usersTable.email,
//                 role: usersTable.role,
//                 isActive: usersTable.isActive,
//             });

//         if (updatedUsers.length === 0) {
//             return c.json({ message: 'User not found' }, 404);
//         }

//         return c.json({ user: updatedUsers[0] });
//     }
// );

// // 3. アカウント有効化/無効化
// const updateStatusSchema = z.object({
//     isActive: z.boolean(),
// });

// userRoutes.patch(
//     '/:id/status',
//     zValidator('json', updateStatusSchema),
//     async (c) => {
//         const id = Number(c.req.param('id'));
//         const { isActive } = c.req.valid('json');

//         const updatedUsers = await db
//             .update(usersTable)
//             .set({ isActive })
//             .where(eq(usersTable.id, id))
//             .returning({
//                 id: usersTable.id,
//                 name: usersTable.name,
//                 email: usersTable.email,
//                 role: usersTable.role,
//                 isActive: usersTable.isActive,
//             });

//         if (updatedUsers.length === 0) {
//             return c.json({ message: 'User not found' }, 404);
//         }

//         return c.json({ user: updatedUsers[0] });
//     }
// );
