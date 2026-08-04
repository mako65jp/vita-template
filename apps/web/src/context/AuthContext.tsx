import React, { createContext, useContext, useState, useEffect } from 'react';

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
    const [token, setToken] = useState<string | null>(() => localStorage.getItem('token'));
    const [isLoading, setIsLoading] = useState<boolean>(true);

    // 初期化時：localStorage にトークンがあれば /api/auth/me でユーザー情報を復元
    useEffect(() => {
        const initAuth = async () => {
            const storedToken = localStorage.getItem('token');
            if (!storedToken) {
                setIsLoading(false);
                return;
            }

            try {
                const res = await fetch('/api/auth/me', {
                    headers: {
                        Authorization: `Bearer ${storedToken}`,
                    },
                });

                if (res.ok) {
                    const data = await res.json();
                    setUser(data.user);
                    setToken(storedToken);
                } else {
                    localStorage.removeItem('token');
                    setToken(null);
                    setUser(null);
                }
            } catch (error) {
                console.error('Failed to restore authentication session:', error);
                localStorage.removeItem('token');
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
        const res = await fetch('/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password }),
        });

        if (!res.ok) {
            const errorData = await res.json().catch(() => ({}));
            throw new Error(errorData.detail || 'Login failed');
        }

        const data = await res.json();
        localStorage.setItem('token', data.token);
        setToken(data.token);
        setUser(data.user);
    };

    // ログアウト処理
    const logout = () => {
        localStorage.removeItem('token');
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
