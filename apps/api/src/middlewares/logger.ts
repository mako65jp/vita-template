import { MiddlewareHandler } from 'hono';

export const loggerMiddleware: MiddlewareHandler = async (c, next) => {
    const start = Date.now();
    const { method, path } = c.req;

    await next();

    const durationMs = Date.now() - start;
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
        timestamp: new Date().toISOString(),
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

// import { MiddlewareHandler } from 'hono';

// export const loggerMiddleware: MiddlewareHandler = async (c, next) => {
//     const start = Date.now();
//     const { method, path } = c.req;

//     await next();

//     const durationMs = Date.now() - start;
//     const status = c.res.status;

//     // 500系エラーの場合は level を error に変更
//     const isError = status >= 500 || c.error !== undefined;
//     const logLevel = isError ? 'error' : 'info';

//     const authHeader = c.req.header('authorization');
//     const headers: Record<string, string> = {};
//     if (authHeader) {
//         headers['authorization'] = '***';
//     }

//     const logPayload: Record<string, any> = {
//         level: logLevel,
//         timestamp: new Date().toISOString(),
//         method,
//         path,
//         status,
//         durationMs,
//         headers: Object.keys(headers).length > 0 ? headers : undefined,
//     };

//     // 500系エラーかつエラーオブジェクトが存在する場合はスタックトレース情報も JSON 内に格納
//     if (isError && c.error) {
//         logPayload.error = {
//             message: c.error.message,
//             stack: c.error.stack,
//         };
//     }

//     // すべて JSON 1行として出力（console.error や console.log に統一）
//     console.log(JSON.stringify(logPayload));
// };
