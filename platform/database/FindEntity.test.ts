import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';
import { FindEntity } from './FindEntity';

describe('FindEntity', () => {

    it('finds entity from repository', () => {
        const repository = new InMemoryRepository([{ id: '1' }]);

        const useCase = new FindEntity(repository);

        expect(useCase.execute('1')).toEqual({ id: '1' });
    });
});
