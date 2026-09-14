// phase-9-authorization.mjs

import { mkdir, writeFile } from 'node:fs/promises';

async function dir(path) {
    await mkdir(path, {
        recursive: true,
    });
}

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await dir('apps/api/src/features/authentication/middleware');

//
// authorize.ts
//

await file(
    'apps/api/src/features/authentication/middleware/authorize.ts',
    `
import { Context, Next }
  from "hono";

export function authorize(
  ...roles: string[]
) {

  return async (
    c: Context,
    next: Next,
  ) => {

    const payload =
      c.get("jwt");

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

//
// UserController.ts
//

await file(
    'apps/api/src/features/user/controllers/UserController.ts',
    `
import { Hono } from "hono";
import bcrypt from "bcrypt";

import { User } from "../domain/User";
import { UserService } from "../services/UserService";
import { UserMapper } from "../mappers/UserMapper";

import { authorize }
  from "../../authentication/middleware/authorize";

export function createUserController(
  service: UserService,
) {

  const router =
    new Hono();

  router.get(
    "/",
    authorize("admin"),
    async c => {

      const users =
        await service.findAll();

      return c.json(
        users.map(
          user =>
            UserMapper.toDto(user),
        ),
      );
    },
  );

  router.get(
    "/:id",
    authorize(
      "admin",
      "user",
    ),
    async c => {

      const user =
        await service.findById(
          c.req.param("id"),
        );

      if (!user) {
        return c.notFound();
      }

      return c.json(
        UserMapper.toDto(
          user,
        ),
      );
    },
  );

  router.post(
    "/",
    authorize("admin"),
    async c => {

      const body =
        await c.req.json();

      const passwordHash =
        await bcrypt.hash(
          body.password,
          10,
        );

      const user =
        new User(
          0,
          body.name,
          body.email,
          passwordHash,
          body.role ?? "user",
          true,
          new Date(),
        );

      await service.create(
        user,
      );

      return c.json(
        {
          message:
            "created",
        },
        201,
      );
    },
  );

  router.put(
    "/:id",
    authorize("admin"),
    async c => {

      const current =
        await service.findById(
          c.req.param("id"),
        );

      if (!current) {
        return c.notFound();
      }

      const body =
        await c.req.json();

      const user =
        new User(
          current.id,
          body.name,
          body.email,
          current.passwordHash,
          body.role,
          body.isActive,
          current.createdAt,
        );

      await service.update(
        user,
      );

      return c.json(
        {
          message:
            "updated",
        },
      );
    },
  );

  router.put(
    "/:id/password",
    authorize("admin"),
    async c => {

      const body =
        await c.req.json();

      const passwordHash =
        await bcrypt.hash(
          body.password,
          10,
        );

      await service.changePassword(
        c.req.param("id"),
        passwordHash,
      );

      return c.json(
        {
          message:
            "password updated",
        },
      );
    },
  );

  router.delete(
    "/:id",
    authorize("admin"),
    async c => {

      await service.delete(
        c.req.param("id"),
      );

      return c.body(
        null,
        204,
      );
    },
  );

  return router;
}
`,
);

console.log('phase-9-authorization completed');
