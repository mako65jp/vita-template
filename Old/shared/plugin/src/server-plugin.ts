// shared/plugin/src/server-plugin.ts

import { Hono } from 'hono';

export interface ServerPlugin {
    id: string;

    routes?: Hono<any>;
}
