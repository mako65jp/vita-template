import sql from 'mssql';

import type { CreateUser, User } from '@packages/schemas';
import { hashPassword } from '../../features/user/auth-utils';
import type { UserRepository } from '../../repositories/user-repository';
import { users } from './schema';

export class SqlServerUserRepository implements UserRepository {
    constructor(private readonly db: sql.ConnectionPool) {}

    async findById(id: number): Promise<User | null> {
        const result = await this.db.request().input('id', sql.UniqueIdentifier, id).query(`
                SELECT
                    ${users.id.select},
                    ${users.name.select},
                    ${users.email.select},
                    $(users.passwordHash.select),
                    ${users.role.select},
                    ${users.isActive.select},
                    $(users.createdAt.select())
                FROM ${users.tableName}
                WHERE ${users.id} = @id
            `);

        if (result.recordset.length === 0) {
            return null;
        }

        const row = result.recordset[0];

        return {
            id: row.id,
            name: row.name,
            email: row.email,
            passwordHash: row.passwordHash,
            role: row.role,
            isActive: row.isActive,
            createdAt: row.createdAt,
        };
    }

    async findByEmail(email: string): Promise<User | null> {
        const result = await this.db.request().input('email', sql.NVarChar(255), email).query(`
                SELECT
                    ${users.id.select},
                    ${users.name.select},
                    ${users.email.select},
                    $(users.passwordHash.select),
                    ${users.role.select},
                    ${users.isActive.select},
                    $(users.createdAt.select)
                FROM ${users.tableName}
                WHERE ${users.email} = @email
            `);

        if (result.recordset.length === 0) {
            return null;
        }

        const row = result.recordset[0];

        return {
            id: row.id,
            name: row.name,
            email: row.email,
            passwordHash: row.password_hash,
            role: row.role,
            isActive: row.isActive,
            createdAt: row.createdAt,
        };
    }

    findAll(): Promise<User[]> {
        throw new Error('Method not implemented.');
    }
    countAdmins(): Promise<number> {
        throw new Error('Method not implemented.');
    }

    async create(request: CreateUser): Promise<User> {
        const passwordHash = await hashPassword(request.password);
        const result = await this.db
            .request()
            .input('name', sql.NVarChar(255), request.name)
            .input('email', sql.NVarChar(255), request.email)
            .input('passwordHash', sql.NVarChar(255), passwordHash).query(`
                INSERT INTO ${users.tableName} (
                    ${users.name},
                    ${users.email},
                    ${users.passwordHash}
                )
                OUTPUT
                    ${users.id.inserted},
                    ${users.name.inserted},
                    ${users.email.inserted},
                    ${users.passwordHash.inserted}
                    ${users.role.inserted},
                    ${users.isActive.inserted},
                    ${users.createdAt.inserted}
                VALUES (
                    @name,
                    @email,
                    @passwordHash
                )
            `);

        const row = result.recordset[0];

        return {
            id: row.id,
            name: row.name,
            email: row.email,
            passwordHash: row.passwordHash,
            role: row.role,
            isActive: row.isActive,
            createdAt: row.createdAt,
        };
    }

    save(user: User): Promise<User> {
        throw new Error('Method not implemented.');
    }
    updatePassword(id: number, passwordHash: string): Promise<User> {
        throw new Error('Method not implemented.');
    }
    updateRole(id: number, role: string): Promise<User> {
        throw new Error('Method not implemented.');
    }
    updateActive(id: number, isActive: boolean): Promise<User> {
        throw new Error('Method not implemented.');
    }
    remove(id: number): Promise<void> {
        throw new Error('Method not implemented.');
    }
}

// import { eq } from 'drizzle-orm';

// import { type CreateUser, type User } from '@packages/schemas';
// import { hashPassword } from '../../features/user/auth-utils';
// import type { UserRepository } from '../../repositories/user-repository';
// import { createSqlServerDb } from './db';
// import { users } from './schema';

// export class SqlServerUserRepository implements UserRepository {
//     constructor(private readonly db: ReturnType<typeof createSqlServerDb>) {}

//     async findById(id: number): Promise<User | null> {
//         const result = await this.db.select().from(users).where(eq(users.id, id)).limit(1);

//         if (result.length === 0) {
//             return null;
//         }

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async findByEmail(email: string): Promise<User | null> {
//         const result = await this.db.select().from(users).where(eq(users.email, email)).limit(1);

//         if (result.length === 0) {
//             return null;
//         }

//         return result[0];
//     }

//     async findAll(): Promise<User[]> {
//         const result = await this.db.select().from(users);
//         return result;
//     }

//     async countAdmins(): Promise<number> {
//         const result = await this.db.select().from(users);
//         return result.length;
//     }

//     async create(request: CreateUser): Promise<User> {
//         const passwordHash = await hashPassword(request.password);
//         const result = await this.db
//             .insert(users)
//             .values({
//                 name: request.name,
//                 email: request.email,
//                 passwordHash: passwordHash,
//                 role: 'user',
//             })
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async save(user: User): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 name: user.name,
//                 email: user.email,
//                 role: user.role,
//                 isActive: user.isActive,
//             })
//             .where(eq(users.id, user.id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async updatePassword(id: number, passwordHash: string): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 passwordHash: passwordHash,
//             })
//             .where(eq(users.id, id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async updateRole(id: number, role: string): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 role: role,
//             })
//             .where(eq(users.id, id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async updateActive(id: number, isActive: boolean): Promise<User> {
//         const result = await this.db
//             .update(users)
//             .set({
//                 isActive: isActive,
//             })
//             .where(eq(users.id, id))
//             .returning();

//         return {
//             id: result[0].id,
//             name: result[0].name,
//             email: result[0].email,
//             passwordHash: result[0].passwordHash,
//             role: result[0].role,
//             isActive: result[0].isActive,
//             createdAt: result[0].createdAt,
//         };
//     }

//     async remove(id: number): Promise<void> {
//         const result = await this.db.delete(users).where(eq(users.id, id)).returning();
//     }
// }
