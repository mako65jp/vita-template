import { Link, Outlet, useNavigate } from 'react-router-dom';

export function Layout() {
    const navigate = useNavigate();

    const handleLogout = () => {
        // TODO: 実際のログアウトAPI（Hono）との連携処理をここに記述

        navigate('/login');
    };

    return (
        <div className="flex h-screen w-screen overflow-hidden bg-gray-50">
            {/* 左側：サイドバーメニュー */}
            <aside className="w-64 bg-white border-r border-gray-200 flex flex-col justify-between">
                {/* 上部メニューエリア */}
                <div className="p-6">
                    <div className="flex items-center gap-2 mb-8">
                        <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center text-white font-bold text-lg">
                            M
                        </div>
                        <h2 className="text-xl font-bold text-gray-800 tracking-tight">
                            マイアプリ
                        </h2>
                    </div>

                    <nav className="flex flex-col gap-1">
                        <Link
                            to="/"
                            className="flex items-center gap-3 px-4 py-3 text-gray-700 hover:bg-gray-100 rounded-xl transition-colors font-medium"
                        >
                            <span className="text-lg">🏠</span>
                            <span>ホーム</span>
                        </Link>
                        <Link
                            to="/settings"
                            className="flex items-center gap-3 px-4 py-3 text-gray-700 hover:bg-gray-100 rounded-xl transition-colors font-medium"
                        >
                            <span className="text-lg">⚙️</span>
                            <span>設定</span>
                        </Link>
                    </nav>
                </div>

                {/* 下部ユーザー・アクションエリア */}
                <div className="p-6 border-t border-gray-100">
                    <button
                        onClick={handleLogout}
                        className="w-full bg-red-50 hover:bg-red-100 text-red-600 font-semibold py-3 px-4 rounded-xl transition-colors text-center text-sm"
                    >
                        ログアウト
                    </button>
                </div>
            </aside>

            {/* 右側：メインコンテンツ表示エリア */}
            <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
                {/* 必要に応じてここに共通ヘッダー（パンくずリストなど）を配置可能 */}

                {/* 下位ルート（ホームや設定画面）の中身がここに動的にはめ込まれます */}
                <div className="flex-1 p-8 overflow-y-auto">
                    <Outlet />
                </div>
            </main>
        </div>
    );
}
