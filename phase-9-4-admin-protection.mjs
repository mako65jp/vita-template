// phase-9-4-admin-protection.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await file(
    'apps/api/src/features/user/repositories/UserRepository.ts',
    `
import { User } from "../domain/User";

export interface UserRepository {
  findById(id: string): Promise<User | undefined>;
  findByEmail(email: string): Promise<User | undefined>;
  findAll(): Promise<User[]>;
  countAdmins(): Promise<number>;
  create(user: User): Promise<void>;
  save(user: User): Promise<void>;
  updatePassword(id: string, passwordHash: string): Promise<void>;
  updateRole(id: string, role: string): Promise<void>;
  updateActive(id: string, isActive: boolean): Promise<void>;
  remove(id: string): Promise<void>;
}
`,
);

await file(
    'apps/api/src/features/user/repositories/UserRepositoryImpl.ts',
    `
import { Database } from "../../../database/Database";
import { User } from "../domain/User";
import { UserRepository } from "./UserRepository";

export class UserRepositoryImpl implements UserRepository {

  constructor(
    private readonly db: Database,
  ) {}

  async findById(id: string) {
    const rows = await this.db.query<User>(
      \`
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
      \`,
      [Number(id)],
    );

    return rows[0];
  }

  async findByEmail(email: string) {
    const rows = await this.db.query<User>(
      \`
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
      \`,
      [email],
    );

    return rows[0];
  }

  async findAll() {
    return this.db.query<User>(
      \`
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
      \`,
    );
  }

  async countAdmins() {
    const rows = await this.db.query<{ count: string }>(
      \`
      select count(*)::text as count
      from public.users
      where role = 'admin'
      and is_active = true
      \`,
    );

    return Number(rows[0]?.count ?? 0);
  }

  async create(user: User) {
    await this.db.execute(
      \`
      insert into public.users (
        name,
        email,
        password_hash,
        role
      )
      values ($1,$2,$3,$4)
      \`,
      [
        user.name,
        user.email,
        user.passwordHash,
        user.role,
      ],
    );
  }

  async save(user: User) {
    await this.db.execute(
      \`
      update public.users
      set
        name = $2,
        email = $3,
        role = $4,
        is_active = $5
      where id = $1
      \`,
      [
        user.id,
        user.name,
        user.email,
        user.role,
        user.isActive,
      ],
    );
  }

  async updatePassword(
    id: string,
    passwordHash: string,
  ) {
    await this.db.execute(
      \`
      update public.users
      set password_hash = $2
      where id = $1
      \`,
      [
        Number(id),
        passwordHash,
      ],
    );
  }

  async updateRole(
    id: string,
    role: string,
  ) {
    await this.db.execute(
      \`
      update public.users
      set role = $2
      where id = $1
      \`,
      [
        Number(id),
        role,
      ],
    );
  }

  async updateActive(
    id: string,
    isActive: boolean,
  ) {
    await this.db.execute(
      \`
      update public.users
      set is_active = $2
      where id = $1
      \`,
      [
        Number(id),
        isActive,
      ],
    );
  }

  async remove(id: string) {
    await this.db.execute(
      \`
      delete
      from public.users
      where id = $1
      \`,
      [Number(id)],
    );
  }
}
`,
);

await file(
    'apps/api/src/features/user/services/UserService.ts',
    `
import { User } from "../domain/User";
import { UserRepository } from "../repositories/UserRepository";

export class UserService {

  constructor(
    private readonly users: UserRepository,
  ) {}

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

  async changePassword(
    id: string,
    passwordHash: string,
  ) {
    await this.users.updatePassword(
      id,
      passwordHash,
    );
  }

  async changeRole(
    currentUserId: string,
    targetUserId: string,
    role: string,
  ) {

    if (currentUserId === targetUserId) {
      throw new Error(
        "Cannot change your own role",
      );
    }

    const target =
      await this.users.findById(
        targetUserId,
      );

    if (
      target?.role === "admin" &&
      role !== "admin"
    ) {

      const adminCount =
        await this.users.countAdmins();

      if (adminCount <= 1) {
        throw new Error(
          "Cannot demote last admin",
        );
      }
    }

    await this.users.updateRole(
      targetUserId,
      role,
    );
  }

  async changeActive(
    currentUserId: string,
    targetUserId: string,
    isActive: boolean,
  ) {

    if (
      currentUserId === targetUserId
    ) {
      throw new Error(
        "Cannot disable yourself",
      );
    }

    const target =
      await this.users.findById(
        targetUserId,
      );

    if (
      target?.role === "admin" &&
      !isActive
    ) {

      const adminCount =
        await this.users.countAdmins();

      if (adminCount <= 1) {
        throw new Error(
          "Cannot disable last admin",
        );
      }
    }

    await this.users.updateActive(
      targetUserId,
      isActive,
    );
  }

  async delete(
    currentUserId: string,
    targetUserId?: string,
  ) {

    const id =
      targetUserId ?? currentUserId;

    if (
      currentUserId === id
    ) {
      throw new Error(
        "Cannot delete yourself",
      );
    }

    const target =
      await this.users.findById(id);

    if (
      target?.role === "admin"
    ) {

      const adminCount =
        await this.users.countAdmins();

      if (adminCount <= 1) {
        throw new Error(
          "Cannot delete last admin",
        );
      }
    }

    await this.users.remove(id);
  }
}
`,
);

console.log('phase-9-4-admin-protection completed');
