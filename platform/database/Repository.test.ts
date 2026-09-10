import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';

describe('InMemoryRepository', () => {

    it('returns entity by id', () => {
        const repository = new InMemoryRepository<{ id: string }>([{ id: '1' }]);

        expect(repository.findById('1')).toEqual({ id: '1', });
    });
});
