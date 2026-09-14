import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';

describe('InMemoryRepository', () => {

    it('returns entity by id', () => {
        const repository = new InMemoryRepository([{ id: '1' }]);

        expect(repository.findById('1')).toEqual({ id: '1' });
    });

    it('returns null when entity does not exist', () => {
        const repository = new InMemoryRepository([{ id: '1' }]);

        expect(repository.findById('2')).toBeNull();
    });

    it('returns null when entity does not exist', () => {
        const repository = new InMemoryRepository([{ id: '1', }]);

        expect(
            repository.findById('2')).toBeNull();
    });

    it('returns all entities', () => {
        const repository = new InMemoryRepository([
            { id: '1' },
            { id: '2' }
        ]);

        expect(repository.findAll()).toEqual([
            { id: '1' },
            { id: '2' }
        ]);
    });

    it('saves entity', () => {
        const repository = new InMemoryRepository<{ id: string }>([]);

        repository.save(
            { id: '1' }
        );

        expect(repository.findById('1')).toEqual(
            { id: '1' }
        );
    });

});
