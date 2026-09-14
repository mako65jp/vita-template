import type { Repository } from './Repository';

export class Remove<TEntity> {

    constructor(
        private readonly repository: Repository
    ) { }

    execute(id: string): void {
        this.repository.remove(id);
    }
}
