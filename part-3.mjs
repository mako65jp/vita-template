// part-3.mjs

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
    // React
    //

    await dir('apps/web-react/src/app');
    await dir('apps/web-react/src/app/providers');
    await dir('apps/web-react/src/components');

    await dir('apps/web-react/src/features/authentication');
    await dir('apps/web-react/src/features/authorization');
    await dir('apps/web-react/src/features/administration');
    await dir('apps/web-react/src/features/user');

    await file(
        'apps/web-react/src/main.tsx',
        `
export {};
`,
    );

    await file(
        'apps/web-react/src/app/App.tsx',
        `
export function App() {

  return (
    <>App</>
  );
}
`,
    );

    await file(
        'apps/web-react/src/app/router.tsx',
        `
export const routes = [];
`,
    );

    await file(
        'apps/web-react/src/app/providers/AuthProvider.tsx',
        `
export function AuthProvider(
  props: any,
) {

  return props.children;
}
`,
    );

    await file(
        'apps/web-react/src/app/providers/FeatureProvider.tsx',
        `
export function FeatureProvider(
  props: any,
) {

  return props.children;
}
`,
    );

    await file(
        'apps/web-react/src/app/providers/ConfigurationProvider.tsx',
        `
export function ConfigurationProvider(
  props: any,
) {

  return props.children;
}
`,
    );

    await file(
        'apps/web-react/src/app/providers/ReactQueryProvider.tsx',
        `
export function ReactQueryProvider(
  props: any,
) {

  return props.children;
}
`,
    );

    await file(
        'apps/web-react/src/features/user/routes.tsx',
        `
export const routes = [];
`,
    );

    await file(
        'apps/web-react/src/features/administration/routes.tsx',
        `
export const routes = [];
`,
    );

    //
    // Vue
    //

    await dir('apps/web-vue/src/app');
    await dir('apps/web-vue/src/components');

    await dir('apps/web-vue/src/features/authentication');
    await dir('apps/web-vue/src/features/authorization');
    await dir('apps/web-vue/src/features/administration');
    await dir('apps/web-vue/src/features/user');

    await file(
        'apps/web-vue/src/main.ts',
        `
export {};
`,
    );

    await file(
        'apps/web-vue/src/app/App.vue',
        `
<template>
  <div>App</div>
</template>
`,
    );

    await file(
        'apps/web-vue/src/app/router.ts',
        `
export const routes = [];
`,
    );

    await file(
        'apps/web-vue/src/features/user/routes.ts',
        `
export const routes = [];
`,
    );

    await file(
        'apps/web-vue/src/features/administration/routes.ts',
        `
export const routes = [];
`,
    );

    //
    // packages/types
    //

    await dir('packages/types');
    await dir('packages/types/common');
    await dir('packages/types/user');
    await dir('packages/types/authentication');
    await dir('packages/types/authorization');
    await dir('packages/types/administration');

    await file(
        'packages/types/Config.ts',
        `
export interface Config {
}
`,
    );

    await file(
        'packages/types/user/UserDto.ts',
        `
export interface UserDto {

  id: string;

  name: string;
}
`,
    );

    await file(
        'packages/types/user/CreateUserRequest.ts',
        `
export interface CreateUserRequest {

  name: string;
}
`,
    );

    await file(
        'packages/types/user/UpdateUserRequest.ts',
        `
export interface UpdateUserRequest {

  id: string;

  name: string;
}
`,
    );

    await file(
        'packages/types/authentication/LoginRequest.ts',
        `
export interface LoginRequest {

  userName: string;

  password: string;
}
`,
    );

    await file(
        'packages/types/authentication/LoginResponse.ts',
        `
export interface LoginResponse {

  accessToken: string;
}
`,
    );

    await file(
        'packages/types/authorization/RoleDto.ts',
        `
export interface RoleDto {

  name: string;
}
`,
    );

    await file(
        'packages/types/authorization/PermissionDto.ts',
        `
export interface PermissionDto {

  name: string;
}
`,
    );

    await file(
        'packages/types/administration/FeatureFlagDto.ts',
        `
export interface FeatureFlagDto {

  name: string;

  enabled: boolean;
}
`,
    );

    await file(
        'packages/types/administration/ConfigurationDto.ts',
        `
export interface ConfigurationDto {
}
`,
    );

    //
    // packages/validation
    //

    await dir('packages/validation');
    await dir('packages/validation/common');
    await dir('packages/validation/user');
    await dir('packages/validation/authentication');
    await dir('packages/validation/administration');

    await file(
        'packages/validation/user/CreateUserSchema.ts',
        `
export const CreateUserSchema = {};
`,
    );

    await file(
        'packages/validation/user/UpdateUserSchema.ts',
        `
export const UpdateUserSchema = {};
`,
    );

    await file(
        'packages/validation/authentication/LoginSchema.ts',
        `
export const LoginSchema = {};
`,
    );

    //
    // packages/api-client
    //

    await dir('packages/api-client');
    await dir('packages/api-client/http');
    await dir('packages/api-client/user');
    await dir('packages/api-client/authentication');
    await dir('packages/api-client/administration');

    await file(
        'packages/api-client/http/HttpClient.ts',
        `
export interface HttpClient {

  get<T>(
    url: string,
  ): Promise<T>;

  post<T>(
    url: string,
    body: unknown,
  ): Promise<T>;
}
`,
    );

    await file(
        'packages/api-client/http/FetchHttpClient.ts',
        `
import { HttpClient }
  from "./HttpClient";

export class FetchHttpClient
implements HttpClient {

  async get<T>(
    url: string,
  ): Promise<T> {

    const response =
      await fetch(url);

    return response.json();
  }

  async post<T>(
    url: string,
    body: unknown,
  ): Promise<T> {

    const response =
      await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type":
            "application/json",
        },
        body:
          JSON.stringify(body),
      });

    return response.json();
  }
}
`,
    );

    await file(
        'packages/api-client/user/UserApi.ts',
        `
export class UserApi {
}
`,
    );

    await file(
        'packages/api-client/authentication/AuthenticationApi.ts',
        `
export class AuthenticationApi {
}
`,
    );

    await file(
        'packages/api-client/administration/ConfigurationApi.ts',
        `
export class ConfigurationApi {
}
`,
    );

    //
    // packages/shared
    //

    await dir('packages/shared');
    await dir('packages/shared/constants');
    await dir('packages/shared/errors');
    await dir('packages/shared/utilities');
    await dir('packages/shared/collections');

    //
    // config
    //

    await dir('config');

    await file(
        'config/development.json',
        `
{
  "database": {
    "type": "memory"
  },

  "authentication": {
    "type": "none"
  },

  "administration": {
    "enabled": true,

    "authentication": {
      "type": "local"
    }
  },

  "features": {
    "user": true
  },

  "frontend": {
    "type": "react"
  }
}
`,
    );

    await file(
        'config/staging.json',
        `
{
}
`,
    );

    await file(
        'config/production.json',
        `
{
}
`,
    );

    //
    // root files
    //

    await file(
        'package.json',
        `
{
  "name": "generated-project",
  "private": true
}
`,
    );

    await file(
        'tsconfig.base.json',
        `
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true
  }
}
`,
    );

    await file(
        'README.md',
        `
# Generated Project
`,
    );

    console.log('part-3 completed');
}
