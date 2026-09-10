import { describe, expect, it } from 'vitest';
import { InMemoryDatabaseProvider } from './InMemoryDatabaseProvider';

describe('InMemoryDatabaseProvider', () => {
    it('can connect', () => {
        const provider = new InMemoryDatabaseProvider();

        expect(provider.connect()).toBe(true);
    });
});
