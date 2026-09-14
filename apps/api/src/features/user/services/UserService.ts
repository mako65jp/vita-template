import { User } from '../domain/User';
import { UserRepository } from '../repositories/UserRepository';

export class UserService {
    constructor(private readonly users: UserRepository) {}

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

    async changeRole(id: string, role: string) {
        await this.users.updateRole(id, role);
    }

    async changeActive(id: string, isActive: boolean) {
        await this.users.updateActive(id, isActive);
    }

    async delete(id: string) {
        await this.users.remove(id);
    }
}
