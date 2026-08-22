export interface InvalidParam {
    name: string;
    reason: string;
}

// RFC 9457 エラーレスポンス用インターフェース
export interface ProblemDetails {
    type: string;
    title: string;
    status: number;
    detail: string;
    instance: string;
    invalidParams?: InvalidParam[];
}
