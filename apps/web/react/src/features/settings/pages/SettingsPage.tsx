import { useState } from 'react';

export function SettingsPage() {
    const [siteName, setSiteName] = useState('マイアプリ');
    const [isMaintenance, setIsMaintenance] = useState(false);

    return (
        <div className="flex flex-col gap-8 max-w-2xl">
            {/* 上部ヘッダー */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900 tracking-tight">システム設定</h1>
                <p className="text-sm text-gray-500 mt-1">
                    アプリケーションのグローバルな動作環境を設定します。
                </p>
            </div>

            {/* 設定フォーム */}
            <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm flex flex-col gap-6">
                <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        サイト名称
                    </label>
                    <input
                        type="text"
                        value={siteName}
                        onChange={(e) => setSiteName(e.target.value)}
                        className="w-full max-w-md px-4 py-2.5 bg-white border border-gray-300 rounded-xl text-gray-900 text-sm focus:outline-hidden focus:border-blue-600 focus:ring-1 focus:ring-blue-600 transition-colors"
                    />
                </div>

                <div className="flex items-center justify-between border-t border-gray-100 pt-6">
                    <div>
                        <label className="text-sm font-semibold text-gray-700 block">
                            メンテナンスモード
                        </label>
                        <span className="text-xs text-gray-500">
                            有効にすると管理者以外のアクセスが制限されます。
                        </span>
                    </div>
                    <input
                        type="checkbox"
                        checked={isMaintenance}
                        onChange={(e) => setIsMaintenance(e.target.checked)}
                        className="w-5 h-5 accent-blue-600 cursor-pointer"
                    />
                </div>

                <div className="border-t border-gray-100 pt-6 flex justify-end">
                    <button
                        type="button"
                        className="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-5 rounded-xl transition-colors text-sm shadow-xs cursor-pointer"
                    >
                        設定を保存
                    </button>
                </div>
            </div>
        </div>
    );
}
