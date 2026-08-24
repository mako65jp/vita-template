import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ProtectedRoute } from './ProtectedRoute';
import * as AuthContextModule from '../context/AuthContext';

vi.mock('../context/AuthContext');

describe('ProtectedRoute', () => {
    it('ローディング中はローディングメッセージを表示する', () => {
        vi.spyOn(AuthContextModule, 'useAuth').mockReturnValue({
            user: null,
            token: null,
            isLoading: true,
            isAuthenticated: false,
            login: vi.fn(),
            logout: vi.fn(),
        });

        render(
            <ProtectedRoute>
                <div>Protected Content</div>
            </ProtectedRoute>
        );

        expect(screen.getByText('認証情報を確認中...')).toBeInTheDocument();
        expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });

    it('未認証の場合はログインフォームを表示する', () => {
        vi.spyOn(AuthContextModule, 'useAuth').mockReturnValue({
            user: null,
            token: null,
            isLoading: false,
            isAuthenticated: false,
            login: vi.fn(),
            logout: vi.fn(),
        });

        render(
            <ProtectedRoute>
                <div>Protected Content</div>
            </ProtectedRoute>
        );

        expect(screen.getByRole('button', { name: /ログイン/i })).toBeInTheDocument();
        expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });

    it('認証済みの場合は子要素を表示する', () => {
        vi.spyOn(AuthContextModule, 'useAuth').mockReturnValue({
            user: { id: 1, email: 'user@example.com', role: 'user' },
            token: 'valid-token',
            isLoading: false,
            isAuthenticated: true,
            login: vi.fn(),
            logout: vi.fn(),
        });

        render(
            <ProtectedRoute>
                <div>Protected Content</div>
            </ProtectedRoute>
        );

        expect(screen.getByText('Protected Content')).toBeInTheDocument();
    });
});
