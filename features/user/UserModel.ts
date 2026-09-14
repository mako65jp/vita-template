import { Remove, Find, FindAll, Save, Update, Model } from '@platform/database';
import { UserEntity } from './UserEntity';

export class UserModel implements Model<UserEntity> {

    constructor(
        public readonly entity: UserEntity,

        public readonly find: Find<UserEntity>,
        public readonly findAll: FindAll<UserEntity>,
        public readonly save: Save<UserEntity>,
        public readonly update: Update<UserEntity>,
        public readonly remove: Remove<UserEntity>,
    ) { }
}
