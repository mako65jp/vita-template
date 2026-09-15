// phase-9-5-jwt-types.mjs

import { mkdir, writeFile } from 'node:fs/promises';

async function dir(path) {
    await mkdir(path, {
        recursive: true,
    });
}

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await dir('apps/api/src/features/authentication');

await file(
    'apps/api/src/features/authentication/JwtPayload.ts',
    `
export interface JwtPayload {
  sub: number;
  email: string;
  role: string;
  iat?: number;
  exp?: number;
}
`,
);

await file(
    'apps/api/src/features/authentication/AppVariables.ts',
    `
import { JwtPayload }
  from "./JwtPayload";

export interface AppVariables {
  jwt: JwtPayload;
}
`,
);

await file(
    'apps/api/src/features/authentication/middleware/authorize.ts',
    `
import { Context, Next } from "hono";
import { JwtPayload } from "../JwtPayload";

export function authorize(
  ...roles: string[]
) {

  return async (
    c: Context,
    next: Next,
  ) => {

    const payload =
      c.get("jwt" as never)
        as JwtPayload;

    const role =
      payload?.role;

    if (
      !role ||
      !roles.includes(role)
    ) {

      return c.json(
        {
          message:
            "Forbidden",
        },
        403,
      );
    }

    await next();
  };
}
`,
);

await file(
    'apps/api/src/features/authentication/middleware/authorizeSelfOrAdmin.ts',
    `
import { Context, Next } from "hono";
import { JwtPayload } from "../JwtPayload";

export function authorizeSelfOrAdmin() {

  return async (
    c: Context,
    next: Next,
  ) => {

    const jwt =
      c.get("jwt" as never)
        as JwtPayload;

    if (!jwt) {

      return c.json(
        {
          message:
            "Unauthorized",
        },
        401,
      );
    }

    if (
      jwt.role === "admin"
    ) {

      await next();
      return;
    }

    const id =
      c.req.param("id");

    if (
      String(jwt.sub) !== id
    ) {

      return c.json(
        {
          message:
            "Forbidden",
        },
        403,
      );
    }

    await next();
  };
}
`,
);

console.log('phase-9-5-jwt-types completed');
