export interface User {
    id: number;
    name: string;
    email: string;
    role: 'admin' | 'user';
    isActive: boolean;
    createdAt?: string;
}

export interface CreateUserInput {
    name: string;
    email: string;
    role: 'admin' | 'user';
}

export const fetchUsers = async (apiBaseUrl: string): Promise<User[]> => {
    const res = await fetch(apiBaseUrl);
    if (!res.ok) throw new Error('ユーザー一覧の取得に失敗しました');
    const data = await res.json();
    return data.users;
};

export const createUser = async (apiBaseUrl: string, input: CreateUserInput): Promise<User> => {
    const res = await fetch(apiBaseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
    });
    if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || errorData.message || 'ユーザーの作成に失敗しました');
    }
    const data = await res.json();
    return data.user;
};

export const updateUserStatus = async (apiBaseUrl: string, id: number, isActive: boolean): Promise<User> => {
    const res = await fetch(`${apiBaseUrl}/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive }),
    });
    if (!res.ok) throw new Error('ステータスの更新に失敗しました');
    const data = await res.json();
    return data.user;
};

export const updateUserRole = async (apiBaseUrl: string, id: number, role: 'admin' | 'user'): Promise<User> => {
    const res = await fetch(`${apiBaseUrl}/${id}/role`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ role }),
    });
    if (!res.ok) throw new Error('ロールの更新に失敗しました');
    const data = await res.json();
    return data.user;
};
