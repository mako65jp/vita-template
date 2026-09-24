import { useAuth } from '../../../app/providers/AuthProvider';
import { login } from '../api/login';

export function useLogin() {
    const auth = useAuth();
    return async (email: string, password: string) => {
        const result = await login({
            email: email,
            password,
        });
        auth.signIn(result.accessToken);
    };
}
