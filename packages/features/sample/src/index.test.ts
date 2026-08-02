import { describe, it, expect } from 'vitest';
import createSampleFeature from './index.ts';

describe('Sample Feature API', () => {
  it('GET /sample should return 200 and json message', async () => {
    const app = createSampleFeature();
    const res = await app.request('/sample');
    
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body).toEqual({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });
});
