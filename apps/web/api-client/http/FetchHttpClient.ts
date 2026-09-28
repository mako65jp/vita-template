import { Application } from '@apps/web/Application';
import { HttpClient } from './HttpClient';

const application = new Application();

export class FetchHttpClient implements HttpClient {
    async get<T>(url: string): Promise<T> {
        const response = await application.fetch(url);

        return response.json();
    }

    async post<T>(url: string, body: unknown): Promise<T> {
        const response = await application.fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
        });

        return response.json();
    }
}
