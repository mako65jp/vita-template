export interface AppJwtPayload {
    sub: number;
    email: string;
    role: string;
    iat?: number;
    exp?: number;
}
