// import { User, UserRepository } from "./UserRepository";

// export class InMemoryUserRepository
//     implements UserRepository {
//     findById(
//         id: string,
//     ): User | null {
//         return {
//             id: '1',
//             name: 'test',
//         };
//     }
// }
import type { DatabaseProvider }
    from './DatabaseProvider';

export class InMemoryDatabaseProvider
    implements DatabaseProvider {
    connect(): boolean {
        return true;
    }
}
