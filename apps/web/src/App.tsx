import React, { useState } from 'react';
import { AppLayout, HeaderContent, SidebarNav, Button, Toaster, toast, showErrorToast } from '@app/ui';
import { clientEnv } from '@app/core/config/env';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { UserManagementTable } from '@app/features-user-management/ui';
import { ForbiddenPage } from './components/ForbiddenPage';

const DashboardContent: React.FC = () => {
    const { user, logout } = useAuth();
    const [currentTab, setCurrentTab] = useState<'dashboard' | 'users' | 'forbidden'>('dashboard');

    const navItems = [
        {
            label: 'ダッシュボード',
            href: '#',
            active: currentTab === 'dashboard',
            onClick: (e: React.MouseEvent) => {
                e.preventDefault();
                setCurrentTab('dashboard');
            },
        },
        ...(user?.role === 'admin'
            ? [
                {
                    label: 'ユーザー管理',
                    href: '#',
                    active: currentTab === 'users',
                    onClick: (e: React.MouseEvent) => {
                        e.preventDefault();
                        setCurrentTab('users');
                    },
                },
            ]
            : []),
        { label: 'プロジェクト一覧', href: '#' },
        { label: '設定', href: '#' },
    ];

    const handleSuccessToast = () => {
        toast.success('処理が完了しました', {
            description: 'データが正常に保存されました。',
        });
    };

    const handleRfcErrorToast = () => {
        const mockRfc9457Error = {
            type: 'https://example.com/errors/invalid-params',
            title: '入力項目に不備があります',
            status: 400,
            detail: 'メールアドレスの形式が正しくありません。',
            instance: '/api/v1/users',
        };

        showErrorToast(mockRfc9457Error);
    };

    const handleTriggerForbidden = () => {
        // 403 権限エラー発生時の画面テスト用動作
        setCurrentTab('forbidden');
    };

    return (
        <AppLayout
            header={
                <HeaderContent title={clientEnv.VITE_APP_TITLE}>
                    <div className="flex items-center gap-4 text-sm">
                        <span className="text-gray-600">
                            <span className="font-semibold text-gray-900">{user?.email}</span> ({user?.role})
                        </span>
                        <Button variant="outline" size="sm" onClick={logout}>
                            ログアウト
                        </Button>
                    </div>
                </HeaderContent>
            }
            sidebar={<SidebarNav items={navItems} />}
        >
            <div className="flex flex-col gap-6">
                {currentTab === 'dashboard' && (
                    <div className="flex flex-col gap-4">
                        <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
                            <h2 className="text-lg font-semibold text-gray-900 mb-2">ダッシュボード</h2>
                            <p className="text-sm text-gray-600">
                                システム概要や各種機能へのショートカットをここに表示します。
                            </p>
                        </div>

                        <div className="rounded-lg border border-dashed border-gray-300 p-4">
                            <p className="text-xs font-semibold text-gray-500 mb-2">UI 動作確認 (Debug)</p>
                            <div className="flex gap-2">
                                <Button variant="default" size="sm" onClick={handleSuccessToast}>
                                    成功 Toast を表示
                                </Button>
                                <Button variant="destructive" size="sm" onClick={handleRfcErrorToast}>
                                    RFC 9457 エラー Toast を表示
                                </Button>
                                <Button variant="outline" size="sm" onClick={handleTriggerForbidden}>
                                    403 権限エラー画面を表示
                                </Button>
                            </div>
                        </div>
                    </div>
                )}

                {currentTab === 'users' && user?.role === 'admin' && (
                    <UserManagementTable apiBaseUrl="/api/user-management" />
                )}

                {currentTab === 'forbidden' && (
                    <ForbiddenPage onBackToDashboard={() => setCurrentTab('dashboard')} />
                )}
            </div>
        </AppLayout>
    );
};

export function App() {
    return (
        <AuthProvider>
            <Toaster />
            <ProtectedRoute>
                <DashboardContent />
            </ProtectedRoute>
        </AuthProvider>
    );
}

export default App;
