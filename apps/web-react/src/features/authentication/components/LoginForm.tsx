import { useState } from 'react';

import { useLogin } from '../hooks/useLogin';

export function LoginForm() {
    const login = useLogin();

    const [email, setEmail] = useState('');

    const [password, setPassword] = useState('');

    const [loading, setLoading] = useState(false);

    const [error, setError] = useState('');

    async function submit(event) {
        event.preventDefault();

        setLoading(true);

        setError('');

        try {
            await login(email, password);
        } catch {
            setError('Login failed');
        } finally {
            setLoading(false);
        }
    }

    return (
        <form onSubmit={submit}>
            <div>
                <label>Email</label>

                <input value={email} onChange={(event) => setEmail(event.target.value)} />
            </div>

            <div>
                <label>Password</label>

                <input
                    type="password"
                    value={password}
                    onChange={(event) => setPassword(event.target.value)}
                />
            </div>

            {error && <p>{error}</p>}

            <button type="submit" disabled={loading}>
                {loading ? 'Loading...' : 'Login'}
            </button>
        </form>
    );
}
