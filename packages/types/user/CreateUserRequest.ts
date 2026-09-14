export interface CreateUserRequest {
    name: string;
    email: string;
    passwordHash: string;
    role?: string;
}
