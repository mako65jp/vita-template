import { User } from '../domain/User';
import { UserRepository } from '../repositories/UserRepository';

export class UserService {
    constructor(private readonly users: UserRepository) { }

    async findById(id: string) {
        return this.users.findById(id);
    }

    async findByEmail(email: string) {
        return this.users.findByEmail(email);
    }

    async findAll() {
        return this.users.findAll();
    }

    async create(user: User) {
        await this.users.create(user);
    }

    async update(user: User) {
        await this.users.save(user);
    }

    async changePassword(id: string, passwordHash: string) {
        await this.users.updatePassword(id, passwordHash);
    }

    async changeRole(currentUserId: string, targetUserId: string, role: string) {
        if (currentUserId === targetUserId) {
            throw new Error('Cannot change your own role');
        }

        const target = await this.users.findById(targetUserId);

        if (target?.role === 'admin' && role !== 'admin') {
            const adminCount = await this.users.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot demote last admin');
            }
        }

        await this.users.updateRole(targetUserId, role);
    }

    async changeActive(currentUserId: string, targetUserId: string, isActive: boolean) {
        if (currentUserId === targetUserId) {
            throw new Error('Cannot disable yourself');
        }

        const target = await this.users.findById(targetUserId);

        if (target?.role === 'admin' && !isActive) {
            const adminCount = await this.users.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot disable last admin');
            }
        }

        await this.users.updateActive(targetUserId, isActive);
    }

    async delete(currentUserId: string, targetUserId?: string) {
        const id = targetUserId ?? currentUserId;

        if (currentUserId === id) {
            throw new Error('Cannot delete yourself');
        }

        const target = await this.users.findById(id);

        if (target?.role === 'admin') {
            const adminCount = await this.users.countAdmins();

            if (adminCount <= 1) {
                throw new Error('Cannot delete last admin');
            }
        }

        await this.users.remove(id);
    }
}
