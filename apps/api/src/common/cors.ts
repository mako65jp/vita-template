import { cors as honoCors } from 'hono/cors';
import { Config } from '../config/Config';

function cors(config: Config) {
    /*
     * CORS ミドルウェア・ハンドラー
     *
     * これも Hono にビルトインされているものを使う
     */
    return honoCors({
        origin: (origin) => {
            try {
                const url = new URL(origin);
                // ホスト名（ポート番号を除いた部分）が一致しているかチェック
                if (url.hostname === config.frontend.host) {
                    return origin; // マッチしたらリクエストのoriginをそのまま返して許可
                }
            } catch (e) {
                // origin が無効なURL、または存在しない場合は許可しない
            }
            // マッチしない場合は、デフォルトのオリジンを返すか、許可しない
            return 'http://' + 'localhost';
        },

        allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
        allowHeaders: ['Accept', 'Content-Type', 'Authorization'],
        exposeHeaders: [],
        credentials: false,
        maxAge: 0,
    });
}

export default cors;
