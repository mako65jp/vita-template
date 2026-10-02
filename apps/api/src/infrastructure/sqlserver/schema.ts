import { Column } from './db';

export const users = {
    tableName: 'users',

    id: new Column('id', 'id'),
    name: new Column('name', 'name'),
    email: new Column('email', 'email'),
    passwordHash: new Column('passwordHash', 'password_hash'),
    role: new Column('role', 'emroleail'),
    isActive: new Column('isActive', 'isActive'),
    createdAt: new Column('createdAt', 'created_at'),
} as const;
