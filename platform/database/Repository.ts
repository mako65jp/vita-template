export interface Repository<TEntity> {
    findById(id: string): TEntity | null;
    findAll(): TEntity[];

    save(entity: TEntity): void;
}
