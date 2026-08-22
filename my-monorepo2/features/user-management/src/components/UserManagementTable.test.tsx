import React from 'react';
import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { UserManagementTable } from './UserManagementTable';

// @shared/client のモック
vi.mock('@shared/client', () => ({
    toast: {
        success: vi.fn(),
        error: vi.fn(),
    },
    showErrorToast: vi.fn(),
    AUTH_TOKEN_KEY: 'test-auth-token',
}));

const globalFetch = vi.fn();
global.fetch = globalFetch;

describe('UserManagementTable Component', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    afterEach(() => {
        cleanup();
    });

    it('初期ロード時にユーザー一覧が取得され、正常に描画されること', async () => {
        const mockUsers = [
            {
                id: 1,
                name: 'テスト太郎',
                email: 'taro@example.com',
                role: 'user',
                isActive: true,
                createdAt: '2026-08-12T00:00:00Z',
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        expect(screen.getByText('読み込み中...')).toBeInTheDocument();

        await waitFor(() => {
            expect(screen.getByText('テスト太郎')).toBeInTheDocument();
            expect(screen.getByText('taro@example.com')).toBeInTheDocument();
            expect(screen.getByText('有効')).toBeInTheDocument();
            expect(screen.getByRole('button', { name: '無効化する' })).toBeInTheDocument();
        });
    });

    it('ステータストグルボタンをクリックした際、PATCH リクエストが送信され表示が切り替わること', async () => {
        const mockUsers = [
            {
                id: 1,
                name: 'テスト太郎',
                email: 'taro@example.com',
                role: 'user',
                isActive: true,
                createdAt: '2026-08-12T00:00:00Z',
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByText('テスト太郎')).toBeInTheDocument();
        });

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                user: { ...mockUsers[0], isActive: false },
            }),
        });

        const toggleButton = screen.getByRole('button', { name: '無効化する' });
        fireEvent.click(toggleButton);

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management/1/status',
                expect.objectContaining({
                    method: 'PATCH',
                    body: JSON.stringify({ isActive: false }),
                })
            );
        });

        await waitFor(() => {
            expect(screen.getByText('無効')).toBeInTheDocument();
            expect(screen.getByRole('button', { name: '有効化する' })).toBeInTheDocument();
        });
    });

    it('ロール変更セレクトを変更した際、PATCH リクエストが送信され表示が切り替わること', async () => {
        const mockUsers = [
            {
                id: 1,
                name: 'テスト太郎',
                email: 'taro@example.com',
                role: 'user' as const,
                isActive: true,
                createdAt: '2026-08-12T00:00:00Z',
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByText('テスト太郎')).toBeInTheDocument();
        });

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                user: { ...mockUsers[0], role: 'admin' },
            }),
        });

        const selectEl = screen.getByRole('combobox');
        fireEvent.change(selectEl, { target: { value: 'admin' } });

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management/1/role',
                expect.objectContaining({
                    method: 'PATCH',
                    body: JSON.stringify({ role: 'admin' }),
                })
            );
        });

        await waitFor(() => {
            expect((selectEl as HTMLSelectElement).value).toBe('admin');
        });
    });

    it('「＋ ユーザー追加」ボタンでモーダルが開き、パスワードを指定して新規ユーザーをPOST登録できること', async () => {
        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: [] }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByRole('button', { name: '＋ ユーザー追加' })).toBeInTheDocument();
        });

        fireEvent.click(screen.getByRole('button', { name: '＋ ユーザー追加' }));

        expect(screen.getByText('新規ユーザー追加')).toBeInTheDocument();

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                user: { id: 2, name: '新規ユーザー', email: 'new@example.com', role: 'user', isActive: true },
                initialPassword: 'password123',
            }),
        });

        fireEvent.change(screen.getByPlaceholderText('山田 太郎'), { target: { value: '新規ユーザー' } });
        fireEvent.change(screen.getByPlaceholderText('user@example.com'), { target: { value: 'new@example.com' } });
        fireEvent.change(screen.getByPlaceholderText('8文字以上（空欄可）'), { target: { value: 'password123' } });

        fireEvent.click(screen.getByRole('button', { name: '追加する' }));

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management',
                expect.objectContaining({
                    method: 'POST',
                    body: JSON.stringify({
                        name: '新規ユーザー',
                        email: 'new@example.com',
                        role: 'user',
                        password: 'password123',
                    }),
                })
            );
        });

        await waitFor(() => {
            expect(screen.getByText('新規ユーザー')).toBeInTheDocument();
        });
    });

    it('削除ボタンをクリックした際、DELETE リクエストが送信され一覧から除外されること', async () => {
        vi.spyOn(window, 'confirm').mockReturnValue(true);

        const mockUsers = [
            {
                id: 1,
                name: '削除対象ユーザー',
                email: 'delete@example.com',
                role: 'user' as const,
                isActive: true,
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByText('削除対象ユーザー')).toBeInTheDocument();
        });

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ message: 'ユーザーを削除しました' }),
        });

        fireEvent.click(screen.getByRole('button', { name: '削除' }));

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management/1',
                expect.objectContaining({ method: 'DELETE' })
            );
        });

        await waitFor(() => {
            expect(screen.queryByText('削除対象ユーザー')).toBeNull();
        });
    });
});
