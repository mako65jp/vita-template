import { CreateUserSchema, UserDetailSchema } from '@packages/schemas';
import { Hono } from 'hono';
import { AppVariables } from '../authentication/AppVariables';
import { authorize } from '../authentication/middleware/authorize';
import { hashPassword } from './auth-utils';
import type { UserService } from './service';

export function createUserController(userService: UserService) {
    const router = new Hono<{
        Variables: AppVariables;
    }>();

    router.get('/me', authorize('admin', 'user'), async (c) => {
        const principal = c.get('principal');

        const user = await userService.findById(Number(principal.userId));
        if (!user) {
            return c.notFound();
        }

        return c.json(UserDetailSchema.parse(user));
    });

    router.put('/me', authorize('admin', 'user'), async (c) => {
        const principal = c.get('principal');

        const current = await userService.findById(Number(principal.userId));
        if (!current) {
            return c.notFound();
        }

        const body = await c.req.json();

        const user = {
            id: current.id,
            name: body.name,
            email: body.email,
            passwordHash: current.passwordHash,
            role: current.role,
            isActive: current.isActive,
            createdAt: current.createdAt,
        };

        await userService.update(user);

        return c.json({
            message: 'updated',
        });
    });

    router.put('/me/password', authorize('admin', 'user'), async (c) => {
        const principal = c.get('principal');
        const body = await c.req.json();

        const passwordHash = await hashPassword(body.password);

        await userService.changePassword(Number(principal.userId), passwordHash);

        return c.json({
            message: 'password updated',
        });
    });

    router.get('/:id', async (c) => {
        const id = Number(c.req.param('id'));
        if (Number.isNaN(id)) {
            return c.json(
                {
                    message: 'invalid id',
                },
                400,
            );
        }
        const user = await userService.findById(id);
        if (!user) {
            return c.json({ message: 'user not found' }, 404);
        }

        return c.json(UserDetailSchema.parse(user));
    });

    router.post('/', async (c) => {
        const body = await c.req.json();
        const request = CreateUserSchema.parse(body);

        const user = await userService.create(request);

        return c.json(UserDetailSchema.parse(user), 201);
    });

    return router;
}
