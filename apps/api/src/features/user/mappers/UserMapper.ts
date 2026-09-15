import { User } from '../domain/User';

import { UserDto } from '../../../../../../packages/types/user/UserDto';

export class UserMapper {
    static toDto(user: User): UserDto {
        return {
            id: user.id,

            name: user.name,

            email: user.email,

            role: user.role,

            isActive: user.isActive,

            createdAt: user.createdAt.toISOString(),
        };
    }
}
