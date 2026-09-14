// part-2.mjs

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
    // administration
    //

    await dir('apps/api/src/features/administration/domain');

    await dir('apps/api/src/features/administration/repositories');

    await dir('apps/api/src/features/administration/services');

    await dir('apps/api/src/features/administration/controllers');

    await dir('apps/api/src/features/administration/authentication');

    await file(
        'apps/api/src/features/administration/domain/SystemConfiguration.ts',
        `
export interface SystemConfiguration {

  databaseType:
    | "memory"
    | "postgres"
    | "sqlserver";

  authenticationType:
    | "none"
    | "jwt"
    | "oidc"
    | "ldap";

  frontendType:
    | "react"
    | "vue";
}
`,
    );

    await file(
        'apps/api/src/features/administration/domain/FeatureFlag.ts',
        `
export interface FeatureFlag {

  name: string;

  enabled: boolean;
}
`,
    );

    await file(
        'apps/api/src/features/administration/domain/AdminUser.ts',
        `
export interface AdminUser {

  userName: string;
}
`,
    );

    await file(
        'apps/api/src/features/administration/domain/SystemStatus.ts',
        `
export interface SystemStatus {

  version: string;

  uptime: number;
}
`,
    );

    await file(
        'apps/api/src/features/administration/repositories/ConfigurationRepository.ts',
        `
import {
  SystemConfiguration
}
from "../domain/SystemConfiguration";

export interface ConfigurationRepository {

  load():
    Promise<SystemConfiguration>;

  save(
    configuration:
      SystemConfiguration,
  ): Promise<void>;
}
`,
    );

    await file(
        'apps/api/src/features/administration/repositories/FeatureFlagRepository.ts',
        `
import {
  FeatureFlag
}
from "../domain/FeatureFlag";

export interface FeatureFlagRepository {

  findAll():
    Promise<FeatureFlag[]>;

  save(
    feature: FeatureFlag,
  ): Promise<void>;
}
`,
    );

    await file(
        'apps/api/src/features/administration/repositories/AdminUserRepository.ts',
        `
import {
  AdminUser
}
from "../domain/AdminUser";

export interface AdminUserRepository {

  findAll():
    Promise<AdminUser[]>;
}
`,
    );

    await file(
        'apps/api/src/features/administration/services/ConfigurationService.ts',
        `
import {
  ConfigurationRepository
}
from "../repositories/ConfigurationRepository";

export class ConfigurationService {

  constructor(
    private readonly repository:
      ConfigurationRepository,
  ) {}

}
`,
    );

    await file(
        'apps/api/src/features/administration/services/FeatureFlagService.ts',
        `
import {
  FeatureFlagRepository
}
from "../repositories/FeatureFlagRepository";

export class FeatureFlagService {

  constructor(
    private readonly repository:
      FeatureFlagRepository,
  ) {}

}
`,
    );

    await file(
        'apps/api/src/features/administration/services/AdminUserService.ts',
        `
import {
  AdminUserRepository
}
from "../repositories/AdminUserRepository";

export class AdminUserService {

  constructor(
    private readonly repository:
      AdminUserRepository,
  ) {}

}
`,
    );

    await file(
        'apps/api/src/features/administration/services/SystemStatusService.ts',
        `
export class SystemStatusService {

}
`,
    );

    await file(
        'apps/api/src/features/administration/controllers/ConfigurationController.ts',
        `
import { Hono }
  from "hono";

export const configurationRouter =
  new Hono();
`,
    );

    await file(
        'apps/api/src/features/administration/controllers/FeatureFlagController.ts',
        `
import { Hono }
  from "hono";

export const featureFlagRouter =
  new Hono();
`,
    );

    await file(
        'apps/api/src/features/administration/controllers/AdminUserController.ts',
        `
import { Hono }
  from "hono";

export const adminUserRouter =
  new Hono();
`,
    );

    await file(
        'apps/api/src/features/administration/controllers/SystemStatusController.ts',
        `
import { Hono }
  from "hono";

export const systemStatusRouter =
  new Hono();
`,
    );

    await file(
        'apps/api/src/features/administration/authentication/AdminAuthenticationProvider.ts',
        `
export interface
AdminAuthenticationProvider {

  authenticate(
    userName: string,
    password: string,
  ): Promise<boolean>;
}
`,
    );

    await file(
        'apps/api/src/features/administration/authentication/LocalAdminAuthenticationProvider.ts',
        `
import {
  AdminAuthenticationProvider
}
from "./AdminAuthenticationProvider";

export class
LocalAdminAuthenticationProvider
implements
AdminAuthenticationProvider {

  async authenticate() {

    return true;
  }
}
`,
    );

    await file(
        'apps/api/src/features/administration/routes.ts',
        `
import { Hono }
  from "hono";

export const routes =
  new Hono();
`,
    );

    //
    // user
    //

    await dir('apps/api/src/features/user/domain');

    await dir('apps/api/src/features/user/repositories');

    await dir('apps/api/src/features/user/services');

    await dir('apps/api/src/features/user/controllers');

    await dir('apps/api/src/features/user/mappers');

    await file(
        'apps/api/src/features/user/domain/User.ts',
        `
export class User {

  constructor(
    public readonly id: string,
    public name: string,
  ) {}

}
`,
    );

    await file(
        'apps/api/src/features/user/repositories/UserRepository.ts',
        `
import { User }
  from "../domain/User";

export interface UserRepository {

  findById(
    id: string,
  ): Promise<User | undefined>;

  findAll():
    Promise<User[]>;

  save(
    user: User,
  ): Promise<void>;

  remove(
    id: string,
  ): Promise<void>;
}
`,
    );

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

export class UserRepositoryImpl
implements UserRepository {

  constructor(
    private readonly db:
      Database,
  ) {}

  async findById() {

    return undefined;
  }

  async findAll() {

    return [];
  }

  async save() {

  }

  async remove() {

  }
}
`,
    );

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

}
`,
    );

    await file(
        'apps/api/src/features/user/controllers/UserController.ts',
        `
import { Hono }
  from "hono";

export const userRouter =
  new Hono();
`,
    );

    await file(
        'apps/api/src/features/user/mappers/UserMapper.ts',
        `
import { User }
  from "../domain/User";

export class UserMapper {

  static toDto(
    user: User,
  ) {

    return {
      id: user.id,
      name: user.name,
    };
  }
}
`,
    );

    await file(
        'apps/api/src/features/user/routes.ts',
        `
import { Hono }
  from "hono";

export const routes =
  new Hono();
`,
    );

    //
    // main
    //

    await file(
        'apps/api/src/main.ts',
        `
import { createApp }
  from "./app/createApp";

const app =
  createApp();

export default app;
`,
    );

    console.log('part-2 completed');
}
