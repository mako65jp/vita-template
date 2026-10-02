import type { CreateUser, User } from '@packages/schemas';

export interface UserRepository {
    findById(id: number): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    findAll(): Promise<User[]>;
    countAdmins(): Promise<number>;

    create(user: CreateUser): Promise<User>;
    save(user: User): Promise<User>;

    updatePassword(id: number, passwordHash: string): Promise<User>;
    updateRole(id: number, role: string): Promise<User>;
    updateActive(id: number, isActive: boolean): Promise<User>;
    remove(id: number): Promise<void>;
}
