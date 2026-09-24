import { createContext, useContext, useMemo, useState } from 'react';

interface AuthContextValue {
    accessToken: string | null;
    signIn(accessToken: string): void;
    signOut(): void;
}

const AuthContext = createContext<AuthContextValue>(null as never);

export function AuthProvider(props: any) {
    const [accessToken, setAccessToken] = useState<string | null>(
        localStorage.getItem('accessToken'),
    );

    const value = useMemo(
        () => ({
            accessToken,

            signIn(token: string) {
                localStorage.setItem('accessToken', token);
                setAccessToken(token);
            },

            signOut() {
                localStorage.removeItem('accessToken');
                setAccessToken(null);
            },
        }),
        [accessToken],
    );

    return <AuthContext.Provider value={value}>{props.children}</AuthContext.Provider>;
}

export function useAuth() {
    return useContext(AuthContext);
}
