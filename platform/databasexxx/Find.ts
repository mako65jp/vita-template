import type { Repository } from './Repository';

export class Find<TEntity> {
    constructor(
        private readonly repository: Repository,
    ) { }

    execute(id: string,): TEntity | null {
        return this.repository.findById(id);
    }
}
