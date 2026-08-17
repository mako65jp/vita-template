import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import React from 'react';
import { App } from './App';

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

// UserManagementTable のモック化（インポート元パスを App.tsx と一致させる）
vi.mock('@app/features-user-management/ui', () => ({
    UserManagementTable: () => <div data-testid="user-management-table">ユーザー管理テーブル画面</div>,
}));

// @app/core/config/env の部分モック
vi.mock('@app/core/config/env', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@app/core/config/env')>();
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
global.fetch = globalFetch;

describe('App Component (User Management Integration)', () => {
    beforeEach(() => {
        vi.clearAllMocks();
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

        // ダッシュボード見出し（h2）の初期表示確認
        expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();

        // admin のためサイドナビに「ユーザー管理」リンクが存在すること
        const userMgmtNav = screen.getByRole('link', { name: 'ユーザー管理' });
        expect(userMgmtNav).toBeDefined();

        // クリックしてユーザー管理画面を表示
        fireEvent.click(userMgmtNav);

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

        expect(screen.queryByRole('link', { name: 'ユーザー管理' })).toBeNull();
    });
});


// import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
// import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
// import React from 'react';
// import { App } from './App';

// // useAuth のモック設定
// const mockUseAuth = vi.fn();

// vi.mock('./context/AuthContext', () => ({
//     AuthProvider: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
//     useAuth: () => mockUseAuth(),
// }));

// // ProtectedRoute のモック（認証チェックをスルー）
// vi.mock('./components/ProtectedRoute', () => ({
//     ProtectedRoute: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
// }));

// // UserManagementTable のモック化（表示確認用）
// vi.mock('@app/features/user-management', () => ({
//     UserManagementTable: () => <div data-testid="user-management-table">ユーザー管理テーブル画面</div>,
// }));

// // @app/core/config/env の部分モック
// vi.mock('@app/core/config/env', async (importOriginal) => {
//     const actual = await importOriginal<typeof import('@app/core/config/env')>();
//     return {
//         ...actual,
//         clientEnv: {
//             ...actual.clientEnv,
//             VITE_APP_TITLE: 'テストアプリ',
//         },
//     };
// });

// // fetch のモック
// const globalFetch = vi.fn();
// global.fetch = globalFetch;

// describe('App Component (User Management Integration)', () => {
//     beforeEach(() => {
//         vi.clearAllMocks();
//     });

//     afterEach(() => {
//         cleanup();
//     });

//     it('admin ユーザーの場合、サイドナビに「ユーザー管理」が表示され、クリックすると管理画面に切り替わること', async () => {
//         mockUseAuth.mockReturnValue({
//             user: { id: 1, email: 'admin@example.com', role: 'admin' },
//             logout: vi.fn(),
//         });

//         render(<App />);

//         // ダッシュボード見出し（h2）の初期表示確認
//         expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();

//         // admin のためサイドナビに「ユーザー管理」リンクが存在すること
//         const userMgmtNav = screen.getByRole('link', { name: 'ユーザー管理' });
//         expect(userMgmtNav).toBeDefined();

//         // クリックしてユーザー管理画面を表示
//         fireEvent.click(userMgmtNav);

//         await waitFor(() => {
//             expect(screen.getByTestId('user-management-table')).toBeDefined();
//         });
//     });

//     it('user（一般権限）ユーザーの場合、サイドナビに「ユーザー管理」が表示されないこと', () => {
//         mockUseAuth.mockReturnValue({
//             user: { id: 2, email: 'user@example.com', role: 'user' },
//             logout: vi.fn(),
//         });

//         render(<App />);

//         expect(screen.queryByRole('link', { name: 'ユーザー管理' })).toBeNull();
//     });
// });
