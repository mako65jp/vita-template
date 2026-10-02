import { z } from 'zod';

export const CreateUserSchema = z.object({
    name: z.string().nonempty(),
    email: z.email(),
    password: z.string().nonempty(),
});

export type CreateUser = z.infer<typeof CreateUserSchema>;
