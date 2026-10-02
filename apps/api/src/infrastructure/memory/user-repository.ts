import type { CreateUser, User } from '@packages/schemas';
import { hashPassword } from '../../features/user/auth-utils';
import type { UserRepository } from '../../repositories/user-repository';

export class MemoryUserRepository implements UserRepository {
    private sequence = 1;

    private readonly users = new Map<number, User>();

    async findById(id: number): Promise<User | null> {
        return this.users.get(id) ?? null;
    }

    async findByEmail(email: string): Promise<User | null> {
        let result = null;
        for (const user of this.users.values()) {
            if (user.email === email) {
                result = user;
                break;
            }
        }
        return result;
    }

    async findAll(): Promise<User[]> {
        throw new Error('not implemented');
    }
    async countAdmins(): Promise<number> {
        throw new Error('not implemented');
    }

    async create(request: CreateUser): Promise<User> {
        const passwordHash = await hashPassword(request.password);
        const user: User = {
            id: this.sequence++,
            name: request.name,
            email: request.email,
            passwordHash: passwordHash,
            role: 'user',
            isActive: true,
            createdAt: new Date(),
        };
        this.users.set(user.id, user);
        return user;
    }

    async save(user: User): Promise<User> {
        throw new Error('not implemented');
    }
    async updatePassword(id: number, passwordHash: string): Promise<User> {
        throw new Error('not implemented');
    }
    async updateRole(id: number, role: string): Promise<User> {
        throw new Error('not implemented');
    }
    async updateActive(id: number, isActive: boolean): Promise<User> {
        throw new Error('not implemented');
    }
    async remove(id: number): Promise<void> {
        throw new Error('not implemented');
    }
}
