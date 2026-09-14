import { describe, expect, it } from 'vitest';
import { InMemoryRepository } from './InMemoryRepository';
import { Save } from './Save';

describe('Save', () => {

    it('saves entity', () => {
        const repository = new InMemoryRepository<{ id: string }>([]);

        const saveEntity = new Save(repository);

        saveEntity.execute({ id: '1' });

        expect(repository.findById('1')).toEqual({ id: '1' });
    });

    it('saves multiple entities', () => {
        const repository = new InMemoryRepository<{ id: string }>([]);

        const saveEntity = new Save(repository);

        saveEntity.execute({ id: '1' });

        saveEntity.execute({ id: '2' });

        expect(repository.findAll()).toEqual([
            { id: '1' },
            { id: '2' }
        ]);
    });
});
