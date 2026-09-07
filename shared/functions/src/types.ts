import type { Database } from '@shared/db';
import { AuthUser } from './auth-registry';

export type AppEnv = {
    Variables: {
        dbInstance: Database,
        user?: AuthUser;
    }
}
