import { AdminUserRepository } from '../repositories/AdminUserRepository';

export class AdminUserService {
    constructor(private readonly repository: AdminUserRepository) {}
}
