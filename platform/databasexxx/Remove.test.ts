import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';
import { Remove } from './Remove';

describe('Remove', () => {

    it('deletes', () => {

        const repository = new InMemoryRepository([
            { id: '1' },
            { id: '2' }
        ]);

        const useCase = new Remove(repository);

        useCase.execute('1');

        expect(repository.findById('1')).toBeNull();
    });

    it('does not affect other entities', () => {

        const repository = new InMemoryRepository([
            { id: '1' },
            { id: '2' }
        ]);

        const useCase = new Remove(repository);

        useCase.execute('1');

        expect(repository.findById('2')).toEqual(
            { id: '2' }
        );
    });

    it('returns empty repository when all entities are deleted', () => {

        const repository = new InMemoryRepository([
            { id: '1' }
        ]);

        const useCase = new Remove(repository);

        useCase.execute('1');

        expect(repository.findAll()).toEqual([]);
    });
});
