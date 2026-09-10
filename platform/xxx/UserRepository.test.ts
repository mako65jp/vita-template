import { it, expect, describe } from "vitest";
import { InMemoryUserRepository } from "./UserRepository";

describe('UserRepository', () => {
    it('finds user by id', () => {
        const repository = new InMemoryUserRepository();

        const user = repository.findById('1');

        expect(user?.id).toBe('1');
    });
});

