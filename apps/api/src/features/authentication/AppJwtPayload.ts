export interface AppJwtPayload {

    /**
     * UserPrincipal.userId
     */
    sub: string;

    /**
     * UserPrincipal.email
     */
    email: string;

    /**
     * UserPrincipal.role
     */
    role: string;

    /**
     * issued at
     */
    iat?: number;

    /**
     * expiration time
     */
    exp?: number;
}

// export interface AppJwtPayload {
//     sub: number;
//     email: string;
//     role: string;
//     iat?: number;
//     exp?: number;
// }
