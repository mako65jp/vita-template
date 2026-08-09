import { describe, it, expect } from 'vitest';
import { clientEnv } from '@app/core/config/env';

describe('Web Environment Variables (Pattern A)', () => {
    it('packages/core の clientEnv から正しく設定値および動的補完値が取得できること', () => {
        // VITE_APP_TITLE の検証
        expect(clientEnv.VITE_APP_TITLE).toBeDefined();
        expect(typeof clientEnv.VITE_APP_TITLE).toBe('string');

        // VITE_PORT の検証
        expect(typeof clientEnv.VITE_PORT).toBe('number');

        // VITE_API_TARGET_URL の動的補完検証
        expect(clientEnv.VITE_API_TARGET_URL).toBeDefined();
        expect(clientEnv.VITE_API_TARGET_URL).toMatch(/^http/);
    });
});
