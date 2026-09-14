// phase-5a.mjs

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
export interface Config {

  database: {

    type:
      | "memory"
      | "postgres"
      | "sqlserver";
  };

  authentication: {

    type:
      | "none"
      | "jwt"
      | "oidc"
      | "ldap";
  };

  frontend: {

    type:
      | "react"
      | "vue";
  };
}
`,
);

//
// loadConfig.ts
//

await file(
    'apps/api/src/config/loadConfig.ts',
    `
import { readFile }
  from "node:fs/promises";

import { Config }
  from "./Config";

export async function
loadConfig()
: Promise<Config> {

  const json =
    await readFile(
      "./config/development.json",
      "utf8",
    );

  return JSON.parse(
    json,
  ) as Config;
}
`,
);

//
// PostgreSqlDatabase
//

await file(
    'apps/api/src/database/PostgreSqlDatabase.ts',
    `
import { Database }
  from "./Database";

export class PostgreSqlDatabase
implements Database {

  constructor() {

    console.log(
      "PostgreSQL selected",
    );
  }

  async query<T>() {

    return [] as T[];
  }

  async execute() {

    return 0;
  }

  async beginTransaction() {}

  async commit() {}

  async rollback() {}
}
`,
);

//
// SqlServerDatabase
//

await file(
    'apps/api/src/database/SqlServerDatabase.ts',
    `
import { Database }
  from "./Database";

export class SqlServerDatabase
implements Database {

  constructor() {

    console.log(
      "SQL Server selected",
    );
  }

  async query<T>() {

    return [] as T[];
  }

  async execute() {

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
  PostgreSqlDatabase
}
from "./PostgreSqlDatabase";

import {
  SqlServerDatabase
}
from "./SqlServerDatabase";

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

      return new PostgreSqlDatabase();

    case "sqlserver":

      return new SqlServerDatabase();

    default:

      throw new Error(
        "Unknown database type",
      );
  }
}
`,
);

console.log('phase-5a completed');
