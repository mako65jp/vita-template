import type { Repository } from './Repository';

export class InMemoryRepository<TEntity extends { id: string; }>
    implements Repository<TEntity> {
    constructor(
        private readonly entities: TEntity[],
    ) { }

    findById(id: string): TEntity | null {
        return (this.entities.find(entity => entity.id === id) ?? null
        );
    }

    findAll(): TEntity[] {
        return [...this.entities];
    }

    save(entity: TEntity): void {
        this.entities.push(entity);
    }
}
