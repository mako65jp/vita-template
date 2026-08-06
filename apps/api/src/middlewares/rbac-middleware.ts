// apps/api/src/middlewares/rbac-middleware.ts
import type { MiddlewareHandler } from 'hono';
import { ForbiddenError, UnauthorizedError } from '@app/core';

/**
 * 許可されたロールのみアクセスを許可する RBAC ミドルウェア
 * @param allowedRoles 許可するロールの配列 (例: ['admin'])
 */
export function requireRole(allowedRoles: string[]): MiddlewareHandler {
    return async (c, next) => {
        const user = c.get('user') as { role?: string } | undefined;

        // 認証ミドルウェアが通過していない場合
        if (!user) {
            throw new UnauthorizedError('Authentication required.');
        }

        // ロールが未設定または許可されていないロールの場合 403 Forbidden
        if (!user.role || !allowedRoles.includes(user.role)) {
            throw new ForbiddenError('You do not have permission to access this resource.');
        }

        await next();
    };
}
