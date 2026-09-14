import { User } from '../domain/User';

export interface UserRepository {
    findById(id: string): Promise<User | undefined>;
    findByEmail(email: string): Promise<User | undefined>;
    findAll(): Promise<User[]>;
    create(user: User): Promise<void>;
    save(user: User): Promise<void>;
    updatePassword(id: string, passwordHash: string): Promise<void>;
    updateRole(id: string, role: string): Promise<void>;
    updateActive(id: string, isActive: boolean): Promise<void>;
    remove(id: string): Promise<void>;
}
