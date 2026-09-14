// phase-8-user-password-hash.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await file(
    'apps/api/src/features/user/controllers/UserController.ts',
    `
import { Hono } from "hono";
import bcrypt from "bcrypt";

import { User } from "../domain/User";
import { UserService } from "../services/UserService";
import { UserMapper } from "../mappers/UserMapper";

export function createUserController(
  service: UserService,
) {

  const router = new Hono();

  router.get("/", async c => {
    const users = await service.findAll();

    return c.json(
      users.map(
        user => UserMapper.toDto(user),
      ),
    );
  });

  router.get("/:id", async c => {
    const user = await service.findById(
      c.req.param("id"),
    );

    if (!user) {
      return c.notFound();
    }

    return c.json(
      UserMapper.toDto(user),
    );
  });

  router.post("/", async c => {

    const body = await c.req.json();

    const passwordHash =
      await bcrypt.hash(
        body.password,
        10,
      );

    const user = new User(
      0,
      body.name,
      body.email,
      passwordHash,
      body.role ?? "user",
      true,
      new Date(),
    );

    await service.create(user);

    return c.json(
      { message: "created" },
      201,
    );
  });

  router.put("/:id", async c => {

    const current =
      await service.findById(
        c.req.param("id"),
      );

    if (!current) {
      return c.notFound();
    }

    const body = await c.req.json();

    const user = new User(
      current.id,
      body.name,
      body.email,
      current.passwordHash,
      body.role,
      body.isActive,
      current.createdAt,
    );

    await service.update(user);

    return c.json({
      message: "updated",
    });
  });

  router.delete("/:id", async c => {

    await service.delete(
      c.req.param("id"),
    );

    return c.body(
      null,
      204,
    );
  });

  return router;
}
`,
);

console.log('phase-8-user-password-hash completed');
