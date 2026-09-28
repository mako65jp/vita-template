import { Link, Outlet, useNavigate } from 'react-router-dom';
import { menus } from '../app/features';
import { useAuth } from '../app/providers/AuthProvider';

export function Layout() {
    const navigate = useNavigate();
    const auth = useAuth();

    const handleLogout = () => {
        auth.signOut();
        navigate('/login', {
            replace: true,
        });
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
                        {menus.map((menu) => (
                            <Link
                                key={menu.id}
                                to={menu.menu!.path}
                                className="flex items-center gap-3 px-4 py-3 text-gray-700 hover:bg-gray-100 rounded-xl transition-colors font-medium"
                            >
                                {menu.menu!.title}
                            </Link>
                        ))}
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
