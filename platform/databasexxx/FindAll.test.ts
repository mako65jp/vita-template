import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';
import { FindAll } from './FindAll';

describe('FindAll', () => {

    it('returns all entities', () => {

        const repository = new InMemoryRepository([
            { id: '1' },
            { id: '2' },
        ]);

        const useCase = new FindAll(repository);

        expect(useCase.execute()).toEqual([
            { id: '1' },
            { id: '2' },
        ]);
    });

    it('returns empty array when repository is empty', () => {
        const repository = new InMemoryRepository<{ id: string }>([]);

        const useCase = new FindAll(repository);

        expect(useCase.execute()).toEqual([]);
    });
});
