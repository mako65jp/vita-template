import { HttpClient } from './HttpClient';

export class FetchHttpClient implements HttpClient {
    async get<T>(url: string): Promise<T> {
        const response = await fetch(url);

        return response.json();
    }

    async post<T>(url: string, body: unknown): Promise<T> {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
        });

        return response.json();
    }
}
