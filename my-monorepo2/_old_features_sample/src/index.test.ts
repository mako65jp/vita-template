import { describe, it, expect } from 'vitest';
import createSampleFeature from './index';

describe('Sample Feature Module', () => {
  const app = createSampleFeature();

  it('GET /sample は正常メッセージを返すこと', async () => {
    const res = await app.request('/sample');
    expect(res.status).toBe(200);

    const body = await res.json();
    expect(body).toEqual({
      message: 'Hello from Auto-Loaded Sample Feature in DevContainer!',
    });
  });
});
