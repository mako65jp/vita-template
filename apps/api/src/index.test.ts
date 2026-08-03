import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import app from './index';
import { validateEnv } from './env';

describe('API Server Integration Tests', () => {
    it('正しい環境変数がセットされている場合、アプリが正常にルーティング応答すること', async () => {
        // 静的にインポートした app をそのまま利用できます
        const res = await app.request('/sample');
        expect(res.status).toBe(200);

        const body = await res.json();
        expect(body).toEqual({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
    });
});

describe('Environment Variable Validation', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    it('DATABASE_URL が存在しない場合、検証関数が例外をスローすること', () => {
        delete process.env.DATABASE_URL;

        // モジュールの再読み込みではなく、純粋な関数として例外発生を検証
        expect(() => {
            validateEnv(process.env);
        }).toThrow('環境変数の検証に失敗しました');
    });

    it('必要な環境変数が揃っている場合、正常にオブジェクトが返ること', () => {
        const mockEnv = {
            DATABASE_URL: 'postgresql://postgres:postgres@localhost:5432/app_db',
            PORT: '3001',
        };

        expect(() => validateEnv(mockEnv)).not.toThrow();
    });
});

describe('API Error Handling (RFC 7807)', () => {
    it('未定義のルートにアクセスした場合、404エラーがRFC7807形式で返ること', async () => {
        const res = await app.request('/api/non-existent-route');
        expect(res.status).toBe(404);

        const body = await res.json();
        expect(body).toEqual({
            type: 'https://api.example.com/errors/not-found',
            title: 'Not Found',
            status: 404,
            detail: 'The requested resource was not found',
            instance: '/api/non-existent-route',
        });
    });

    it('意図しないサーバー内部エラーが発生した場合、500エラーが共通形式で返ること', async () => {
        const res = await app.request('/test/error');
        expect(res.status).toBe(500);

        const body = await res.json();
        expect(body).toEqual({
            type: 'https://api.example.com/errors/internal-server-error',
            title: 'Internal Server Error',
            status: 500,
            detail: 'An unexpected error occurred',
            instance: '/test/error',
        });
    });
});

describe('Zod Request Validation (Step 2)', () => {
    it('リクエストBodyが不正な場合、400エラーと詳細なフィールドエラー情報がRFC7807形式で返ること', async () => {
        // 必須項目（email）が欠落しており、name が短すぎる不正なリクエストデータ
        const invalidPayload = {
            name: 'a', // 最低2文字以上必要とする仕様
        };

        const res = await app.request('/test/validation', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(invalidPayload),
        });

        expect(res.status).toBe(400);

        const body = await res.json();
        expect(body).toMatchObject({
            type: 'https://api.example.com/errors/validation-error',
            title: 'Bad Request',
            status: 400,
            detail: 'Validation failed for the request payload',
            instance: '/test/validation',
        });

        // フィールドごとのエラー詳細が含まれているか検証
        expect(body.invalidParams).toEqual(
            expect.arrayContaining([
                expect.objectContaining({ name: 'name' }),
                expect.objectContaining({ name: 'email' }),
            ])
        );
    });
});
