import type { Repository } from './Repository';

export class Save<TEntity> {
    constructor(
        private readonly repository: Repository
    ) { }

    execute(entity: TEntity): void {
        this.repository.save(entity);
    }
}
