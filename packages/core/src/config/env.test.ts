import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { allEnvSchema, formatEnvForLog, AllEnv } from './env';

// 💡 テスト専用の検証用ヘルパー関数
function parseEnv(targetEnv: Record<string, string | undefined>) {
    const result = allEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        throw new Error(`環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

describe('packages/core/src/config/env', () => {

    const originalEnv = process.env;

    beforeEach(() => {
        // テストごとに process.env を分離・復元できるようにクローン
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    // テストで使用する最小限の有効な環境変数セット
    const validMockEnv = {
        DATABASE_URL: 'postgresql://user:pass@localhost:5432/mydb',
        TEST_DATABASE_URL: 'postgresql://user:pass@localhost:5432/mydb_test',
        JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
    };

    describe('allEnvSchema & validateAllEnv', () => {
        it('必須の環境変数が揃っている場合、デフォルト値および動的補完値を含めて正しく検証できること', () => {
            const result = parseEnv(validMockEnv);

            // デフォルト値の検証
            expect(result.NODE_ENV).toBe('development');
            expect(result.PORT).toBe(3001);
            expect(result.VITE_PORT).toBe(3000);
            expect(result.VITE_APP_TITLE).toBe('My App');

            // PORT(3001) からの動的補完 URL の検証
            expect(result.API_BASE_URL).toBe('http://localhost:3001');
            expect(result.VITE_API_TARGET_URL).toBe('http://127.0.0.1:3001');
        });

        it('PORT を変更した場合、API_BASE_URL と VITE_API_TARGET_URL にポート番号が動的に反映されること', () => {
            const customEnv = {
                ...validMockEnv,
                PORT: '4000',
            };

            const result = parseEnv(customEnv);

            expect(result.PORT).toBe(4000);
            expect(result.API_BASE_URL).toBe('http://localhost:4000');
            expect(result.VITE_API_TARGET_URL).toBe('http://127.0.0.1:4000');
        });

        it('API_BASE_URL や VITE_API_TARGET_URL が明示的に指定されている場合、自動補完より優先されること', () => {
            const customEnv = {
                ...validMockEnv,
                PORT: '5000',
                API_BASE_URL: 'https://api.example.com',
                VITE_API_TARGET_URL: 'https://proxy.example.com',
            };

            const result = parseEnv(customEnv);

            expect(result.API_BASE_URL).toBe('https://api.example.com');
            expect(result.VITE_API_TARGET_URL).toBe('https://proxy.example.com');
        });

        it('PORT や VITE_PORT に文字列の数値が渡された場合、number 型に変換されること', () => {
            const customEnv = {
                ...validMockEnv,
                PORT: '8080',
                VITE_PORT: '8081',
            };

            const result = parseEnv(customEnv);

            expect(result.PORT).toBe(8080);
            expect(typeof result.PORT).toBe('number');
            expect(result.VITE_PORT).toBe(8081);
            expect(typeof result.VITE_PORT).toBe('number');
        });

        it('DATABASE_URL が無効な URL の場合、例外がスローされること', () => {
            const invalidEnv = {
                ...validMockEnv,
                DATABASE_URL: 'invalid-url-format',
            };

            expect(() => parseEnv(invalidEnv)).toThrow('環境変数の検証に失敗しました');
        });

        it('JWT_SECRET が 32 文字未満の場合、例外がスローされること', () => {
            const invalidEnv = {
                ...validMockEnv,
                JWT_SECRET: 'short-secret', // 32文字未満
            };

            expect(() => parseEnv(invalidEnv)).toThrow('環境変数の検証に失敗しました');
        });
    });

    describe('formatEnvForLog', () => {
        it('DATABASE_URL や JWT_SECRET などの機密情報がマスクされること', () => {
            const mockParsedEnv: AllEnv = {
                NODE_ENV: 'development',
                PORT: 3001,
                API_BASE_URL: 'http://localhost:3001',
                DATABASE_URL: 'postgresql://postgres:my-secret-password@localhost:5432/app_db',
                TEST_DATABASE_URL: 'postgresql://postgres:test-password@localhost:5432/app_db_test',
                JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
                VITE_PORT: 3000,
                VITE_API_TARGET_URL: 'http://127.0.0.1:3001',
                VITE_APP_TITLE: 'My App',
            };

            const formatted = formatEnvForLog(mockParsedEnv as any);

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
