import { useState, type SubmitEvent } from 'react';
import { useLogin } from '../hooks/useLogin';

export function LoginForm() {
    const login = useLogin();

    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    async function submit(event: SubmitEvent<HTMLFormElement>) {
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
        <div className="w-full max-w-md bg-white rounded-2xl border border-gray-200 p-8 shadow-sm">
            <div className="flex flex-col items-center mb-8">
                <div className="w-12 h-12 bg-blue-600 rounded-xl flex items-center justify-center text-white font-bold text-2xl mb-4">
                    M
                </div>
                <h1 className="text-2xl font-bold text-gray-900 tracking-tight">アカウントにログイン</h1>
                <p className="text-sm text-gray-500 mt-1">管理画面にアクセスするための資格情報を入力してください</p>
            </div>
            {error && (
                <div className="mb-6 p-4 bg-red-50 border border-red-100 rounded-xl text-sm text-red-600 font-medium解">
                    {error}
                </div>
            )}
            <form onSubmit={submit} className="flex flex-col gap-5">
                <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Email
                    </label>
                    <input
                        value={email}
                        onChange={(event) => setEmail(event.target.value)}
                        required
                        className="w-full px-4 py-3 bg-white border border-gray-300 rounded-xl text-gray-900 text-sm focus:outline-hidden focus:border-blue-600 focus:ring-1 focus:ring-blue-600 transition-colors"
                        placeholder="name@example.com"
                    />
                </div>
                <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                        Password
                    </label>
                    <input
                        type="password"
                        value={password}
                        onChange={(event) => setPassword(event.target.value)}
                        required
                        className="w-full px-4 py-3 bg-white border border-gray-300 rounded-xl text-gray-900 text-sm focus:outline-hidden focus:border-blue-600 focus:ring-1 focus:ring-blue-600 transition-colors"
                        placeholder="••••••••"
                    />
                </div>
                <button
                    type="submit"
                    disabled={loading}
                    className="w-full mt-2 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-semibold py-3 px-4 rounded-xl transition-colors text-center text-sm shadow-xs cursor-pointer flex justify-center items-center"
                >
                    {loading ? 'Loading...' : 'Login'}
                </button>
            </form>
        </div>
    );
}
