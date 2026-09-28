export interface Database {
    type: string;
    query<T>(sql: string, params?: readonly unknown[]): Promise<T[]>;
    execute(sql: string, params?: readonly unknown[]): Promise<number>;
    beginTransaction(): Promise<void>;
    commit(): Promise<void>;
    rollback(): Promise<void>;
}
