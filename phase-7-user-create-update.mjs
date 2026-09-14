// phase-7-user-create-update.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// CreateUserRequest
//

await file(
    'packages/types/user/CreateUserRequest.ts',
    `
export interface CreateUserRequest {
  name: string;
  email: string;
  passwordHash: string;
  role?: string;
}
`,
);

//
// UpdateUserRequest
//

await file(
    'packages/types/user/UpdateUserRequest.ts',
    `
export interface UpdateUserRequest {
  name: string;
  email: string;
  role: string;
  isActive: boolean;
}
`,
);

//
// UserRepositoryImpl
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
// UserService
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

  async findAll() {
    return this.users.findAll();
  }

  async create(user: User) {
    await this.users.create(user);
  }

  async update(user: User) {
    await this.users.save(user);
  }

  async delete(id: string) {
    await this.users.remove(id);
  }
}
`,
);

//
// UserController
//

await file(
    'apps/api/src/features/user/controllers/UserController.ts',
    `
import { Hono } from "hono";
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
      users.map(user =>
        UserMapper.toDto(user),
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

    const user = new User(
      0,
      body.name,
      body.email,
      body.passwordHash,
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

console.log('phase-7-user-create-update completed');
