import { describe, expect, it } from 'vitest';

import { hashPassword, verifyPassword, signJwt, verifyJwt } from './auth-utils';

describe('hashPassword', () => {
    it('パスワードをハッシュ化できる', async () => {
        const password = 'password123';

        const hash = await hashPassword(password);

        expect(hash).toBeDefined();
        expect(hash).not.toBe(password);
        expect(typeof hash).toBe('string');
    });

    it('同じパスワードでも異なるハッシュを生成する', async () => {
        const password = 'password123';

        const hash1 = await hashPassword(password);
        const hash2 = await hashPassword(password);

        expect(hash1).not.toBe(hash2);
    });
});

describe('verifyPassword', () => {
    it('正しいパスワードを検証できる', async () => {
        const password = 'password123';

        const hash = await hashPassword(password);

        const result = await verifyPassword(password, hash);

        expect(result).toBe(true);
    });

    it('誤ったパスワードは false を返す', async () => {
        const hash = await hashPassword('password123');

        const result = await verifyPassword('wrong-password', hash);

        expect(result).toBe(false);
    });

    it('空文字パスワードも検証できる', async () => {
        const hash = await hashPassword('');

        const result = await verifyPassword('', hash);

        expect(result).toBe(true);
    });
});

describe('signJwt', () => {
    it('JWTを生成できる', async () => {
        const payload = {
            userId: 1,
            email: 'test@example.com',
        };

        const token = await signJwt(payload, 'secret-key');

        expect(token).toBeDefined();
        expect(typeof token).toBe('string');

        const segments = token.split('.');

        expect(segments).toHaveLength(3);
    });

    it('expiresInを指定してJWTを生成できる', async () => {
        const token = await signJwt(
            {
                userId: 1,
            },
            'secret-key',
            '1h',
        );

        expect(token).toBeDefined();
    });
});

describe('verifyJwt', () => {
    it('正常なJWTを検証できる', async () => {
        const payload = {
            userId: 1,
            email: 'test@example.com',
            role: 'admin',
        };

        const secret = 'secret-key';

        const token = await signJwt(payload, secret);

        const result = await verifyJwt<{
            userId: number;
            email: string;
            role: string;
        }>(token, secret);

        expect(result).toMatchObject({
            userId: 1,
            email: 'test@example.com',
            role: 'admin',
        });
    });

    it('異なるsecretの場合はnullを返す', async () => {
        const token = await signJwt({ userId: 1 }, 'secret-1');

        const result = await verifyJwt(token, 'secret-2');

        expect(result).toBeNull();
    });

    it('不正なJWTの場合はnullを返す', async () => {
        const result = await verifyJwt('invalid-token', 'secret-key');

        expect(result).toBeNull();
    });

    it('空文字トークンの場合はnullを返す', async () => {
        const result = await verifyJwt('', 'secret-key');

        expect(result).toBeNull();
    });

    it('改ざんされたJWTの場合はnullを返す', async () => {
        const token = await signJwt(
            {
                userId: 1,
            },
            'secret-key',
        );

        const tamperedToken = token.slice(0, -5) + 'abcde';

        const result = await verifyJwt(tamperedToken, 'secret-key');

        expect(result).toBeNull();
    });

    it('ジェネリクス型を利用してPayloadを取得できる', async () => {
        interface UserPayload {
            userId: number;
            email: string;
        }

        const token = await signJwt(
            {
                userId: 123,
                email: 'test@example.com',
            },
            'secret-key',
        );

        const result = await verifyJwt<UserPayload>(token, 'secret-key');

        expect(result?.userId).toBe(123);
        expect(result?.email).toBe('test@example.com');
    });
});

// import { describe, it, expect } from 'vitest';
// import { hashPassword, verifyPassword, signJwt, verifyJwt } from './auth-utils';

// describe('Auth Utilities (Step 4.1)', () => {
//     // ----------------------------------------------------
//     // 1. パスワードハッシュ化・照合テスト
//     // ----------------------------------------------------
//     describe('Password Hashing', () => {
//         it('平文パスワードを正しくハッシュ化し、検証できること', async () => {
//             const rawPassword = 'mySecurePassword123';
//             const hashedPassword = await hashPassword(rawPassword);

//             // 平文とハッシュ値が異なっていること
//             expect(hashedPassword).not.toBe(rawPassword);

//             // 正しいパスワードの照合
//             const isValid = await verifyPassword(rawPassword, hashedPassword);
//             expect(isValid).toBe(true);
//         });

//         it('誤ったパスワードの場合は検証に失敗すること', async () => {
//             const rawPassword = 'mySecurePassword123';
//             const wrongPassword = 'WrongPassword456';
//             const hashedPassword = await hashPassword(rawPassword);

//             const isValid = await verifyPassword(wrongPassword, hashedPassword);
//             expect(isValid).toBe(false);
//         });
//     });

//     // ----------------------------------------------------
//     // 2. JWT 発行・検証テスト
//     // ----------------------------------------------------
//     describe('JWT Operations', () => {
//         const mockPayload = { userId: 'user-123', role: 'admin' };
//         const secret = 'test-secret-key-at-least-32-chars-long';

//         it('Payload から JWT を発行し、正しくデコード・検証できること', async () => {
//             const token = await signJwt(mockPayload, secret);
//             expect(typeof token).toBe('string');
//             expect(token.length).toBeGreaterThan(0);

//             const decoded = await verifyJwt(token, secret);
//             expect(decoded).toMatchObject(mockPayload);
//         });

//         it('不正なシークレットキーや改ざんされたトークンは検証失敗（null または例外）になること', async () => {
//             const token = await signJwt(mockPayload, secret);
//             const wrongSecret = 'wrong-secret-key-32-chars-xxxxxx';

//             // 異なるシークレットキーでの検証失敗
//             const decodedWithWrongSecret = await verifyJwt(token, wrongSecret);
//             expect(decodedWithWrongSecret).toBeNull();

//             // 改ざんされたトークンでの検証失敗
//             const tamperedToken = token + 'invalid';
//             const decodedTampered = await verifyJwt(tamperedToken, secret);
//             expect(decodedTampered).toBeNull();
//         });
//     });
// });
