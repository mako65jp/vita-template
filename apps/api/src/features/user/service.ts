import type { CreateUser, User } from '@packages/schemas';
import type { UserRepository } from '../../repositories/user-repository';

export class UserService {
    constructor(private readonly repository: UserRepository) {}

    async findById(id: number) {
        return this.repository.findById(id);
    }

    async findByEmail(email: string) {
        return this.repository.findByEmail(email);
    }

    async findAll() {
        return this.repository.findAll();
    }

    async create(user: CreateUser) {
        await this.repository.create(user);
    }

    async update(user: User) {
        await this.repository.save(user);
    }

    async changePassword(id: number, passwordHash: string) {
        await this.repository.updatePassword(id, passwordHash);
    }

    async changeRole(currentUserId: number, targetUserId: number, role: string) {
        if (currentUserId === targetUserId) {
            throw new Error('Cannot change your own role');
        }

        const target = await this.repository.findById(targetUserId);

        if (target?.role === 'admin' && role !== 'admin') {
            const adminCount = await this.repository.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot demote last admin');
            }
        }

        await this.repository.updateRole(targetUserId, role);
    }

    async changeActive(currentUserId: number, targetUserId: number, isActive: boolean) {
        if (currentUserId === targetUserId) {
            throw new Error('Cannot disable yourself');
        }

        const target = await this.repository.findById(targetUserId);

        if (target?.role === 'admin' && !isActive) {
            const adminCount = await this.repository.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot disable last admin');
            }
        }

        await this.repository.updateActive(targetUserId, isActive);
    }

    async delete(currentUserId: number, targetUserId?: number) {
        const id = targetUserId ?? currentUserId;

        if (currentUserId === id) {
            throw new Error('Cannot delete yourself');
        }

        const target = await this.repository.findById(id);

        if (target?.role === 'admin') {
            const adminCount = await this.repository.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot delete last admin');
            }
        }

        await this.repository.remove(id);
    }
}
