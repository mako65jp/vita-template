import { AppError } from './app-error';

export class BadRequestError extends AppError {
    constructor(message = 'The request was invalid or cannot be served') {
        super(400, 'bad-request', 'Bad Request', message);
    }
}
