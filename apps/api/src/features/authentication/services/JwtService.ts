import jwt from 'jsonwebtoken';
import { AppJwtPayload } from '../AppJwtPayload';
import { UserPrincipal } from '../domain/UserPrincipal';

function isAppJwtPayload(value: unknown): value is AppJwtPayload {

    if (typeof value !== 'object' || value === null) {
        return false;
    }

    const payload = value as Record<string, unknown>;

    return (
        typeof payload.sub === 'string' &&
        typeof payload.email === 'string' &&
        typeof payload.role === 'string'
    );
}

export class JwtService {

    expiresInSeconds = 3600;

    constructor(
        private readonly secret: string
    ) { }

    createAccessToken(principal: UserPrincipal): string {

        return jwt.sign(
            {
                sub: principal.userId,
                email: principal.email,
                role: principal.role
            },
            this.secret,
            {
                expiresIn: `${this.expiresInSeconds}SECONDS`
            },
        );
    }

    verify(token: string): UserPrincipal {

        const payload = jwt.verify(
            token,
            this.secret
        );

        if (!isAppJwtPayload(payload)) {
            throw new Error('Invalid JWT payload.');
        }

        return {
            userId: payload.sub,
            email: payload.email,
            role: payload.role
        };
    }
}

// import jwt from 'jsonwebtoken';
// import { AppJwtPayload } from '../AppJwtPayload';
// import { UserPrincipal } from '../domain/UserPrincipal';

// export class JwtService {

//     constructor(
//         private readonly secret: string,
//     ) { }

//     createAccessToken(
//         principal: UserPrincipal,
//     ): string {

//         return jwt.sign(
//             {
//                 sub: principal.userId,
//                 email: principal.email,
//                 role: principal.role,
//             },
//             this.secret,
//             {
//                 expiresIn: '1h',
//             },
//         );
//     }

//     verify(
//         token: string,
//     ): UserPrincipal {

//         const payload =
//             jwt.verify(
//                 token,
//                 this.secret,
//             ) as AppJwtPayload;

//         return {
//             userId: String(payload.sub),
//             email: payload.email,
//             role: payload.role,
//         };
//     }
// }

// // import jwt from 'jsonwebtoken';

// // import { AppJwtPayload } from '../AppJwtPayload';
// // import { UserPrincipal } from '../domain/UserPrincipal';

// // export class JwtService {

// //     constructor(
// //         private readonly secret: string,
// //     ) { }

// //     createAccessToken(
// //         principal: UserPrincipal,
// //     ): string {

// //         return jwt.sign(
// //             {
// //                 sub: principal.userId,
// //                 email: principal.email,
// //                 role: principal.role,
// //             },
// //             this.secret,
// //             {
// //                 expiresIn: '1h',
// //             },
// //         );
// //     }

// //     verify(
// //         token: string,
// //     ): UserPrincipal {

// //         const payload =
// //             jwt.verify(
// //                 token,
// //                 this.secret
// //             ) as unknown as AppJwtPayload;

// //         return {
// //             userId: String(payload.sub),
// //             email: payload.email,
// //             role: payload.role,
// //         };
// //     }
// // }


// // // import jwt from 'jsonwebtoken';

// // // export class JwtService {
// // //     constructor(private readonly secret: string) {}

// // //     createAccessToken(userId: number, email: string, role: string) {
// // //         return jwt.sign(
// // //             {
// // //                 sub: userId,
// // //                 email,
// // //                 role,
// // //             },
// // //             this.secret,
// // //             {
// // //                 expiresIn: '1h',
// // //             },
// // //         );
// // //     }

// // //     verify(token: string) {
// // //         return jwt.verify(token, this.secret);
// // //     }
// // // }
