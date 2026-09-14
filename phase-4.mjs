// phase-4.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// InMemoryDatabase
//

await file(
    'apps/api/src/database/InMemoryDatabase.ts',
    `
import { Database }
  from "./Database";

import { User }
  from "../features/user/domain/User";

export class InMemoryDatabase
implements Database {

  private readonly users =
    new Map<string, User>();

  constructor() {

    this.users.set(
      "1",
      new User(
        "1",
        "Administrator",
      ),
    );

    this.users.set(
      "2",
      new User(
        "2",
        "Test User",
      ),
    );
  }

  async query<T>(
    sql: string,
    params:
      readonly unknown[] = [],
  ): Promise<T[]> {

    switch (sql) {

      case "users": {

        const id =
          params[0] as string;

        const user =
          this.users.get(id);

        return user
          ? [user as T]
          : [];
      }

      default:
        return [];
    }
  }

  async execute(
    _sql: string,
  ): Promise<number> {

    return 0;
  }

  async beginTransaction() {}

  async commit() {}

  async rollback() {}
}
`,
);

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
        "users",
        [id],
      );

    return rows[0];
  }

  async findAll() {

    return [];
  }

  async save(
    _user: User,
  ) {

  }

  async remove(
    _id: string,
  ) {

  }
}
`,
);

console.log('phase-4 completed');
