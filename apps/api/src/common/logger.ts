import { logger as honoLogger } from "hono/logger";

/*
 * 簡易的なロガー
 *
 * HTTP のステータスコードや
 * エラーログなどが追いやすくなるのであると助かる
 */
export const customLogger = (message: string, ...rest: Array<string>) => {
    console.log(message, ...rest);
    //  if (env.LOG_LEVEL === "debug") {
    //     console.log(message, ...rest);
    //   }
};

const logger = honoLogger(customLogger);

export default logger;
