import { csrf as honoCsrf } from 'hono/csrf';
import { Config } from '../config/Config';

function csrf(config: Config) {
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
                return url.hostname === config.frontend.host;
            } catch {
                return false;
            }
        },
    });
}

export default csrf;
