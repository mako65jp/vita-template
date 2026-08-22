import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { clientEnvSchema, serverEnvSchema, formatEnvForLog, ServerEnv, ClientEnv } from './env';

// 💡 テスト専用の検証用ヘルパー関数
function parseServerEnv(targetEnv: Record<string, string | undefined>): ServerEnv {
    const result = serverEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        throw new Error(`[Server] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

function parseClientEnv(targetEnv: Record<string, string | undefined>): ClientEnv {
    const result = clientEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        throw new Error(`[Client] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

describe('shared/core/src/config/env', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    // テストで使用する最小限の有効な環境変数セット
    const validMockServerEnv = {
        DATABASE_URL: 'postgresql://user:pass@localhost:5432/mydb',
        TEST_DATABASE_URL: 'postgresql://user:pass@localhost:5432/mydb_test',
        JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
        CORS_ORIGIN: 'http://localhost:3000',
    };

    describe('serverEnvSchema', () => {
        it('必須のサーバー環境変数が揃っている場合、デフォルト値および動的補完値を含めて正しく検証できること', () => {
            const result = parseServerEnv(validMockServerEnv);

            // デフォルト値の検証
            expect(result.NODE_ENV).toBe('development');
            expect(result.PORT).toBe(3001);

            // PORT(3001) からの動的補完 URL の検証
            expect(result.API_BASE_URL).toBe('http://localhost:3001');
        });

        it('PORT を変更した場合、API_BASE_URL にポート番号が動的に反映されること', () => {
            const customEnv = {
                ...validMockServerEnv,
                PORT: '4000',
            };

            const result = parseServerEnv(customEnv);

            expect(result.PORT).toBe(4000);
            expect(result.API_BASE_URL).toBe('http://localhost:4000');
        });

        it('API_BASE_URL が明示的に指定されている場合、自動補完より優先されること', () => {
            const customEnv = {
                ...validMockServerEnv,
                PORT: '5000',
                API_BASE_URL: 'https://api.example.com',
            };

            const result = parseServerEnv(customEnv);

            expect(result.API_BASE_URL).toBe('https://api.example.com');
        });

        it('PORT に文字列の数値が渡された場合、number 型に変換されること', () => {
            const customEnv = {
                ...validMockServerEnv,
                PORT: '8080',
            };

            const result = parseServerEnv(customEnv);

            expect(result.PORT).toBe(8080);
            expect(typeof result.PORT).toBe('number');
        });

        it('DATABASE_URL が無効な URL の場合、例外がスローされること', () => {
            const invalidEnv = {
                ...validMockServerEnv,
                DATABASE_URL: 'invalid-url-format',
            };

            expect(() => parseServerEnv(invalidEnv)).toThrow('[Server] 環境変数の検証に失敗しました');
        });

        it('JWT_SECRET が 32 文字未満の場合、例外がスローされること', () => {
            const invalidEnv = {
                ...validMockServerEnv,
                JWT_SECRET: 'short-secret', // 32文字未満
            };

            expect(() => parseServerEnv(invalidEnv)).toThrow('[Server] 環境変数の検証に失敗しました');
        });
    });

    describe('clientEnvSchema', () => {
        it('デフォルト値および PORT に応じた VITE_API_TARGET_URL の補完が正しく機能すること', () => {
            const result = parseClientEnv({});

            expect(result.VITE_PORT).toBe(3000);
            expect(result.VITE_APP_TITLE).toBe('My App');
            expect(result.VITE_API_TARGET_URL).toBe('http://127.0.0.1:3001');
        });

        it('PORT を指定した場合、VITE_API_TARGET_URL のポートに正しく反映されること', () => {
            const result = parseClientEnv({ PORT: '4000' });

            expect(result.VITE_API_TARGET_URL).toBe('http://127.0.0.1:4000');
        });

        it('VITE_API_TARGET_URL が明示的に指定されている場合、自動補完より優先されること', () => {
            const result = parseClientEnv({
                PORT: '5000',
                VITE_API_TARGET_URL: 'https://proxy.example.com',
            });

            expect(result.VITE_API_TARGET_URL).toBe('https://proxy.example.com');
        });

        it('VITE_PORT に文字列の数値が渡された場合、number 型に変換されること', () => {
            const result = parseClientEnv({ VITE_PORT: '8081' });

            expect(result.VITE_PORT).toBe(8081);
            expect(typeof result.VITE_PORT).toBe('number');
        });
    });

    describe('formatEnvForLog', () => {
        it('DATABASE_URL や JWT_SECRET などの機密情報がマスクされること', () => {
            const mockParsedServerEnv: ServerEnv = {
                NODE_ENV: 'development',
                PORT: 3001,
                API_BASE_URL: 'http://localhost:3001',
                CORS_ORIGIN: 'http://localhost:3000',
                DATABASE_URL: 'postgresql://postgres:my-secret-password@localhost:5432/app_db',
                TEST_DATABASE_URL: 'postgresql://postgres:test-password@localhost:5432/app_db_test',
                JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
            };

            const formatted = formatEnvForLog(mockParsedServerEnv);

            // マスクされているかの検証
            expect(formatted).not.toContain('my-secret-password');
            expect(formatted).not.toContain('test-password');
            expect(formatted).not.toContain('super-secret-jwt-key-with-at-least-32-chars!');

            expect(formatted).toContain('postgresql://postgres:***@localhost:5432/app_db');
            expect(formatted).toContain('postgresql://postgres:***@localhost:5432/app_db_test');
            expect(formatted).toContain('"JWT_SECRET": "***"');
        });
    });
});
