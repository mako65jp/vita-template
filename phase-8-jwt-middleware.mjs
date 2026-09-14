// phase-8-jwt-middleware.mjs

import { mkdir, writeFile } from 'node:fs/promises';

async function dir(path) {
    await mkdir(path, { recursive: true });
}

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await dir('apps/api/src/features/authentication/middleware');

//
// jwtAuthentication.ts
//

await file(
    'apps/api/src/features/authentication/middleware/jwtAuthentication.ts',
    `
import { Context, Next } from "hono";
import jwt from "jsonwebtoken";

export function jwtAuthentication(
  secret: string,
) {

  return async (
    c: Context,
    next: Next,
  ) => {

    const authorization =
      c.req.header(
        "Authorization",
      );

    if (
      !authorization ||
      !authorization.startsWith(
        "Bearer ",
      )
    ) {

      return c.json(
        {
          message:
            "Unauthorized",
        },
        401,
      );
    }

    const token =
      authorization.substring(
        7,
      );

    try {

      const payload =
        jwt.verify(
          token,
          secret,
        );

      c.set(
        "jwt",
        payload,
      );

      await next();

    } catch {

      return c.json(
        {
          message:
            "Unauthorized",
        },
        401,
      );
    }
  };
}
`,
);

//
// createApp.ts
//

await file(
    'apps/api/src/app/createApp.ts',
    `
import { Hono } from "hono";

import { DependencyContainer }
  from "./DependencyContainer";

import { createUserController }
  from "../features/user/controllers/UserController";

import { createAuthenticationController }
  from "../features/authentication/controllers/AuthenticationController";

import { jwtAuthentication }
  from "../features/authentication/middleware/jwtAuthentication";

export function createApp(
  container: DependencyContainer,
) {

  const app =
    new Hono();

  app.get(
    "/",
    c => c.text(
      "Hello World",
    ),
  );

  app.route(
    "/auth",
    createAuthenticationController(
      container.authenticationService,
    ),
  );

  app.use(
    "/users/*",
    jwtAuthentication(
      "change-this-secret",
    ),
  );

  app.route(
    "/users",
    createUserController(
      container.userService,
    ),
  );

  return app;
}
`,
);

console.log('phase-8-jwt-middleware completed');
``;
