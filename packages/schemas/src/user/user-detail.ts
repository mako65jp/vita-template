import { z } from 'zod';

export const UserDetailSchema = z.object({
    id: z.number(),
    name: z.string(),
    email: z.string(),
    role: z.string(),
    isActive: z.boolean(),
    createdAt: z.date(),
});

export type UserDetail = z.infer<typeof UserDetailSchema>;
