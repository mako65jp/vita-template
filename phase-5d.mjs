// phase-5d.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// .env
//

await file(
    '.env',
    `
DATABASE_URL=postgres://postgres:postgres@localhost:5432/sample
`,
);

//
// drizzle/db.ts
//

await file(
    'apps/api/src/drizzle/db.ts',
    `
import "dotenv/config";

import { Pool }
  from "pg";

import { drizzle }
  from "drizzle-orm/node-postgres";

const pool =
  new Pool({
    connectionString:
      process.env.DATABASE_URL,
  });

export const db =
  drizzle(pool);

export { pool };
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

import { db }
  from "../drizzle/db";

export class DrizzleDatabase
implements Database {

  constructor(
    private readonly provider:
      "postgres"
      | "sqlserver",
  ) {}

  async query<T>(
    sql: string,
    params:
      readonly unknown[] = [],
  ): Promise<T[]> {

    console.log(
      "[DrizzleDatabase]",
      this.provider,
      sql,
      params,
    );

    const result =
      await db.execute(
        sql as any,
      );

    return result.rows as T[];
  }

  async execute(
    sql: string,
    _params:
      readonly unknown[] = [],
  ): Promise<number> {

    console.log(
      "[DrizzleDatabase]",
      this.provider,
      sql,
    );

    const result =
      await db.execute(
        sql as any,
      );

    return result.rowCount ?? 0;
  }

  async beginTransaction() {}

  async commit() {}

  async rollback() {}
}
`,
);

console.log('phase-5d completed');
