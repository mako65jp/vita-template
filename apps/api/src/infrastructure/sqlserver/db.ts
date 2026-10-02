import sql from 'mssql';

export type SqlServerDb = sql.ConnectionPool;

export async function createSqlServerDb(connectionString: string): Promise<SqlServerDb> {
    const pool = new sql.ConnectionPool(connectionString);

    await pool.connect();

    return pool;
}

export class Column {
    constructor(
        public readonly property: string,
        public readonly columnName: string,
    ) {}

    get column(): string {
        return this.columnName;
    }

    get select(): string {
        return `${this.columnName} AS ${this.property}`;
    }
    get inserted(): string {
        return `inserted.${this.select}`;
    }
    get deleted(): string {
        return `deleted.${this.select}`;
    }

    toString(): string {
        return this.columnName;
    }
}
