import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import React from 'react';
import { App } from './App';
import { PluginRegistry } from '@shared/functions';

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

// UserManagementTable のみモック化（PluginRegistryの登録はbeforeEachで行う）
vi.mock('@features-user-management/ui', () => ({
    UserManagementTable: () => <div data-testid="user-management-table">ユーザー管理テーブル画面</div>,
    registerUserManagementPlugin: vi.fn(),
}));

// @shared/env の部分モック
vi.mock('@shared/env', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@shared/client')>();
    return {
        ...actual,
        clientEnv: {
            ...actual.clientEnv,
            VITE_APP_TITLE: 'テストアプリ',
        },
    };
});

// fetch のモック
const globalFetch = vi.fn();
(globalThis as any).fetch = globalFetch;

describe('App Component (User Management Integration)', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        // 1. テストごとに PluginRegistry を初期化
        PluginRegistry.clear();

        // 2. アプリ起動前（エントリーポイント）にプラグインが登録された状態を模倣する
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
    });

    afterEach(() => {
        cleanup();
    });

    it('admin ユーザーの場合、サイドナビに「ユーザー管理」が表示され、クリックすると管理画面に切り替わること', async () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: vi.fn(),
        });

        render(<App />);

        // 初期表示でダッシュボードの見出しが存在すること
        expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();

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

    it('user（一般権限）ユーザーの場合、サイドナビに「ユーザー管理」が表示されないこと', () => {
        mockUseAuth.mockReturnValue({
            user: { id: 2, email: 'user@example.com', role: 'user' },
            logout: vi.fn(),
        });

        render(<App />);

        // role: 'user' の場合はメニューに表示されないこと
        expect(screen.queryByRole('link', { name: 'ユーザー管理' })).toBeNull();
    });
});
