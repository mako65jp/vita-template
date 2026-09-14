// phase-8-jwt.mjs

import { mkdir, writeFile } from 'node:fs/promises';

async function dir(path) {
    await mkdir(path, {
        recursive: true,
    });
}

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

await dir('apps/api/src/features/authentication/services');

await dir('apps/api/src/features/authentication/middleware');

//
// Config.ts
//

await file(
    'apps/api/src/config/Config.ts',
    `
export interface DatabaseConfig {
  type: "memory" | "postgres" | "sqlserver";
  connectionString?: string;
}

export interface AuthenticationConfig {
  type: "none" | "jwt" | "oidc" | "ldap";
  secret?: string;
}

export interface FrontendConfig {
  type: "react" | "vue";
}

export interface Config {
  database: DatabaseConfig;
  authentication: AuthenticationConfig;
  frontend: FrontendConfig;
}
`,
);

//
// JwtService.ts
//

await file(
    'apps/api/src/features/authentication/services/JwtService.ts',
    `
import jwt from "jsonwebtoken";

export class JwtService {

  constructor(
    private readonly secret: string,
  ) {}

  createAccessToken(
    userId: number,
    email: string,
    role: string,
  ) {

    return jwt.sign(
      {
        sub: userId,
        email,
        role,
      },
      this.secret,
      {
        expiresIn: "1h",
      },
    );
  }

  verify(
    token: string,
  ) {
    return jwt.verify(
      token,
      this.secret,
    );
  }
}
`,
);

//
// AuthenticationService.ts
//

await file(
    'apps/api/src/features/authentication/services/AuthenticationService.ts',
    `
import bcrypt from "bcrypt";
import { UserService } from "../../user/services/UserService";
import { JwtService } from "./JwtService";

export class AuthenticationService {

  constructor(
    private readonly users: UserService,
    private readonly jwt: JwtService,
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

    return {
      accessToken:
        this.jwt.createAccessToken(
          user.id,
          user.email,
          user.role,
        ),
      expiresIn: 3600,
    };
  }
}
`,
);

//
// AuthenticationController.ts
//

await file(
    'apps/api/src/features/authentication/controllers/AuthenticationController.ts',
    `
import { Hono } from "hono";
import { AuthenticationService } from "../services/AuthenticationService";

export function createAuthenticationController(
  service: AuthenticationService,
) {

  const router = new Hono();

  router.post(
    "/login",
    async c => {

      const body =
        await c.req.json();

      const result =
        await service.login(
          body.email,
          body.password,
        );

      if (!result) {

        return c.json(
          {
            message:
              "Invalid credentials",
          },
          401,
        );
      }

      return c.json(
        result,
      );
    },
  );

  return router;
}
`,
);

//
// jwtAuthentication.ts
//

await file(
    'apps/api/src/features/authentication/middleware/jwtAuthentication.ts',
    `
import { Context, Next }
  from "hono";

import jwt
  from "jsonwebtoken";

export function jwtAuthentication(
  secret: string,
) {

  return async (
    c: Context,
    next: Next,
  ) => {

    const header =
      c.req.header(
        "Authorization",
      );

    if (
      !header ||
      !header.startsWith(
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
      header.replace(
        "Bearer ",
        "",
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
// DependencyContainer.ts
//

await file(
    'apps/api/src/app/DependencyContainer.ts',
    `
import { Database } from "../database/Database";
import { UserRepository } from "../features/user/repositories/UserRepository";
import { UserService } from "../features/user/services/UserService";
import { AuthenticationService } from "../features/authentication/services/AuthenticationService";
import { JwtService } from "../features/authentication/services/JwtService";

export class DependencyContainer {

  constructor(
    public readonly database: Database,
    public readonly userRepository: UserRepository,
    public readonly userService: UserService,
    public readonly jwtService: JwtService,
    public readonly authenticationService: AuthenticationService,
  ) {}
}
`,
);

//
// createContainer.ts
//

await file(
    'apps/api/src/app/createContainer.ts',
    `
import { Config } from "../config/Config";
import { createDatabase } from "../database/createDatabase";
import { DependencyContainer } from "./DependencyContainer";
import { UserRepositoryImpl } from "../features/user/repositories/UserRepositoryImpl";
import { UserService } from "../features/user/services/UserService";
import { AuthenticationService } from "../features/authentication/services/AuthenticationService";
import { JwtService } from "../features/authentication/services/JwtService";

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

  const jwtService =
    new JwtService(
      config.authentication.secret ??
      "change-this-secret",
    );

  const authenticationService =
    new AuthenticationService(
      userService,
      jwtService,
    );

  return new DependencyContainer(
    database,
    userRepository,
    userService,
    jwtService,
    authenticationService,
  );
}
`,
);

console.log('phase-8-jwt completed');
