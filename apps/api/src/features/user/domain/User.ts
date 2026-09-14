export class User {
    constructor(
        public readonly id: number,

        public name: string,

        public email: string,

        public passwordHash: string,

        public role: string,

        public isActive: boolean,

        public createdAt: Date,
    ) {}
}
