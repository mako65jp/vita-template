export interface Repository {
    findById<TEntity>(id: string): TEntity | null;
    findAll<TEntity>(): TEntity[];

    save<TEntity>(entity: TEntity): void;
    update<TEntity>(entity: TEntity): void;
    remove<TEntity>(id: string): void;
}
