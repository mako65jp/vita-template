import type { Repository } from './Repository';

export class Update<TEntity> {
    constructor(
        private readonly repository: Repository
    ) { }

    execute(entity: TEntity): void {
        this.repository.update(entity);
    }
}
