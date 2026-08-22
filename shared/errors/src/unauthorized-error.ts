import { AppError } from './app-error';

export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication token is missing or invalid') {
        super(401, 'unauthorized', 'Unauthorized', message);
    }
}
