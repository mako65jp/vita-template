// phase-8-password-change.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// UserRepository.ts
//

await file(
    'apps/api/src/features/user/repositories/UserRepository.ts',
    `
import { User } from "../domain/User";

export interface UserRepository {
  findById(id: string): Promise<User | undefined>;
  findByEmail(email: string): Promise<User | undefined>;
  findAll(): Promise<User[]>;
  create(user: User): Promise<void>;
  save(user: User): Promise<void>;
  updatePassword(
    id: string,
    passwordHash: string,
  ): Promise<void>;
  remove(id: string): Promise<void>;
}
`,
);

//
// UserRepositoryImpl.ts
//

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

  async create(user: User) {
    await this.db.execute(
      \`
      insert into public.users (
        name,
        email,
        password_hash,
        role
      )
      values (
        $1,
        $2,
        $3,
        $4
      )
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

//
// UserService.ts
//

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

  async delete(id: string) {
    await this.users.remove(id);
  }
}
`,
);

//
// UserController.ts
//

await file(
    'apps/api/src/features/user/controllers/UserController.ts',
    `
import { Hono } from "hono";
import bcrypt from "bcrypt";

import { User } from "../domain/User";
import { UserService } from "../services/UserService";
import { UserMapper } from "../mappers/UserMapper";

export function createUserController(
  service: UserService,
) {

  const router = new Hono();

  router.get("/", async c => {
    const users = await service.findAll();

    return c.json(
      users.map(
        user => UserMapper.toDto(user),
      ),
    );
  });

  router.get("/:id", async c => {
    const user = await service.findById(
      c.req.param("id"),
    );

    if (!user) {
      return c.notFound();
    }

    return c.json(
      UserMapper.toDto(user),
    );
  });

  router.post("/", async c => {

    const body = await c.req.json();

    const passwordHash = await bcrypt.hash(
      body.password,
      10,
    );

    const user = new User(
      0,
      body.name,
      body.email,
      passwordHash,
      body.role ?? "user",
      true,
      new Date(),
    );

    await service.create(user);

    return c.json(
      { message: "created" },
      201,
    );
  });

  router.put("/:id", async c => {

    const current = await service.findById(
      c.req.param("id"),
    );

    if (!current) {
      return c.notFound();
    }

    const body = await c.req.json();

    const user = new User(
      current.id,
      body.name,
      body.email,
      current.passwordHash,
      body.role,
      body.isActive,
      current.createdAt,
    );

    await service.update(user);

    return c.json({
      message: "updated",
    });
  });

  router.put("/:id/password", async c => {

    const current = await service.findById(
      c.req.param("id"),
    );

    if (!current) {
      return c.notFound();
    }

    const body = await c.req.json();

    const passwordHash = await bcrypt.hash(
      body.password,
      10,
    );

    await service.changePassword(
      c.req.param("id"),
      passwordHash,
    );

    return c.json({
      message: "password updated",
    });
  });

  router.delete("/:id", async c => {

    await service.delete(
      c.req.param("id"),
    );

    return c.body(
      null,
      204,
    );
  });

  return router;
}
`,
);

console.log('phase-8-password-change completed');
