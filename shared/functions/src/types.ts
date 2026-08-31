import type { Database } from '@shared/db';

export type AppEnv = {
    Variables: {
        dbInstance: Database
    }
}
