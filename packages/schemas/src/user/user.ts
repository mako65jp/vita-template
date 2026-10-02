export interface User {
    id: number;
    name: string;
    email: string;
    passwordHash: string;
    role: string;
    isActive: boolean;
    createdAt: Date;
}
