// phase-5-postgres.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// Config.ts
//

await file(
    'apps/api/src/config/Config.ts',
    `
export interface DatabaseConfig {

  type:
    | "memory"
    | "postgres"
    | "sqlserver";

  connectionString?:
    string;
}

export interface AuthenticationConfig {

  type:
    | "none"
    | "jwt"
    | "oidc"
    | "ldap";
}

export interface FrontendConfig {

  type:
    | "react"
    | "vue";
}

export interface Config {

  database:
    DatabaseConfig;

  authentication:
    AuthenticationConfig;

  frontend:
    FrontendConfig;
}
`,
);

//
// DrizzleDatabase.ts
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

    //
    // UserRepositoryImpl
    // の現在の呼び出しに合わせる
    //

    if (
      sql === "users"
    ) {

      const result =
        await this.pool.query(
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
          [
            Number(
              params[0],
            ),
          ],
        );

      return result.rows as T[];
    }

    return [];
  }

  async execute(
    _sql: string,
    _params:
      readonly unknown[] = [],
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
// createDatabase.ts
//

await file(
    'apps/api/src/database/createDatabase.ts',
    `
import { Database }
  from "./Database";

import {
  DatabaseConfig
}
from "../config/Config";

import {
  InMemoryDatabase
}
from "./InMemoryDatabase";

import {
  DrizzleDatabase
}
from "./DrizzleDatabase";

export async function
createDatabase(
  config:
    DatabaseConfig,
): Promise<Database> {

  switch (
    config.type
  ) {

    case "memory":

      return new InMemoryDatabase();

    case "postgres":

      return new DrizzleDatabase(
        config.connectionString ??
          "",
      );

    case "sqlserver":

      throw new Error(
        "SQL Server not implemented",
      );

    default:

      throw new Error(
        \`Unknown database type:
          \${config.type}\`,
      );
  }
}
`,
);

console.log('phase-5-postgres completed');
