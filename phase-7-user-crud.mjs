// phase-7-user-crud.mjs

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
  findAll(): Promise<User[]>;
  save(user: User): Promise<void>;
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

export class UserRepositoryImpl
implements UserRepository {

  constructor(
    private readonly db: Database,
  ) {}

  async findById(
    id: string,
  ) {

    const rows =
      await this.db.query<User>(
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
      \`
    );
  }

  async save(
    user: User,
  ) {

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

  async remove(
    id: string,
  ) {

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
import { UserRepository } from "../repositories/UserRepository";

export class UserService {

  constructor(
    private readonly users: UserRepository,
  ) {}

  async findById(
    id: string,
  ) {
    return this.users.findById(id);
  }

  async findAll() {
    return this.users.findAll();
  }

  async delete(
    id: string,
  ) {
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
import { UserService } from "../services/UserService";
import { UserMapper } from "../mappers/UserMapper";

export function createUserController(
  service: UserService,
) {

  const router = new Hono();

  router.get(
    "/",
    async c => {

      const users =
        await service.findAll();

      return c.json(
        users.map(
          user =>
            UserMapper.toDto(
              user,
            ),
        ),
      );
    },
  );

  router.get(
    "/:id",
    async c => {

      const user =
        await service.findById(
          c.req.param("id"),
        );

      if (!user) {
        return c.notFound();
      }

      return c.json(
        UserMapper.toDto(
          user,
        ),
      );
    },
  );

  router.delete(
    "/:id",
    async c => {

      await service.delete(
        c.req.param("id"),
      );

      return c.body(
        null,
        204,
      );
    },
  );

  return router;
}
`,
);

console.log('phase-7-user-crud completed');
