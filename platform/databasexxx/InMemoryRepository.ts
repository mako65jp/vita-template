import type { Repository } from './Repository';

export class InMemoryRepository implements Repository {
    constructor(
        private readonly entities: TEntity[],
    ) { }

    findById<TEntity>(id: string): TEntity | null {
        return (this.entities.find(entity => entity.id === id) ?? null);
    }

    findAll<TEntity>(): TEntity[] {
        return [...this.entities];
    }

    save<TEntity>(entity: TEntity): void {
        this.entities.push(entity);
    }

    update<TEntity>(entity: TEntity): void {
        const index = this.entities.findIndex(current => current.id === entity.id);

        if (index >= 0) {
            this.entities[index] = entity;
        }
    }

    remove<TEntity>(id: string): void {
        const index = this.entities.findIndex(entity => entity.id === id);

        if (index >= 0) {
            this.entities.splice(index, 1);
        }
    }
}
