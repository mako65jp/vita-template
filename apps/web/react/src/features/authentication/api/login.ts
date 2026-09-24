import { LoginRequest } from '../../../../../../../packages/types/authentication/LoginRequest';
import { LoginResponse } from '../../../../../../../packages/types/authentication/LoginResponse';
import { Application } from '../../../../../Application';

const application = new Application();

export async function login(request: LoginRequest): Promise<LoginResponse> {
    console.log('login request', JSON.stringify(request));

    const apiBaseUrl = application.configurationService.getApiBaseUrl();
    const response = await fetch(`${apiBaseUrl}/auth/login`, {
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
