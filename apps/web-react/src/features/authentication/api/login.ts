export interface LoginRequest {
    email: string;
    password: string;
}

export interface LoginResponse {
    accessToken: string;
    expiresIn: number;
}

export async function login(
    request: LoginRequest,
): Promise<LoginResponse> {
    const response =
        await fetch(
            '/api/auth/login',
            {
                method: 'POST',
                headers: {
                    'Content-Type':
                        'application/json',
                },
                body:
                    JSON.stringify(
                        request,
                    ),
            },
        );

    if (!response.ok) {
        throw new Error(
            'Login failed',
        );
    }

    return await response.json();
}
