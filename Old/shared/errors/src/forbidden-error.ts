import { AppError } from './app-error';

export class ForbiddenError extends AppError {
    constructor(message = 'You do not have permission to access this resource') {
        super(403, 'forbidden', 'Forbidden', message);
    }
}
