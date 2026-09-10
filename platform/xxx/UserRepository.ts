export interface User {
    id: string;
    name: string;
}

export interface UserRepository {
    findById(
        id: string
    ): User | null;
}

