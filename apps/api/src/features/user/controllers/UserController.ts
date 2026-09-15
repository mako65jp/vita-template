import bcrypt from 'bcrypt';
import { Hono } from 'hono';
import { AppVariables } from '../../authentication/AppVariables';
import { JwtPayload } from '../../authentication/JwtPayload';

import { User } from '../domain/User';
import { UserMapper } from '../mappers/UserMapper';
import { UserService } from '../services/UserService';

import { authorize } from '../../authentication/middleware/authorize';
import { authorizeSelfOrAdmin } from '../../authentication/middleware/authorizeSelfOrAdmin';

export function createUserController(service: UserService) {
    const router = new Hono<{
        Variables: AppVariables;
    }>();

    router.get('/me', authorize('admin', 'user'), async (c) => {
        const jwt = c.get('jwt' as never) as JwtPayload;
        const user = await service.findById(String(jwt.sub));

        if (!user) {
            return c.notFound();
        }

        return c.json(UserMapper.toDto(user));
    });

    router.put('/me', authorize('admin', 'user'), async (c) => {
        const jwt = c.get('jwt' as never) as JwtPayload;

        const current = await service.findById(String(jwt.sub));

        if (!current) {
            return c.notFound();
        }

        const body = await c.req.json();

        const user = new User(
            current.id,
            body.name,
            body.email,
            current.passwordHash,
            current.role,
            current.isActive,
            current.createdAt,
        );

        await service.update(user);

        return c.json({
            message: 'updated',
        });
    });

    router.put('/me/password', authorize('admin', 'user'), async (c) => {
        const jwt = c.get('jwt' as never) as JwtPayload;

        const body = await c.req.json();

        const passwordHash = await bcrypt.hash(body.password, 10);

        await service.changePassword(String(jwt.sub), passwordHash);

        return c.json({
            message: 'password updated',
        });
    });

    router.get('/', authorize('admin'), async (c) => {
        const users = await service.findAll();

        return c.json(users.map((user) => UserMapper.toDto(user)));
    });

    router.get('/:id', authorizeSelfOrAdmin(), async (c) => {
        const user = await service.findById(c.req.param('id')!);

        if (!user) {
            return c.notFound();
        }

        return c.json(UserMapper.toDto(user));
    });

    router.post('/', authorize('admin'), async (c) => {
        const body = await c.req.json();

        const passwordHash = await bcrypt.hash(body.password, 10);

        const user = new User(
            0,
            body.name,
            body.email,
            passwordHash,
            body.role ?? 'user',
            true,
            new Date(),
        );

        await service.create(user);

        return c.json(
            {
                message: 'created',
            },
            201,
        );
    });

    router.put('/:id', authorize('admin'), async (c) => {
        const current = await service.findById(c.req.param('id')!);

        if (!current) {
            return c.notFound();
        }

        const body = await c.req.json();

        const user = new User(
            current.id,
            body.name,
            body.email,
            current.passwordHash,
            body.role,
            body.isActive,
            current.createdAt,
        );

        await service.update(user);

        return c.json({
            message: 'updated',
        });
    });

    router.put('/:id/password', authorize('admin'), async (c) => {
        const body = await c.req.json();

        const passwordHash = await bcrypt.hash(body.password, 10);

        await service.changePassword(c.req.param('id')!, passwordHash);

        return c.json({
            message: 'password updated',
        });
    });

    router.put('/:id/role', authorize('admin'), async (c) => {
        const jwt = c.get('jwt' as never) as JwtPayload;

        const body = await c.req.json();

        try {

            await service.changeRole(
                String(jwt.sub),
                c.req.param('id')!,
                body.role,
            );

            return c.json({
                message: 'role updated',
            });

        } catch (error) {

            return c.json(
                {
                    message:
                        error instanceof Error ? error.message : 'Role update failed',
                },
                400,
            );
        }
    });

    router.put('/:id/active', authorize('admin'), async (c) => {
        const jwt = c.get('jwt' as never) as JwtPayload;

        const body = await c.req.json();

        try {

            await service.changeActive(
                String(jwt.sub),
                c.req.param('id')!,
                body.isActive,
            );

            return c.json({
                message: 'active updated',
            });

        } catch (error) {

            return c.json(
                {
                    message:
                        error instanceof Error ? error.message : 'Active update failed',
                },
                400,
            );
        }
    });

    router.delete('/:id', authorize('admin'), async (c) => {
        const jwt = c.get('jwt' as never) as JwtPayload;

        try {

            await service.delete(
                String(jwt.sub),
                c.req.param('id'),
            );

            return c.body(
                null,
                204,
            );

        } catch (error) {

            return c.json(
                {
                    message:
                        error instanceof Error ? error.message : 'Delete failed',
                },
                400,
            );
        }
    });

    return router;
}
