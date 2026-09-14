// phase-8-authentication-basic-complete.mjs

import { mkdir, writeFile } from 'node:fs/promises';

async function dir(path) {
    await mkdir(path, { recursive: true });
}

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await dir('apps/api/src/features/authentication/controllers');

await dir('apps/api/src/features/authentication/services');

//
// AuthenticationService
//

await file(
    'apps/api/src/features/authentication/services/AuthenticationService.ts',
    `
import bcrypt from "bcrypt";
import { UserService } from "../../user/services/UserService";

export class AuthenticationService {

  constructor(
    private readonly users: UserService,
  ) {}

  async login(
    email: string,
    password: string,
  ) {

    const user =
      await this.users.findByEmail(
        email,
      );

    if (!user) {
      return undefined;
    }

    const matched =
      await bcrypt.compare(
        password,
        user.passwordHash,
      );

    if (!matched) {
      return undefined;
    }

    return user;
  }
}
`,
);

//
// AuthenticationController
//

await file(
    'apps/api/src/features/authentication/controllers/AuthenticationController.ts',
    `
import { Hono } from "hono";

import { AuthenticationService }
  from "../services/AuthenticationService";

import { UserMapper }
  from "../../user/mappers/UserMapper";

export function createAuthenticationController(
  service: AuthenticationService,
) {

  const router = new Hono();

  router.post(
    "/login",
    async c => {

      const body =
        await c.req.json();

      const user =
        await service.login(
          body.email,
          body.password,
        );

      if (!user) {

        return c.json(
          {
            message:
              "Invalid credentials",
          },
          401,
        );
      }

      return c.json(
        UserMapper.toDto(
          user,
        ),
      );
    },
  );

  return router;
}
`,
);

//
// UserRepository.ts
//

await file(
    'apps/api/src/features/user/repositories/UserRepository.ts',
    `
import { User } from "../domain/User";

export interface UserRepository {

  findById(
    id: string,
  ): Promise<User | undefined>;

  findByEmail(
    email: string,
  ): Promise<User | undefined>;

  findAll():
    Promise<User[]>;

  create(
    user: User,
  ): Promise<void>;

  save(
    user: User,
  ): Promise<void>;

  remove(
    id: string,
  ): Promise<void>;
}
`,
);

//
// UserService.ts
//

await file(
    'apps/api/src/features/user/services/UserService.ts',
    `
import { User }
  from "../domain/User";

import { UserRepository }
  from "../repositories/UserRepository";

export class UserService {

  constructor(
    private readonly users: UserRepository,
  ) {}

  async findById(
    id: string,
  ) {
    return this.users.findById(id);
  }

  async findByEmail(
    email: string,
  ) {
    return this.users.findByEmail(email);
  }

  async findAll() {
    return this.users.findAll();
  }

  async create(
    user: User,
  ) {
    await this.users.create(user);
  }

  async update(
    user: User,
  ) {
    await this.users.save(user);
  }

  async delete(
    id: string,
  ) {
    await this.users.remove(id);
  }
}
`,
);

//
// DependencyContainer
//

await file(
    'apps/api/src/app/DependencyContainer.ts',
    `
import { Database } from "../database/Database";

import { UserRepository }
  from "../features/user/repositories/UserRepository";

import { UserService }
  from "../features/user/services/UserService";

import { AuthenticationService }
  from "../features/authentication/services/AuthenticationService";

export class DependencyContainer {

  constructor(
    public readonly database: Database,

    public readonly userRepository: UserRepository,

    public readonly userService: UserService,

    public readonly authenticationService:
      AuthenticationService,
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
import { Config }
  from "../config/Config";

import { createDatabase }
  from "../database/createDatabase";

import { DependencyContainer }
  from "./DependencyContainer";

import { UserRepositoryImpl }
  from "../features/user/repositories/UserRepositoryImpl";

import { UserService }
  from "../features/user/services/UserService";

import { AuthenticationService }
  from "../features/authentication/services/AuthenticationService";

export async function createContainer(
  config: Config,
): Promise<DependencyContainer> {

  const database =
    await createDatabase(
      config.database,
    );

  const userRepository =
    new UserRepositoryImpl(
      database,
    );

  const userService =
    new UserService(
      userRepository,
    );

  const authenticationService =
    new AuthenticationService(
      userService,
    );

  return new DependencyContainer(
    database,
    userRepository,
    userService,
    authenticationService,
  );
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

import { DependencyContainer }
  from "./DependencyContainer";

import { createUserController }
  from "../features/user/controllers/UserController";

import { createAuthenticationController }
  from "../features/authentication/controllers/AuthenticationController";

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
    "/users",
    createUserController(
      container.userService,
    ),
  );

  app.route(
    "/auth",
    createAuthenticationController(
      container.authenticationService,
    ),
  );

  return app;
}
`,
);

console.log('phase-8-authentication-basic-complete completed');
