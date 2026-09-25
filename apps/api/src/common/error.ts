import type { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { JwtTokenInvalid } from 'hono/utils/jwt/types';
import { customLogger } from './logger.js';

const error = (e: Error, c: Context) => {
    if (e instanceof HTTPException) {
        if (e.status === 400) {
            return c.json({ message: e.message }, e.status);
        }
        if (e.status === 401) {
            //   if (e.cause) customLogger(`${e.cause}`);
            if (e.cause) console.log(`${e.cause}`);
            return c.json({ message: 'unauthorized' }, e.status);
        }
        if (e.status === 403) {
            return c.json({ message: 'forbidden' }, e.status);
        }
        if (e.status === 404) {
            return c.json({ message: 'not found' }, e.status);
        }
        if (e.status === 422) {
            return c.json({ message: e.cause }, e.status);
        }
    }

    if (e instanceof JwtTokenInvalid) {
        customLogger(e.message);
        return c.json({ message: 'invalid token' }, 400);
    }

    return c.json({ message: e.message }, 500);
};

export default error;
