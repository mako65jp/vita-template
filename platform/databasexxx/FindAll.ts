import type { Repository } from './Repository';

export class FindAll<TEntity> {
    constructor(
        private readonly repository: Repository,
    ) { }

    execute(): TEntity[] {
        return this.repository.findAll();
    }
}
