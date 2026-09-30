import { ConfigurationApi } from '@apps/web-core/api-client/administration/ConfigurationApi';
import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';
import { defaultAuthenticationPolicy } from '@packages/types/administration/defaultAuthenticationPolicy';
import { useState } from 'react';

export function SettingsPage() {
    const [policy, setPolicy] = useState<AuthenticationPolicy>(defaultAuthenticationPolicy);
    const [isSaving, setIsSaving] = useState(false); // 保存中のローディング状態
    const configurationApi = new ConfigurationApi();

    async function handleSave() {
        if (isSaving) return; // 二重クリック防止

        setIsSaving(true);
        try {
            await configurationApi.saveConfiguration({
                authenticationPolicy: policy,
            });

            alert('保存しました');
        } catch {
            alert('保存に失敗しました');
        } finally {
            setIsSaving(false); // 成功・失敗に関わらずローディングを解除
        }
    }

    return (
        <div className="max-w-5xl mx-auto flex flex-col gap-8">
            <div>
                <h1 className="text-3xl font-bold">認証・セキュリティ設定</h1>

                <p className="text-gray-500 mt-2">
                    ユーザー認証、セッション管理、およびアクセス制御を構成します。
                </p>
            </div>

            <section className="bg-white border rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-6">セッション管理</h2>

                <div className="grid gap-6">
                    <div>
                        <label className="block font-medium mb-2">ブラウザ再読込時</label>

                        <select
                            value={policy.session.reloadBehavior}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    session: {
                                        ...policy.session,
                                        reloadBehavior: e.target.value as 'keep-session' | 'logout',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="keep-session">ログイン状態を維持する</option>

                            <option value="logout">ログアウトする</option>
                        </select>
                    </div>

                    <div>
                        <label className="block font-medium mb-2">アイドルタイムアウト（分）</label>

                        <input
                            type="number"
                            value={policy.session.idleTimeoutMinutes}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    session: {
                                        ...policy.session,
                                        idleTimeoutMinutes: Number(e.target.value),
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-40"
                        />
                    </div>

                    <div>
                        <label className="block font-medium mb-2">
                            絶対セッションタイムアウト（分）
                        </label>

                        <input
                            type="number"
                            value={policy.session.absoluteTimeoutMinutes}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    session: {
                                        ...policy.session,
                                        absoluteTimeoutMinutes: Number(e.target.value),
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-40"
                        />
                    </div>
                </div>
            </section>

            <section className="bg-white border rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-6">Deep Link</h2>

                <div className="grid gap-6">
                    <label className="flex items-center gap-3">
                        <input
                            type="checkbox"
                            checked={policy.deepLink.enabled}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    deepLink: {
                                        ...policy.deepLink,
                                        enabled: e.target.checked,
                                    },
                                })
                            }
                        />
                        ログイン前URLを保持する
                    </label>

                    <div>
                        <label className="block font-medium mb-2">ログイン成功後</label>

                        <select
                            value={policy.deepLink.afterLogin}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    deepLink: {
                                        ...policy.deepLink,
                                        afterLogin: e.target.value as 'restore' | 'home',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="restore">元URLへ戻る</option>

                            <option value="home">ホームへ戻る</option>
                        </select>
                    </div>
                </div>
            </section>

            <section className="bg-white border rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-6">アクセス制御</h2>

                <div className="grid gap-6">
                    <div>
                        <label className="block font-medium mb-2">
                            認証済みで /login にアクセス
                        </label>

                        <select
                            value={policy.navigation.loginPageWhileAuthenticated}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    navigation: {
                                        ...policy.navigation,
                                        loginPageWhileAuthenticated: e.target.value as
                                            'back' | 'home',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="back">元画面へ戻る</option>

                            <option value="home">ホームへ戻る</option>
                        </select>
                    </div>

                    <div>
                        <label className="block font-medium mb-2">権限なしURLアクセス時</label>

                        <select
                            value={policy.navigation.forbiddenPage}
                            onChange={(e) =>
                                setPolicy({
                                    ...policy,
                                    navigation: {
                                        ...policy.navigation,
                                        forbiddenPage: e.target.value as 'back' | 'home' | '403',
                                    },
                                })
                            }
                            className="border rounded-lg px-3 py-2 w-full max-w-md"
                        >
                            <option value="back">元画面へ戻る</option>

                            <option value="home">ホームへ戻る</option>

                            <option value="403">403画面を表示</option>
                        </select>
                    </div>
                </div>
            </section>

            <div className="flex justify-end">
                <button
                    onClick={handleSave}
                    disabled={isSaving}
                    className={`px-8 py-3 rounded-xl text-white transition-colors ${
                        isSaving
                            ? 'bg-blue-400 cursor-not-allowed'
                            : 'bg-blue-600 hover:bg-blue-700'
                    }`}
                >
                    {isSaving ? '保存中...' : '保存'}
                </button>
            </div>
        </div>
    );
}
