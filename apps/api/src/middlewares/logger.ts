import { MiddlewareHandler } from 'hono';

function formatLocalISOString(date: Date): string {
    // 1. 各日時のパーツをローカル時間で取得してパッド（穴埋め）する
    const YYYY = date.getFullYear();
    const MM = String(date.getMonth() + 1).padStart(2, '0');
    const DD = String(date.getDate()).padStart(2, '0');
    const hh = String(date.getHours()).padStart(2, '0');
    const mm = String(date.getMinutes()).padStart(2, '0');
    const ss = String(date.getSeconds()).padStart(2, '0');
    const mss = String(date.getMilliseconds()).padStart(3, '0'); // ミリ秒（3桁）

    // 2. 時分のオフセットを計算 (例: +09:00)
    const offsetMinutes = -date.getTimezoneOffset();
    const sign = offsetMinutes >= 0 ? '+' : '-';
    const absMinutes = Math.abs(offsetMinutes);
    const offsetH = String(Math.floor(absMinutes / 60)).padStart(2, '0');
    const offsetM = String(absMinutes % 60).padStart(2, '0');

    // 3. ミリ秒までの時刻と、時分オフセットを結合
    return `${YYYY}-${MM}-${DD}T${hh}:${mm}:${ss}.${mss}${sign}${offsetH}:${offsetM}`;
}

export const loggerMiddleware: MiddlewareHandler = async (c, next) => {
    const start = new Date();
    const { method, path } = c.req;

    await next();

    const end = new Date();
    const durationMs = end.getTime() - start.getTime();

    const status = c.res.status;

    // 💡 500 以上のシステムエラーのみ error レベルとする（4xx は info レベル）
    const isServerError = status >= 500;
    const logLevel = isServerError ? 'error' : 'info';

    const authHeader = c.req.header('authorization');
    const headers: Record<string, string> = {};
    if (authHeader) {
        headers['authorization'] = '***';
    }

    const logPayload: Record<string, any> = {
        level: logLevel,
        timestamp: formatLocalISOString(start),    //new Date().toISOString(),
        method,
        path,
        status,
        durationMs,
        headers: Object.keys(headers).length > 0 ? headers : undefined,
    };

    // 💡 500 以上のサーバーエラーの場合のみエラー情報（スタックトレース）を出力
    if (isServerError && c.error) {
        logPayload.error = {
            message: c.error.message,
            stack: c.error.stack,
        };
    }

    console.log(JSON.stringify(logPayload));
};
