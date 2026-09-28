import { createContext, useContext, useEffect, useMemo, useState } from 'react';

interface AuthContextValue {
    readonly accessToken: string | null;
    readonly isAuthenticated: boolean;

    signIn(accessToken: string): void;
    signOut(): void;
}

const AuthContext = createContext<AuthContextValue>(null as never);

function getTokenExpiration(token: string): number | null {
    try {
        const [, payloadBase64] = token.split('.');

        const payload = JSON.parse(atob(payloadBase64));

        if (typeof payload.exp !== 'number') {
            return null;
        }

        return payload.exp * 1000;
    } catch {
        return null;
    }
}

function isTokenExpired(token: string): boolean {
    const expiresAt = getTokenExpiration(token);

    if (expiresAt === null) {
        return true;
    }

    return expiresAt <= Date.now();
}

export function AuthProvider(props: any) {
    const [accessToken, setAccessToken] = useState<string | null>(null);

    useEffect(() => {
        if (!accessToken) {
            return;
        }

        const expiresAt = getTokenExpiration(accessToken);
        if (expiresAt === null) {
            setAccessToken(null);
            return;
        }

        const timeout = expiresAt - Date.now();
        if (timeout <= 0) {
            setAccessToken(null);
            return;
        }

        const timer = window.setTimeout(() => setAccessToken(null), timeout);

        return () => window.clearTimeout(timer);
    }, [accessToken]);

    const isAuthenticated = accessToken !== null && !isTokenExpired(accessToken);

    const value = useMemo(
        () => ({
            accessToken,
            isAuthenticated,
            signIn(token: string) {
                setAccessToken(token);
            },
            signOut() {
                setAccessToken(null);
            },
        }),
        [accessToken, isAuthenticated],
    );

    return <AuthContext.Provider value={value}>{props.children}</AuthContext.Provider>;
}

export function useAuth() {
    return useContext(AuthContext);
}
