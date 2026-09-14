import { AdminUser } from '../domain/AdminUser';

export interface AdminUserRepository {
    findAll(): Promise<AdminUser[]>;
}
