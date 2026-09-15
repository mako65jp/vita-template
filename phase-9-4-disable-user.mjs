// phase-9-4-disable-user.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

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

    if (!user.isActive) {
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

await file(
    'apps/api/src/features/authentication/middleware/jwtAuthentication.ts',
    `
import { Context, Next } from "hono";
import jwt from "jsonwebtoken";
import { UserRepositoryImpl } from "../../user/repositories/UserRepositoryImpl";

export function jwtAuthentication(
  secret: string,
  userRepository: UserRepositoryImpl,
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

      const user =
        await userRepository.findById(
          String(
            (payload as any).sub,
          ),
        );

      if (
        !user ||
        !user.isActive
      ) {

        return c.json(
          {
            message:
              "Account disabled",
          },
          403,
        );
      }

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

console.log('phase-9-4-disable-user completed');
