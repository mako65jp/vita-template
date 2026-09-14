// part-1.mjs

import { mkdir, writeFile } from 'node:fs/promises';

export async function run() {
    async function dir(path) {
        await mkdir(path, {
            recursive: true,
        });
    }

    async function file(path, content = '') {
        await writeFile(path, content.trimStart(), 'utf8');
    }

    //
    // app
    //

    await dir('apps/api/src/app');

    await file(
        'apps/api/src/app/AppContext.ts',
        `
export interface AppContext {
}
`,
    );

    await file(
        'apps/api/src/app/DependencyContainer.ts',
        `
export class DependencyContainer {
}
`,
    );

    await file(
        'apps/api/src/app/createContainer.ts',
        `
export async function createContainer() {
}
`,
    );

    await file(
        'apps/api/src/app/createApp.ts',
        `
import { Hono } from "hono";

export function createApp() {
  return new Hono();
}
`,
    );

    //
    // config
    //

    await dir('apps/api/src/config');

    await file(
        'apps/api/src/config/Config.ts',
        `
export interface Config {

  database: {
    type:
      | "memory"
      | "postgres"
      | "sqlserver";
  };

  authentication: {
    type:
      | "none"
      | "jwt"
      | "oidc"
      | "ldap";
  };

  frontend: {
    type:
      | "react"
      | "vue";
  };
}
`,
    );

    await file(
        'apps/api/src/config/loadConfig.ts',
        `
export async function loadConfig() {
  throw new Error(
    "Not implemented."
  );
}
`,
    );

    await file(
        'apps/api/src/config/saveConfig.ts',
        `
export async function saveConfig() {
  throw new Error(
    "Not implemented."
  );
}
`,
    );

    //
    // database
    //

    await dir('apps/api/src/database');

    await file(
        'apps/api/src/database/Database.ts',
        `
export interface Database {

  query<T>(
    sql: string,
    params?: readonly unknown[],
  ): Promise<T[]>;

  execute(
    sql: string,
    params?: readonly unknown[],
  ): Promise<number>;

  beginTransaction():
    Promise<void>;

  commit():
    Promise<void>;

  rollback():
    Promise<void>;
}
`,
    );

    await file(
        'apps/api/src/database/createDatabase.ts',
        `
import { Database }
  from "./Database";

export async function createDatabase()
: Promise<Database> {

  throw new Error(
    "Not implemented."
  );
}
`,
    );

    await file(
        'apps/api/src/database/PostgreSqlDatabase.ts',
        `
import { Database }
  from "./Database";

export class PostgreSqlDatabase
implements Database {

  async query<T>() {
    return [] as T[];
  }

  async execute() {
    return 0;
  }

  async beginTransaction() {}

  async commit() {}

  async rollback() {}
}
`,
    );

    await file(
        'apps/api/src/database/SqlServerDatabase.ts',
        `
import { Database }
  from "./Database";

export class SqlServerDatabase
implements Database {

  async query<T>() {
    return [] as T[];
  }

  async execute() {
    return 0;
  }

  async beginTransaction() {}

  async commit() {}

  async rollback() {}
}
`,
    );

    await file(
        'apps/api/src/database/InMemoryDatabase.ts',
        `
import { Database }
  from "./Database";

export class InMemoryDatabase
implements Database {

  async query<T>() {
    return [] as T[];
  }

  async execute() {
    return 0;
  }

  async beginTransaction() {}

  async commit() {}

  async rollback() {}
}
`,
    );

    //
    // common
    //

    await dir('apps/api/src/common/repositories');

    await dir('apps/api/src/common/middleware');

    await dir('apps/api/src/common/errors');

    await file(
        'apps/api/src/common/repositories/Repository.ts',
        `
export interface Repository<TEntity> {
}
`,
    );

    await file(
        'apps/api/src/common/repositories/BaseRepository.ts',
        `
export abstract class BaseRepository<TEntity> {
}
`,
    );

    await file(
        'apps/api/src/common/middleware/errorHandler.ts',
        `
export function errorHandler() {
}
`,
    );

    await file(
        'apps/api/src/common/middleware/authentication.ts',
        `
export function authentication() {
}
`,
    );

    await file(
        'apps/api/src/common/middleware/authorization.ts',
        `
export function authorization() {
}
`,
    );

    await file(
        'apps/api/src/common/middleware/featureGuard.ts',
        `
export function featureGuard() {
}
`,
    );

    //
    // authentication
    //

    await dir('apps/api/src/features/authentication/domain');

    await dir('apps/api/src/features/authentication/providers');

    await dir('apps/api/src/features/authentication/services');

    await dir('apps/api/src/features/authentication/controllers');

    await file(
        'apps/api/src/features/authentication/domain/UserPrincipal.ts',
        `
export interface UserPrincipal {

  userId: string;

  userName: string;

  roles: readonly string[];
}
`,
    );

    await file(
        'apps/api/src/features/authentication/providers/AuthenticationProvider.ts',
        `
import { UserPrincipal }
  from "../domain/UserPrincipal";

export interface AuthenticationProvider {

  authenticate(
    request: Request,
  ): Promise<
    UserPrincipal | null
  >;
}
`,
    );

    await file(
        'apps/api/src/features/authentication/services/AuthenticationService.ts',
        `
export class AuthenticationService {
}
`,
    );

    await file(
        'apps/api/src/features/authentication/controllers/AuthenticationController.ts',
        `
import { Hono } from "hono";

export const authenticationRouter =
  new Hono();
`,
    );

    await file(
        'apps/api/src/features/authentication/routes.ts',
        `
import { Hono } from "hono";

export const routes =
  new Hono();
`,
    );

    //
    // authorization
    //

    await dir('apps/api/src/features/authorization/domain');

    await dir('apps/api/src/features/authorization/repositories');

    await dir('apps/api/src/features/authorization/services');

    await dir('apps/api/src/features/authorization/controllers');

    await file(
        'apps/api/src/features/authorization/domain/Role.ts',
        `
export interface Role {
  name: string;
}
`,
    );

    await file(
        'apps/api/src/features/authorization/domain/Permission.ts',
        `
export interface Permission {
  name: string;
}
`,
    );

    await file(
        'apps/api/src/features/authorization/repositories/RoleRepository.ts',
        `
export interface RoleRepository {
}
`,
    );

    await file(
        'apps/api/src/features/authorization/services/AuthorizationService.ts',
        `
export class AuthorizationService {
}
`,
    );

    await file(
        'apps/api/src/features/authorization/controllers/AuthorizationController.ts',
        `
import { Hono } from "hono";

export const authorizationRouter =
  new Hono();
`,
    );

    await file(
        'apps/api/src/features/authorization/routes.ts',
        `
import { Hono } from "hono";

export const routes =
  new Hono();
`,
    );

    console.log('part-1 completed');
}
