// apps/web/src/lib/apiClient.test.ts
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { apiClient, ApiError } from "./apiClient";
import { AUTH_TOKEN_KEY } from '@app/core';

describe("apiClient (API クライアント)", () => {
    const originalFetch = globalThis.fetch;

    beforeEach(() => {
        localStorage.clear();
        vi.restoreAllMocks();
    });

    afterEach(() => {
        globalThis.fetch = originalFetch;
    });

    it("正常系: リクエストヘッダーに Content-Type と Authorization トークンが正しく設定されること", async () => {
        localStorage.setItem(AUTH_TOKEN_KEY, "mock-jwt-token");

        const mockResponse = { id: "1", name: "テストユーザー" };
        (globalThis as any).fetch = vi.fn().mockResolvedValue({
            ok: true,
            headers: new Headers({ "content-type": "application/json" }),
            json: async () => mockResponse,
        });

        const data = await apiClient.get<{ id: string; name: string }>("/api/me");

        expect(data).toEqual(mockResponse);

        // fetch の呼出し引数を検証
        const [url, options] = ((globalThis as any).fetch as any).mock.calls[0];
        expect(url).toContain("/api/me");
        expect(options.method).toBe("GET");

        // Headers オブジェクトから取得して検証
        const headers = options.headers as Headers;
        expect(headers.get("Content-Type")).toBe("application/json");
        expect(headers.get("Authorization")).toBe("Bearer mock-jwt-token");
    });

    it("異常系: RFC 9457 エラーレスポンスを受け取った際、ApiError をスローすること", async () => {
        const problemJson = {
            type: "about:blank",
            title: "Bad Request",
            status: 400,
            detail: "入力内容が不正です",
            instance: "/api/test",
            invalidParams: [
                { name: "email", reason: "メールアドレスの形式が正しくありません" },
            ],
        };

        (globalThis as any).fetch = vi.fn().mockResolvedValue({
            ok: false,
            status: 400,
            headers: new Headers({ "content-type": "application/problem+json" }),
            json: async () => problemJson,
        });

        try {
            await apiClient.post("/api/test", { email: "invalid" });
            expect.fail("エラーが発生しませんでした");
        } catch (error) {
            expect(error).toBeInstanceOf(ApiError);
            const apiError = error as ApiError;
            expect(apiError.status).toBe(400);
            expect(apiError.title).toBe("Bad Request");
            expect(apiError.detail).toBe("入力内容が不正です");
            expect(apiError.invalidParams).toHaveLength(1);
        }
    });

    it("異常系: 401 Unauthorized 発生時にローカルストレージのトークンが削除されること", async () => {
        localStorage.setItem(AUTH_TOKEN_KEY, "expired-token");

        (globalThis as any).fetch = vi.fn().mockResolvedValue({
            ok: false,
            status: 401,
            headers: new Headers({ "content-type": "application/problem+json" }),
            json: async () => ({
                type: "about:blank",
                title: "Unauthorized",
                status: 401,
                detail: "認証期限が切れています",
            }),
        });

        await expect(apiClient.get("/api/protected")).rejects.toThrow(ApiError);
        expect(localStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
    });
});
