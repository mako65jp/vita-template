export interface InvalidParam {
    name: string;
    reason: string;
}

export interface ProblemDetails {
    type: string;
    title: string;
    status: number;
    detail: string;
    instance: string;
    invalidParams?: InvalidParam[];
}

export class AppError extends Error {
    constructor(
        public readonly status: number,
        public readonly code: string,
        public readonly title: string,
        message: string
    ) {
        super(message);
        this.name = 'AppError';
    }
}

export class NotFoundError extends AppError {
    constructor(message = 'The requested resource was not found') {
        super(404, 'not-found', 'Not Found', message);
    }
}

export class InternalServerError extends AppError {
    constructor(message = 'An unexpected error occurred') {
        super(500, 'internal-server-error', 'Internal Server Error', message);
    }
}

export class ValidationError extends AppError {
    constructor(
        public readonly invalidParams: InvalidParam[],
        message = 'Validation failed for the request payload'
    ) {
        super(400, 'validation-error', 'Bad Request', message);
    }
}

export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication token is missing or invalid') {
        super(401, 'unauthorized', 'Unauthorized', message);
    }
}
