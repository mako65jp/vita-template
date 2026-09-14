// part-4.mjs

import { writeFile } from 'node:fs/promises';

export async function run() {
    async function file(path, content = '') {
        await writeFile(path, content.trimStart(), 'utf8');
    }

    //
    // package.json
    //

    await file(
        'package.json',
        `
{
  "name": "generated-project",

  "private": true,

  "type": "module",

  "scripts": {

    "dev":
      "tsx apps/api/src/main.ts",

    "check":
      "tsc --noEmit",

    "build":
      "tsc"
  },

  "dependencies": {

    "hono":
      "^4.9.6",

    "@hono/node-server":
      "^1.19.0"
  },

  "devDependencies": {

    "tsx":
      "^4.20.5",

    "typescript":
      "^5.9.2",

    "@types/node":
      "^24.4.0"
  }
}
`,
    );

    //
    // tsconfig.base.json
    //

    await file(
        'tsconfig.base.json',
        `
{
  "compilerOptions": {

    "target":
      "ES2022",

    "module":
      "NodeNext",

    "moduleResolution":
      "NodeNext",

    "strict":
      true,

    "skipLibCheck":
      true,

    "esModuleInterop":
      true,

    "forceConsistentCasingInFileNames":
      true
  }
}
`,
    );

    //
    // tsconfig.json
    //

    await file(
        'tsconfig.json',
        `
{
  "extends":
    "./tsconfig.base.json",

  "include": [
    "apps/**/*",
    "packages/**/*"
  ]
}
`,
    );

    //
    // createApp.ts
    //

    await file(
        'apps/api/src/app/createApp.ts',
        `
import { Hono }
  from "hono";

export function createApp() {

  const app =
    new Hono();

  app.get(
    "/",
    c =>
      c.text(
        "Hello World",
      ),
  );

  return app;
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

import { createApp }
  from "./app/createApp";

const app =
  createApp();

serve({
  fetch: app.fetch,
  port: 3000,
});

console.log(
  "Listening on :3000",
);
`,
    );

    console.log('part-4 completed');
}
