// phase-3.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// createDatabase
//

await file(
    'apps/api/src/database/createDatabase.ts',
    `
import { Database }
  from "./Database";

import { InMemoryDatabase }
  from "./InMemoryDatabase";

export async function
createDatabase()
: Promise<Database> {

  return new InMemoryDatabase();
}
`,
);

//
// DependencyContainer
//

await file(
    'apps/api/src/app/DependencyContainer.ts',
    `
import { Database }
  from "../database/Database";

import {
  UserRepository
}
from "../features/user/repositories/UserRepository";

import {
  UserService
}
from "../features/user/services/UserService";

export class
DependencyContainer {

  constructor(

    public readonly database:
      Database,

    public readonly userRepository:
      UserRepository,

    public readonly userService:
      UserService,
  ) {}
}
`,
);

//
// createContainer
//

await file(
    'apps/api/src/app/createContainer.ts',
    `
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
createContainer()
: Promise<
  DependencyContainer
> {

  const database =
    await createDatabase();

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
// UserRepositoryImpl
//

await file(
    'apps/api/src/features/user/repositories/UserRepositoryImpl.ts',
    `
import { Database }
  from "../../../database/Database";

import { User }
  from "../domain/User";

import {
  UserRepository
}
from "./UserRepository";

export class
UserRepositoryImpl
implements UserRepository {

  constructor(
    private readonly db:
      Database,
  ) {}

  async findById(
    id: string,
  ) {

    return new User(
      id,
      "Administrator",
    );
  }

  async findAll() {

    return [
      new User(
        "1",
        "Administrator",
      ),
    ];
  }

  async save(
    _user: User,
  ) {}

  async remove(
    _id: string,
  ) {}
}
`,
);

//
// UserService
//

await file(
    'apps/api/src/features/user/services/UserService.ts',
    `
import {
  UserRepository
}
from "../repositories/UserRepository";

export class UserService {

  constructor(
    private readonly users:
      UserRepository,
  ) {}

  async findById(
    id: string,
  ) {

    return this.users.findById(
      id,
    );
  }
}
`,
);

//
// UserController
//

await file(
    'apps/api/src/features/user/controllers/UserController.ts',
    `
import { Hono }
  from "hono";

import {
  UserService
}
from "../services/UserService";

export function
createUserController(
  service: UserService,
) {

  const router =
    new Hono();

  router.get(
    "/:id",
    async c => {

      const user =
        await service.findById(
          c.req.param("id"),
        );

      if (!user) {
        return c.notFound();
      }

      return c.json({
        id: user.id,
        name: user.name,
      });
    },
  );

  return router;
}
`,
);

//
// createApp
//

await file(
    'apps/api/src/app/createApp.ts',
    `
import { Hono }
  from "hono";

import {
  DependencyContainer
}
from "./DependencyContainer";

import {
  createUserController
}
from "../features/user/controllers/UserController";

export function
createApp(
  container:
    DependencyContainer,
) {

  const app =
    new Hono();

  app.get(
    "/",
    c =>
      c.text(
        "Hello World",
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

//
// main.ts
//

await file(
    'apps/api/src/main.ts',
    `
import { serve }
  from "@hono/node-server";

import {
  createContainer
}
from "./app/createContainer";

import {
  createApp
}
from "./app/createApp";

const container =
  await createContainer();

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

console.log('phase-3 completed');
