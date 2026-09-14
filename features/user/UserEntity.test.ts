import { expect, it } from 'vitest';
import { InMemoryRepository } from '@platform/database';
import { Find } from '@platform/database';
import type { UserEntity } from './UserEntity';

it('finds user entity', () => {
    const repository = new InMemoryRepository([
        {
            id: '1',
            loginId: 'araki',
            displayName: '荒木'
        }
    ]);

    const useCase = new Find<UserEntity>(repository);

    expect(useCase.execute('1')).toEqual(
        {
            id: '1',
            loginId: 'araki',
            displayName: '荒木'
        });
});
