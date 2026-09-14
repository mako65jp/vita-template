export interface UserPrincipal {
    userId: string;

    userName: string;

    roles: readonly string[];
}
