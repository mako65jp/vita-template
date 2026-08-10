import React, { createContext, useContext, useState, useEffect } from 'react';
import { apiClient, getStoredToken, setStoredToken, removeStoredToken } from '../lib/apiClient';

// ユーザーオブジェクトの型定義
export interface User {
    id: number | string;
    name?: string;
    email: string;
    role: string;
}

// AuthContext の型定義
export interface AuthContextType {
    user: User | null;
    token: string | null;
    isLoading: boolean;
    isAuthenticated: boolean;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [user, setUser] = useState<User | null>(null);
    const [token, setToken] = useState<string | null>(() => getStoredToken());
    const [isLoading, setIsLoading] = useState<boolean>(true);

    // 初期化時：localStorage にトークンがあれば /api/auth/me でユーザー情報を復元
    useEffect(() => {
        const initAuth = async () => {
            const storedToken = getStoredToken();
            if (!storedToken) {
                setIsLoading(false);
                return;
            }

            try {
                const data = await apiClient.get<{ user: User }>('/api/auth/me');
                setUser(data.user);
                setToken(storedToken);
            } catch (error) {
                console.error('Failed to restore authentication session:', error);
                removeStoredToken();
                setToken(null);
                setUser(null);
            } finally {
                setIsLoading(false);
            }
        };

        initAuth();
    }, []);

    // ログイン処理
    const login = async (email: string, password: string) => {
        const data = await apiClient.post<{ token: string; user: User }>('/api/auth/login', {
            email,
            password,
        });

        setStoredToken(data.token);
        setToken(data.token);
        setUser(data.user);
    };

    // ログアウト処理
    const logout = () => {
        removeStoredToken();
        setToken(null);
        setUser(null);
    };

    return (
        <AuthContext.Provider
            value={{
                user,
                token,
                isLoading,
                isAuthenticated: !!user,
                login,
                logout,
            }}
        >
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = (): AuthContextType => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};
