import type { Repository } from './Repository';

export class FindEntity<TEntity> {
    constructor(
        private readonly repository: Repository<TEntity>,
    ) { }

    execute(id: string,): TEntity | null {
        return this.repository.findById(id);
    }
}
