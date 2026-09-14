// phase-5b.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await file(
    'apps/api/src/database/createDatabase.ts',
    `
import { Database }
  from "./Database";

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

    case "memory": {

      const {
        InMemoryDatabase
      } =
        await import(
          "./InMemoryDatabase"
        );

      return new InMemoryDatabase();
    }

    case "postgres": {

      const {
        PostgreSqlDatabase
      } =
        await import(
          "./PostgreSqlDatabase"
        );

      return new PostgreSqlDatabase();
    }

    case "sqlserver": {

      const {
        SqlServerDatabase
      } =
        await import(
          "./SqlServerDatabase"
        );

      return new SqlServerDatabase();
    }

    default:

      throw new Error(
        "Unknown database type",
      );
  }
}
`,
);

console.log('phase-5b completed');
``;
