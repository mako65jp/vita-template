// phase-5-user-alignment.mjs

import { writeFile } from 'node:fs/promises';

async function file(path, content = '') {
    await writeFile(path, content.trimStart(), 'utf8');
}

//
// User Entity
//

await file(
    'apps/api/src/features/user/domain/User.ts',
    `
export class User {

  constructor(

    public readonly id:
      number,

    public name:
      string,

    public email:
      string,

    public passwordHash:
      string,

    public role:
      string,

    public isActive:
      boolean,

    public createdAt:
      Date,
  ) {}
}
`,
);

//
// User DTO
//

await file(
    'packages/types/user/UserDto.ts',
    `
export interface UserDto {

  id:
    number;

  name:
    string;

  email:
    string;

  role:
    string;

  isActive:
    boolean;

  createdAt:
    string;
}
`,
);

//
// UserMapper
//

await file(
    'apps/api/src/features/user/mappers/UserMapper.ts',
    `
import { User }
  from "../domain/User";

import {
  UserDto
}
from "../../../../../packages/types/user/UserDto";

export class UserMapper {

  static toDto(
    user: User,
  ): UserDto {

    return {

      id:
        user.id,

      name:
        user.name,

      email:
        user.email,

      role:
        user.role,

      isActive:
        user.isActive,

      createdAt:
        user.createdAt.toISOString(),
    };
  }
}
`,
);

//
// UserRepositoryImpl
//
// 現在の InMemory 実装に合わせる
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

export class UserRepositoryImpl
implements UserRepository {

  constructor(
    private readonly db:
      Database,
  ) {}

  async findById(
    id: string,
  ) {

    const rows =
      await this.db.query<User>(
        "users",
        [id],
      );

    return rows[0];
  }

  async findAll() {

    return [];
  }

  async save(
    _user: User,
  ) {

  }

  async remove(
    _id: string,
  ) {

  }
}
`,
);

console.log('phase-5-user-alignment completed');
