import { useAuth } from '@apps/web/react/src/app/providers/AuthProvider';

export function DashboardPage() {
    const auth = useAuth();

    // 簡易的なデータ定義
    const stats = [
        { label: '総ユーザー数', value: '1,280 人', change: '+4.75%', isPositive: true },
        { label: '本日の売上', value: '¥48,500', change: '+10.2%', isPositive: true },
        { label: 'システム稼働率', value: '99.98%', change: '-0.02%', isPositive: false },
    ];

    return (
        <div className="flex flex-col gap-8">
            {/* 上部ヘッダー */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900 tracking-tight">ダッシュボード</h1>
                <p className="text-sm text-gray-500 mt-1">
                    システムの状況と主要なインサイトを一覧で確認できます。
                </p>
            </div>

            {/* 統計カードエリア */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {stats.map((stat, index) => (
                    <div
                        key={index}
                        className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm flex flex-col gap-2"
                    >
                        <span className="text-sm font-semibold text-gray-500">{stat.label}</span>
                        <div className="flex items-baseline justify-between">
                            <span className="text-2xl font-bold text-gray-900">{stat.value}</span>
                            <span
                                className={`text-xs font-bold px-2 py-1 rounded-sm ${
                                    stat.isPositive
                                        ? 'bg-green-50 text-green-700'
                                        : 'bg-red-50 text-red-700'
                                }`}
                            >
                                {stat.change}
                            </span>
                        </div>
                    </div>
                ))}
            </div>

            {/* メインコンテンツエリア */}
            <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                <h3 className="text-base font-bold text-gray-900 mb-4">最近のアクティビティ</h3>
                <div className="border-t border-gray-100 divide-y divide-gray-100">
                    <div className="py-3.5 flex justify-between text-sm">
                        <span className="text-gray-700">システム設定が更新されました</span>
                        <span className="text-gray-400">10分前</span>
                    </div>
                    <div className="py-3.5 flex justify-between text-sm">
                        <span className="text-gray-700">新規ユーザーが登録されました</span>
                        <span className="text-gray-400">1時間前</span>
                    </div>
                </div>
            </div>
        </div>
    );
}
