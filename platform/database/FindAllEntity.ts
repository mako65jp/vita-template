import type { Repository } from './Repository';

export class FindAllEntity<TEntity> {
    constructor(
        private readonly repository: Repository<TEntity>,
    ) { }

    execute(): TEntity[] {
        return this.repository.findAll();
    }
}
