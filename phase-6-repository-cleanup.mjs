// phase-6-repository-cleanup.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// UserRepositoryImpl
//

await file(
    'apps/api/src/features/user/repositories/UserRepositoryImpl.ts',
    `
import { Database }
  from "../../../database/Database";

import { User }
  from "../domain/User";

import {
  UserRepository
}
from "./UserRepository";

export class UserRepositoryImpl
implements UserRepository {

  constructor(
    private readonly db:
      Database,
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
          password_hash
            as "passwordHash",
          role,
          is_active
            as "isActive",
          created_at
            as "createdAt"
        from public.users
        where id = $1
        \`,
        [
          Number(id),
        ],
      );

    return rows[0];
  }

  async findAll() {

    const rows =
      await this.db.query<User>(
        \`
        select
          id,
          name,
          email,
          password_hash
            as "passwordHash",
          role,
          is_active
            as "isActive",
          created_at
            as "createdAt"
        from public.users
        order by id
        \`,
      );

    return rows;
  }

  async save(
    _user: User,
  ) {

    throw new Error(
      "Not implemented",
    );
  }

  async remove(
    _id: string,
  ) {

    throw new Error(
      "Not implemented",
    );
  }
}
`,
);

//
// DrizzleDatabase
//

await file(
    'apps/api/src/database/DrizzleDatabase.ts',
    `
import { Pool }
  from "pg";

import { Database }
  from "./Database";

export class DrizzleDatabase
implements Database {

  private readonly pool:
    Pool;

  constructor(
    connectionString:
      string,
  ) {

    this.pool =
      new Pool({
        connectionString,
      });
  }

  async query<T>(
    sql: string,
    params:
      readonly unknown[] = [],
  ): Promise<T[]> {

    const result =
      await this.pool.query(
        sql,
        [...params],
      );

    return result.rows
      as T[];
  }

  async execute(
    sql: string,
    params:
      readonly unknown[] = [],
  ): Promise<number> {

    const result =
      await this.pool.query(
        sql,
        [...params],
      );

    return result.rowCount
      ?? 0;
  }

  async beginTransaction() {

    await this.pool.query(
      "BEGIN",
    );
  }

  async commit() {

    await this.pool.query(
      "COMMIT",
    );
  }

  async rollback() {

    await this.pool.query(
      "ROLLBACK",
    );
  }
}
`,
);

console.log('phase-6-repository-cleanup completed');
