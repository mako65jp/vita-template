// phase-5c.mjs

import { mkdir, writeFile } from 'node:fs/promises';

async function dir(path) {
    await mkdir(path, {
        recursive: true,
    });
}

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// drizzle directory
//

await dir('apps/api/src/drizzle');

//
// schema.ts
//

await file(
    'apps/api/src/drizzle/schema.ts',
    `
export const tables = {

  users: "users",
};
`,
);

//
// db.ts
//

await file(
    'apps/api/src/drizzle/db.ts',
    `
export interface DrizzleConnection {

}
`,
);

//
// index.ts
//

await file(
    'apps/api/src/drizzle/index.ts',
    `
export * from "./db";
export * from "./schema";
`,
);

//
// DrizzleDatabase
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
      "postgres" | "sqlserver",
  ) {}

  async query<T>(
    _sql: string,
    _params:
      readonly unknown[] = [],
  ): Promise<T[]> {

    console.log(
      "DrizzleDatabase:",
      this.provider,
    );

    return [];
  }

  async execute(
    _sql: string,
    _params:
      readonly unknown[] = [],
  ): Promise<number> {

    console.log(
      "DrizzleDatabase:",
      this.provider,
    );

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
  InMemoryDatabase
}
from "./InMemoryDatabase";

import {
  DrizzleDatabase
}
from "./DrizzleDatabase";

import {
  loadConfig
}
from "../config/loadConfig";

export async function
createDatabase()
: Promise<Database> {

  const config =
    await loadConfig();

  switch (
    config.database.type
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
        "Unknown database type",
      );
  }
}
`,
);

console.log('phase-5c completed');
