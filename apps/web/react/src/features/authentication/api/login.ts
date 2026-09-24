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

// import {
//     loadApplicationConfiguration,
// } from '../../../../../loadApplicationConfiguration';

// export interface LoginRequest {
//     readonly email: string;
//     readonly password: string;
// }

// export interface LoginResponse {
//     readonly accessToken: string;
// }

// export async function login(
//     request: LoginRequest,
// ): Promise<LoginResponse> {
//     const configuration =
//         loadApplicationConfiguration();

//     const response = await fetch(
//         `${configuration.apiBaseUrl}/auth/login`,
//         {
//             method: 'POST',
//             headers: {
//                 'Content-Type': 'application/json',
//             },
//             body: JSON.stringify(request),
//         },
//     );

//     if (!response.ok) {
//         throw new Error(
//             `Login failed: ${response.status}`,
//         );
//     }

//     return await response.json();
// }

// // import { Application } from '../../../../../Application';

// // const application = new Application();

// // export async function login(
// //     username: string,
// //     password: string,
// // ) {

// //     const response = await fetch(
// //         `${application.frontendConfigurationService.getApiBaseUrl()}/auth/login`,
// //         {
// //             method: 'POST',
// //             headers: {
// //                 'Content-Type': 'application/json',
// //             },
// //             body: JSON.stringify({
// //                 username,
// //                 password,
// //             }),
// //         },
// //     );

// //     return response.json();
// // }

// // // export interface LoginRequest {
// // //     email: string;
// // //     password: string;
// // // }

// // // export interface LoginResponse {
// // //     accessToken: string;
// // //     expiresIn: number;
// // // }

// // // export async function login(request: LoginRequest): Promise<LoginResponse> {
// // //     const apiBaseUrl =
// // //         window.__APP_CONFIG__.apiBaseUrl;

// // //     const response = await fetch(
// // //         `${apiBaseUrl}/auth/login`,
// // //         {
// // //             method: 'POST',
// // //             headers: {
// // //                 'Content-Type': 'application/json',
// // //             },
// // //             body: JSON.stringify(request),
// // //         }
// // //     );
// // //     if (!response.ok) {
// // //         throw new Error('Login failed');
// // //     }

// // //     return await response.json();

// // // }

// // // // export interface LoginRequest {
// // // //     email: string;
// // // //     password: string;
// // // // }

// // // // export interface LoginResponse {
// // // //     accessToken: string;
// // // //     expiresIn: number;
// // // // }

// // // // export async function login(request: LoginRequest): Promise<LoginResponse> {
// // // //     const response = await fetch('/api/auth/login', {
// // // //         method: 'POST',
// // // //         headers: {
// // // //             'Content-Type': 'application/json',
// // // //         },
// // // //         body: JSON.stringify(request),
// // // //     });

// // // //     if (!response.ok) {
// // // //         throw new Error('Login failed');
// // // //     }

// // // //     return await response.json();
// // // // }

// // // // // export interface LoginRequest {
// // // // //     email: string;
// // // // //     password: string;
// // // // // }

// // // // // export interface LoginResponse {
// // // // //     accessToken: string;
// // // // //     expiresIn: number;
// // // // // }

// // // // // export async function login(request: LoginRequest): Promise<LoginResponse> {
// // // // //     const response = await fetch('/api/auth/login', {
// // // // //         method: 'POST',
// // // // //         headers: {
// // // // //             'Content-Type': 'application/json',
// // // // //         },
// // // // //         body: JSON.stringify(request),
// // // // //     });

// // // // //     if (!response.ok) {
// // // // //         throw new Error('Login failed');
// // // // //     }

// // // // //     return await response.json();
// // // // // }
