import { Find, FindAll, Remove, Save, Update } from ".";

export interface Model<TEntity> {
    readonly entity: TEntity;

    readonly find: Find<TEntity>;
    readonly findAll: FindAll<TEntity>;

    readonly save: Save<TEntity>;
    readonly update: Update<TEntity>;
    readonly remove: Remove<TEntity>;
}
