import { describe, expect, it, vi } from 'vitest';
import { Find } from './Find';
import { UserEntity, UserModel } from '@features/user';
import { InMemoryRepository } from './InMemoryRepository';
import { PostgreSqlRepository } from './PostgreSqlRepository';

describe('Find', () => {

    const data = [
        {
            id: '1',
            loginId: 'araki',
            displayName: '荒木',
        }
    ];

    const repositories = [
        new InMemoryRepository(data),
        new PostgreSqlRepository<UserEntity>('postgres://localhost/sample'),
    ];

    it.each(repositories)('works with repository', repository => {

        expect(repository.findById('1')).toEqual(data[0]);

    });


    it('finds entity from repository', () => {
        const repository = new InMemoryRepository(data);

        const find = new Find(repository);

        expect(find.execute('1')).toEqual(data[0]);
    });

});
