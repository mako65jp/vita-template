import { defaultPath } from '@apps/web-react/src/app/features';
import { useAuth } from '@apps/web-react/src/app/providers/AuthProvider';
import { useNavigate } from 'react-router-dom';
import { login } from '../api/login';

export function useLogin() {
    const auth = useAuth();
    const navigate = useNavigate();

    return async (email: string, password: string) => {
        const result = await login({
            email: email,
            password,
        });

        auth.signIn(result.accessToken);

        navigate(defaultPath, {
            replace: true,
        });
    };
}
