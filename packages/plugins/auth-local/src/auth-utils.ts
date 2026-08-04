import bcrypt from 'bcryptjs';
import { SignJWT, jwtVerify } from 'jose';

// ----------------------------------------------------
// 1. パスワードハッシュ化 & 照合処理
// ----------------------------------------------------

/**
 * 平文パスワードをハッシュ化します
 */
export async function hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
}

/**
 * 平文パスワードとハッシュ値を照合します
 */
export async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
}

// ----------------------------------------------------
// 2. JWT 発行 & 検証処理
// ----------------------------------------------------

/**
 * Payload を受け取り、署名済み JWT を生成します
 */
export async function signJwt(
    payload: Record<string, unknown>,
    secret: string,
    expiresIn: string = '2h'
): Promise<string> {
    const secretKey = new TextEncoder().encode(secret);

    return await new SignJWT(payload)
        .setProtectedHeader({ alg: 'HS256' })
        .setIssuedAt()
        .setExpirationTime(expiresIn)
        .sign(secretKey);
}

/**
 * JWT を検証し、デコードされた Payload を返します。
 * 不正または改ざんされたトークンの場合は null を返します。
 */
export async function verifyJwt<T = Record<string, unknown>>(
    token: string,
    secret: string
): Promise<T | null> {
    try {
        const secretKey = new TextEncoder().encode(secret);
        const { payload } = await jwtVerify(token, secretKey);
        return payload as T;
    } catch {
        // トークンが不正、改ざんされている、または有効期限切れの場合
        return null;
    }
}
