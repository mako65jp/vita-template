import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';
import { Update } from './Update';

describe('Update', () => {
    it('updates entity', () => {

        const repository = new InMemoryRepository([
            { id: '1', name: 'old' }
        ]);

        const useCase = new Update(repository);

        useCase.execute(
            { id: '1', name: 'new' }
        );

        expect(repository.findById('1')).toEqual(
            { id: '1', name: 'new' }
        );
    });

    it('does not create a new entity', () => {
        const repository = new InMemoryRepository([
            { id: '1', name: 'old' }
        ]);

        const useCase = new Update(repository);

        useCase.execute(
            { id: '1', name: 'new' }
        );

        expect(repository.findAll()).toHaveLength(1);
    });
});
