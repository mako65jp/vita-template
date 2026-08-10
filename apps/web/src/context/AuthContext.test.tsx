import { renderHook, act, waitFor } from '@testing-library/react';
import { describe, it, expect, beforeEach, vi, Mock } from 'vitest';
import { AuthProvider, useAuth } from './AuthContext';
import React from 'react';
import { apiClient, getStoredToken, setStoredToken, removeStoredToken } from '../lib/apiClient';

// apiClient のモック設定
vi.mock('../lib/apiClient', () => ({
    apiClient: {
        get: vi.fn(),
        post: vi.fn(),
    },
    getStoredToken: vi.fn(),
    setStoredToken: vi.fn(),
    removeStoredToken: vi.fn(),
}));

describe('AuthContext / useAuth (Step 7 修正版)', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
    );

    it('初期状態（トークンなし）: user/token 共に null で未認証状態であること', async () => {
        (getStoredToken as Mock).mockReturnValue(null);

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isLoading).toBe(false);
        });

        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
        expect(result.current.token).toBeNull();
    });

    it('初期状態（トークンあり）: /api/auth/me からユーザー情報を取得し認証状態を復元すること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        (getStoredToken as Mock).mockReturnValue('existing-token');
        (apiClient.get as Mock).mockResolvedValueOnce({ user: mockUser });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isLoading).toBe(false);
        });

        expect(apiClient.get).toHaveBeenCalledWith('/api/auth/me');
        expect(result.current.isAuthenticated).toBe(true);
        expect(result.current.user).toEqual(mockUser);
        expect(result.current.token).toBe('existing-token');
    });

    it('login: /api/auth/login を呼び出し、トークンとユーザー情報を保持すること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        const mockToken = 'mock-jwt-token';

        (apiClient.post as Mock).mockResolvedValueOnce({ token: mockToken, user: mockUser });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await act(async () => {
            await result.current.login('test@example.com', 'password123');
        });

        expect(apiClient.post).toHaveBeenCalledWith('/api/auth/login', {
            email: 'test@example.com',
            password: 'password123',
        });
        expect(setStoredToken).toHaveBeenCalledWith(mockToken);
        expect(result.current.isAuthenticated).toBe(true);
        expect(result.current.user).toEqual(mockUser);
        expect(result.current.token).toBe(mockToken);
    });

    it('logout: トークンとユーザー情報が破棄されること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        (getStoredToken as Mock).mockReturnValue('existing-token');
        (apiClient.get as Mock).mockResolvedValueOnce({ user: mockUser });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isAuthenticated).toBe(true);
        });

        act(() => {
            result.current.logout();
        });

        expect(removeStoredToken).toHaveBeenCalled();
        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
        expect(result.current.token).toBeNull();
    });
});
