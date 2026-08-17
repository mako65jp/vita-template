import React, { useEffect, useState } from 'react';
import { toast, showErrorToast } from '@app/ui';
import { CreateUserModal } from './CreateUserModal';
import { AUTH_TOKEN_KEY } from '@app/core';

export interface User {
    id: number;
    name: string;
    email: string;
    role: 'user' | 'admin';
    isActive: boolean;
    createdAt?: string;
}

interface UserManagementTableProps {
    apiBaseUrl?: string;
}

// 認証ヘッダーを取得するヘルパー関数 (AUTH_TOKEN_KEYを指定)
const getAuthHeaders = (): Record<string, string> => {
    const token = localStorage.getItem(AUTH_TOKEN_KEY);
    return {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
    };
};

export const UserManagementTable: React.FC<UserManagementTableProps> = ({
    apiBaseUrl = '/api/user-management',
}) => {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null);
    const [isModalOpen, setIsModalOpen] = useState<boolean>(false);

    // 1. 一覧取得 (GET)
    const fetchUsers = async () => {
        try {
            setLoading(true);
            const res = await fetch(apiBaseUrl, {
                headers: getAuthHeaders(),
            });
            if (!res.ok) throw new Error('ユーザー情報の取得に失敗しました');
            const data = await res.json();
            setUsers(data.users);
            setError(null);
        } catch (err: any) {
            setError(err.message || 'エラーが発生しました');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchUsers();
    }, [apiBaseUrl]);

    // 2. 新規作成 (POST)
    const handleCreateUser = async (newUser: { name: string; email: string; role: 'user' | 'admin' }) => {
        const res = await fetch(apiBaseUrl, {
            method: 'POST',
            headers: getAuthHeaders(),
            body: JSON.stringify(newUser),
        });

        const data = await res.json();

        if (!res.ok) {
            showErrorToast(data);
            throw new Error(data.detail || data.message || 'ユーザーの作成に失敗しました');
        }

        toast.success('ユーザーを追加しました', {
            description: `${data.user.name} を作成しました。`,
        });

        setUsers((prev) => [...prev, data.user]);
    };

    // 3. ロール変更 (PATCH)
    const handleRoleChange = async (userId: number, newRole: 'user' | 'admin') => {
        try {
            const res = await fetch(`${apiBaseUrl}/${userId}/role`, {
                method: 'PATCH',
                headers: getAuthHeaders(),
                body: JSON.stringify({ role: newRole }),
            });

            const data = await res.json();
            if (!res.ok) throw new Error(data.detail || data.message || 'ロールの更新に失敗しました');

            setUsers((prev) =>
                prev.map((u) => (u.id === userId ? { ...u, role: data.user.role } : u))
            );
        } catch (err: any) {
            alert(err.message || '更新エラー');
        }
    };

    // 4. ステータス変更 (PATCH)
    const handleStatusToggle = async (userId: number, currentStatus: boolean) => {
        try {
            const res = await fetch(`${apiBaseUrl}/${userId}/status`, {
                method: 'PATCH',
                headers: getAuthHeaders(),
                body: JSON.stringify({ isActive: !currentStatus }),
            });

            const data = await res.json();
            if (!res.ok) throw new Error(data.detail || data.message || 'ステータスの更新に失敗しました');

            setUsers((prev) =>
                prev.map((u) => (u.id === userId ? { ...u, isActive: data.user.isActive } : u))
            );
        } catch (err: any) {
            alert(err.message || '更新エラー');
        }
    };

    // 5. 削除 (DELETE)
    const handleDeleteUser = async (userId: number) => {
        if (!confirm('本当にこのユーザーを削除しますか？')) return;

        try {
            const res = await fetch(`${apiBaseUrl}/${userId}`, {
                method: 'DELETE',
                headers: getAuthHeaders(),
            });

            const data = await res.json();
            if (!res.ok) {
                showErrorToast(data);
                return;
            }

            toast.success('ユーザーを削除しました');
            setUsers((prev) => prev.filter((u) => u.id !== userId));
        } catch (err: any) {
            toast.error(err.message || '削除エラーが発生しました');
        }
    };

    if (loading) return <div className="p-4">読み込み中...</div>;
    if (error) return <div className="p-4 text-red-500">エラー: {error}</div>;

    return (
        <div className="p-6 bg-white rounded-lg shadow-sm">
            <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold">ユーザー管理</h2>
                <button
                    onClick={() => setIsModalOpen(true)}
                    className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded hover:bg-blue-700 transition"
                >
                    ＋ ユーザー追加
                </button>
            </div>

            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="border-b bg-gray-50 text-sm font-semibold text-gray-600">
                            <th className="p-3">ID</th>
                            <th className="p-3">名前</th>
                            <th className="p-3">メールアドレス</th>
                            <th className="p-3">権限 (Role)</th>
                            <th className="p-3">ステータス</th>
                            <th className="p-3">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {users.map((user) => (
                            <tr key={user.id} className="border-b hover:bg-gray-50">
                                <td className="p-3 text-sm text-gray-500">{user.id}</td>
                                <td className="p-3 text-sm font-medium">{user.name}</td>
                                <td className="p-3 text-sm text-gray-600">{user.email}</td>
                                <td className="p-3 text-sm">
                                    <select
                                        value={user.role}
                                        onChange={(e) =>
                                            handleRoleChange(user.id, e.target.value as 'user' | 'admin')
                                        }
                                        className="border rounded px-2 py-1 text-sm bg-white"
                                    >
                                        <option value="user">ユーザー (user)</option>
                                        <option value="admin">管理者 (admin)</option>
                                    </select>
                                </td>
                                <td className="p-3 text-sm">
                                    <span
                                        className={`inline-block px-2 py-1 rounded text-xs font-semibold ${user.isActive
                                            ? 'bg-green-100 text-green-800'
                                            : 'bg-red-100 text-red-800'
                                            }`}
                                    >
                                        {user.isActive ? '有効' : '無効'}
                                    </span>
                                </td>
                                <td className="p-3 text-sm flex gap-2">
                                    <button
                                        onClick={() => handleStatusToggle(user.id, user.isActive)}
                                        className={`px-3 py-1 rounded text-xs text-white transition ${user.isActive
                                            ? 'bg-amber-500 hover:bg-amber-600'
                                            : 'bg-green-500 hover:bg-green-600'
                                            }`}
                                    >
                                        {user.isActive ? '無効化する' : '有効化する'}
                                    </button>
                                    <button
                                        onClick={() => handleDeleteUser(user.id)}
                                        className="px-3 py-1 bg-red-600 hover:bg-red-700 text-white text-xs rounded transition"
                                    >
                                        削除
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            <CreateUserModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onSubmit={handleCreateUser}
            />
        </div>
    );
};

