import React from 'react';
import { AppLayout, HeaderContent, SidebarNav, Button, Toaster, toast, showErrorToast } from '@app/ui';
import { clientEnv } from '@app/core/config/env';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';

const DashboardContent: React.FC = () => {
  const { user, logout } = useAuth();

  const navItems = [
    { label: 'ダッシュボード', href: '#', active: true },
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

  return (
    <AppLayout
      header={<HeaderContent title={clientEnv.VITE_APP_TITLE} />}
      sidebar={<SidebarNav items={navItems} />}
    >
      <div className="flex flex-col gap-6">
        <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900 mb-2">ダッシュボード</h2>
          <p className="text-sm text-gray-600 mb-4">
            ログイン中: <span className="font-semibold text-gray-900">{user?.email}</span> (Role: {user?.role})
          </p>
          <div className="flex gap-2">
            <Button variant="outline" onClick={logout}>
              ログアウト
            </Button>
            <Button variant="default" onClick={handleSuccessToast}>
              成功 Toast を表示
            </Button>
            <Button variant="destructive" onClick={handleRfcErrorToast}>
              RFC 9457 エラー Toast を表示
            </Button>
          </div>
        </div>
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
