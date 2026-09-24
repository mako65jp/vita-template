import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { Layout } from '../components/Layout';
import { LoginPage } from '../features/authentication/pages/LoginPage';
import { DashboardPage } from '../features/dashboard/pages/DashboardPage';
import { SettingsPage } from '../features/settings/pages/SettingsPage';
import { useAuth } from './providers/AuthProvider';

export function App() {
    const auth = useAuth();
    // accessToken が null でなければログイン済み（true）とみなす
    const isAuthenticated = !!auth.accessToken;

    return (
        <BrowserRouter>
            <Routes>
                {/* ログイン画面：認証済みならトップページへ、未認証ならログイン画面を表示 */}
                <Route
                    path="/login"
                    element={isAuthenticated ? <Navigate to="/" replace /> : <LoginPage />}
                />

                {/* 認証済みルート：Layoutを共通の枠組みとして使用 */}
                <Route
                    path="/"
                    element={isAuthenticated ? <Layout /> : <Navigate to="/login" replace />}
                >
                    {/* / にアクセスした時、デフォルトで右エリアに表示される画面 */}
                    <Route index element={<DashboardPage />} />

                    {/* /settings にアクセスした時に右エリアに表示される画面 */}
                    <Route path="settings" element={<SettingsPage />} />
                </Route>

                {/* 定義外のURLはすべてルートへ戻す */}
                <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
        </BrowserRouter>
    );
}
