import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';
import { FindAllEntity } from './FindAllEntity';

describe('FindAllEntity', () => {

    it('returns all entities', () => {

        const repository = new InMemoryRepository([
            { id: '1' },
            { id: '2' },
        ]);

        const useCase = new FindAllEntity(repository);

        expect(useCase.execute()).toEqual([
            { id: '1' },
            { id: '2' },
        ]);
    });

    it('returns empty array when repository is empty', () => {
        const repository = new InMemoryRepository<{ id: string }>([]);

        const useCase = new FindAllEntity(repository);

        expect(useCase.execute()).toEqual([]);
    });
});
