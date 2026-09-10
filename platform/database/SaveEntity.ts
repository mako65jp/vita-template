import type {
    Repository,
} from './Repository';

export class SaveEntity<TEntity> {

    constructor(
        private readonly repository:
            Repository<TEntity>,
    ) { }

    execute(
        entity: TEntity,
    ): void {

        this.repository.save(
            entity,
        );
    }
}
