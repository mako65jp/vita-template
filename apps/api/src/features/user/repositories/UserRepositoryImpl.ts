import { Database } from '../../../database/Database';
import { User } from '../domain/User';
import { UserRepository } from './UserRepository';

export class UserRepositoryImpl implements UserRepository {
    constructor(private readonly db: Database) {}

    async findById(id: string) {
        const rows = await this.db.query<User>(
            `
      select
        id,
        name,
        email,
        password_hash as "passwordHash",
        role,
        is_active as "isActive",
        created_at as "createdAt"
      from public.users
      where id = $1
      `,
            [Number(id)],
        );

        return rows[0];
    }

    async findByEmail(email: string) {
        const rows = await this.db.query<User>(
            `
      select
        id,
        name,
        email,
        password_hash as "passwordHash",
        role,
        is_active as "isActive",
        created_at as "createdAt"
      from public.users
      where email = $1
      `,
            [email],
        );

        return rows[0];
    }

    async findAll() {
        return this.db.query<User>(
            `
      select
        id,
        name,
        email,
        password_hash as "passwordHash",
        role,
        is_active as "isActive",
        created_at as "createdAt"
      from public.users
      order by id
      `,
        );
    }

    async countAdmins() {
        const rows = await this.db.query<{ count: string }>(
            `
      select count(*)::text as count
      from public.users
      where role = 'admin'
      and is_active = true
      `,
        );

        return Number(rows[0]?.count ?? 0);
    }

    async create(user: User) {
        await this.db.execute(
            `
      insert into public.users (
        name,
        email,
        password_hash,
        role
      )
      values ($1,$2,$3,$4)
      `,
            [user.name, user.email, user.passwordHash, user.role],
        );
    }

    async save(user: User) {
        await this.db.execute(
            `
      update public.users
      set
        name = $2,
        email = $3,
        role = $4,
        is_active = $5
      where id = $1
      `,
            [user.id, user.name, user.email, user.role, user.isActive],
        );
    }

    async updatePassword(id: string, passwordHash: string) {
        await this.db.execute(
            `
      update public.users
      set password_hash = $2
      where id = $1
      `,
            [Number(id), passwordHash],
        );
    }

    async updateRole(id: string, role: string) {
        await this.db.execute(
            `
      update public.users
      set role = $2
      where id = $1
      `,
            [Number(id), role],
        );
    }

    async updateActive(id: string, isActive: boolean) {
        await this.db.execute(
            `
      update public.users
      set is_active = $2
      where id = $1
      `,
            [Number(id), isActive],
        );
    }

    async remove(id: string) {
        await this.db.execute(
            `
      delete
      from public.users
      where id = $1
      `,
            [Number(id)],
        );
    }
}
