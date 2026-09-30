import { csrf as honoCsrf } from 'hono/csrf';
import { SystemConfig } from '../systemConfig/SystemConfig';

function csrf(systemConfig: SystemConfig) {
    /*
     * csrf ミドルウェア・ハンドラー
     *
     * これも Hono にビルトインされているものを使う
     */
    return honoCsrf({
        origin: (origin, c) => {
            try {
                const url = new URL(origin);
                // CORSのときと同様に、ホスト名が一致していればCSRF的にも安全とみなして許可する
                return url.hostname === systemConfig.frontend.host;
            } catch {
                return false;
            }
        },
    });
}

export default csrf;
