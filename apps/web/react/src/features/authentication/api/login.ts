import { Application } from '@apps/web-core/Application';
import { LoginRequest } from '@packages/types/authentication/LoginRequest';
import { LoginResponse } from '@packages/types/authentication/LoginResponse';

const application = new Application();

export async function login(request: LoginRequest): Promise<LoginResponse> {
    console.log('login request', JSON.stringify(request));

    const response = await application.fetch(`/auth/login`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(request),
    });
    if (!response.ok) {
        throw new Error(`Login failed: ${response.status}`);
    }

    return await response.json();
}
