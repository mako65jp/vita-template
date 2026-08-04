import { renderHook, act, waitFor } from '@testing-library/react';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { AuthProvider, useAuth } from './AuthContext';
import React from 'react';

// fetch のモック設定
const globalFetch = vi.fn();
global.fetch = globalFetch;

describe('AuthContext / useAuth (Step 5.1)', () => {
    beforeEach(() => {
        localStorage.clear();
        vi.clearAllMocks();
    });

    const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
    );

    it('初期状態では未認証であり、localStorage にトークンがなければユーザーは null であること', async () => {
        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isLoading).toBe(false);
        });

        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
    });

    it('login 関数を実行すると API を呼び出し、トークンとユーザー情報を保存すること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        const mockToken = 'mock-jwt-token';

        // ログイン API のレスポンスをモック
        globalFetch.mockResolvedValueOnce({
            ok: true,
            status: 200,
            json: async () => ({ token: mockToken, user: mockUser }),
        });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await act(async () => {
            await result.current.login('test@example.com', 'password123');
        });

        expect(globalFetch).toHaveBeenCalledWith(
            '/api/auth/login',
            expect.objectContaining({
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: 'test@example.com', password: 'password123' }),
            })
        );

        expect(localStorage.getItem('token')).toBe(mockToken);
        expect(result.current.isAuthenticated).toBe(true);
        expect(result.current.user).toEqual(mockUser);
    });

    it('logout 関数を実行するとトークンとユーザー情報が破棄されること', async () => {
        localStorage.setItem('token', 'existing-token');

        // /me API の初期化レスポンスをモック
        globalFetch.mockResolvedValueOnce({
            ok: true,
            status: 200,
            json: async () => ({ user: { id: 1, email: 'test@example.com', role: 'user' } }),
        });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isAuthenticated).toBe(true);
        });

        act(() => {
            result.current.logout();
        });

        expect(localStorage.getItem('token')).toBeNull();
        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
    });
});
