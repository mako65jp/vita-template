// phase-5-config-separation.mjs

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
import { Database }
  from "./Database";

export class DrizzleDatabase
implements Database {

  constructor(
    private readonly provider:
      | "postgres"
      | "sqlserver",
  ) {}

  async query<T>(
    _sql: string,
    _params:
      readonly unknown[] = [],
  ): Promise<T[]> {

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
        "postgres",
      );

    case "sqlserver":

      return new DrizzleDatabase(
        "sqlserver",
      );

    default:

      throw new Error(
        \`Unknown database type: \${config.type}\`,
      );
  }
}
`,
);

//
// createContainer.ts
//

await file(
    'apps/api/src/app/createContainer.ts',
    `
import { Config }
  from "../config/Config";

import {
  createDatabase
}
from "../database/createDatabase";

import {
  DependencyContainer
}
from "./DependencyContainer";

import {
  UserRepositoryImpl
}
from "../features/user/repositories/UserRepositoryImpl";

import {
  UserService
}
from "../features/user/services/UserService";

export async function
createContainer(
  config: Config,
): Promise<
  DependencyContainer
> {

  const database =
    await createDatabase(
      config.database,
    );

  const userRepository =
    new UserRepositoryImpl(
      database,
    );

  const userService =
    new UserService(
      userRepository,
    );

  return new DependencyContainer(
    database,
    userRepository,
    userService,
  );
}
`,
);

//
// main.ts
//

await file(
    'apps/api/src/main.ts',
    `
import { serve }
  from "@hono/node-server";

import {
  loadConfig
}
from "./config/loadConfig";

import {
  createContainer
}
from "./app/createContainer";

import {
  createApp
}
from "./app/createApp";

const config =
  await loadConfig();

const container =
  await createContainer(
    config,
  );

const app =
  createApp(
    container,
  );

serve({
  fetch: app.fetch,
  port: 3000,
});

console.log(
  "Listening on :3000",
);
`,
);

//
// drizzle/db.ts
//

await file(
    'apps/api/src/drizzle/db.ts',
    `
export interface DrizzleConnection {

}
`,
);

//
// drizzle/index.ts
//

await file(
    'apps/api/src/drizzle/index.ts',
    `
export * from "./db";
export * from "./schema";
`,
);

console.log('phase-5-config-separation completed');
