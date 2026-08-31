import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import React from 'react';
import { App } from './App';
import { PluginRegistry } from '@shared/client';

// useAuth のモック設定
const mockUseAuth = vi.fn();

vi.mock('./context/AuthContext', () => ({
    AuthProvider: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
    useAuth: () => mockUseAuth(),
}));

// ProtectedRoute のモック（認証チェックをスルー）
vi.mock('./components/ProtectedRoute', () => ({
    ProtectedRoute: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
}));

// UserManagementTable のモック（配列の `.map()` エラーを防ぐため、安全な描画を行う）
vi.mock('@features/user-management/src/ui', () => ({
    UserManagementTable: () => <div data-testid="user-management-table">ユーザー管理テーブル画面</div>,
    registerUserManagementPlugin: vi.fn(),
}));

// @shared/client（環境変数やトースト関連）の部分モック
vi.mock('@shared/client', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@shared/client')>();
    return {
        ...actual,
        clientEnv: {
            ...actual.clientEnv,
            VITE_APP_TITLE: 'テストアプリ',
        },
        toast: {
            success: vi.fn(),
        },
        showErrorToast: vi.fn(),
    };
});

// グローバル fetch のモック
const globalFetch = vi.fn();
(globalThis as any).fetch = globalFetch;

describe('App Component Integration Tests', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        PluginRegistry.clear();

        // ユーザー管理プラグインの初期登録
        PluginRegistry.register({
            id: 'user-management',
            name: 'ユーザー管理',
            navItems: [
                {
                    id: 'users',
                    label: 'ユーザー管理',
                    path: '#users',
                    roles: ['admin'],
                },
            ],
        });

        // デフォルトの fetch 成功レスポンスを設定
        globalFetch.mockResolvedValue({
            ok: true,
            json: async () => [],
        });
    });

    afterEach(() => {
        cleanup();
    });

    it('初期表示としてダッシュボードとタイトルが正しくレンダリングされること', () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'test@example.com', role: 'user' },
            logout: vi.fn(),
        });

        render(<App />);

        // 初期表示でダッシュボードの見出しが存在すること
        expect(screen.getByText('テストアプリ')).toBeDefined();
        expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();
        expect(screen.getByText('test@example.com')).toBeDefined();
    });

    it('admin ユーザーの場合、サイドナビに「ユーザー管理」が表示され、クリックすると管理画面に切り替わること', async () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: vi.fn(),
        });

        render(<App />);

        // 描画時点でレジストリが登録されているため、同期的に getByRole でナビゲーション要素が取得できる
        const userMgmtNav = screen.getByRole('link', { name: 'ユーザー管理' });
        expect(userMgmtNav).toBeDefined();

        // クリックしてユーザー管理画面を表示
        fireEvent.click(userMgmtNav);

        // 画面切り替えの確認
        await waitFor(() => {
            expect(screen.getByTestId('user-management-table')).toBeDefined();
        });
    });

    it('一般ユーザー（user）の場合、サイドナビに「ユーザー管理」が表示されないこと', () => {
        mockUseAuth.mockReturnValue({
            user: { id: 2, email: 'user@example.com', role: 'user' },
            logout: vi.fn(),
        });

        render(<App />);

        expect(screen.queryByRole('link', { name: 'ユーザー管理' })).toBeNull();
    });

    it('「403 権限エラー画面を表示」ボタンを押すとForbiddenPageに切り替わり、「ダッシュボードへ戻る」で復帰すること', async () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: vi.fn(),
        });

        render(<App />);

        // 403画面へ遷移するボタンを押下
        const forbiddenButton = screen.getByRole('button', { name: '403 権限エラー画面を表示' });
        fireEvent.click(forbiddenButton);

        // 403画面が表示されていることの確認
        await waitFor(() => {
            expect(screen.getByText('403')).toBeDefined();
        });

        // 「ダッシュボードへ戻る」ボタンを押下
        const backButton = screen.getByRole('button', { name: 'ダッシュボードへ戻る' });
        fireEvent.click(backButton);

        // ダッシュボードの見出しが再び表示されていること
        await waitFor(() => {
            expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();
        });
    });

    it('ログアウトボタンを押すと logout 関数が呼び出されること', () => {
        const handleLogout = vi.fn();
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: handleLogout,
        });

        render(<App />);

        const logoutButton = screen.getByRole('button', { name: 'ログアウト' });
        fireEvent.click(logoutButton);

        expect(handleLogout).toHaveBeenCalledTimes(1);
    });
});

