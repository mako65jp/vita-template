// apps/web/src/lib/apiClient.ts
import { clientEnv } from "@app/ui";

export interface InvalidParam {
    name: string;
    reason: string;
}

export class ApiError extends Error {
    public status: number;
    public title: string;
    public detail?: string;
    public instance?: string;
    public invalidParams?: InvalidParam[];

    constructor(problem: {
        title?: string;
        status?: number;
        detail?: string;
        instance?: string;
        invalidParams?: InvalidParam[];
    }) {
        super(problem.detail || problem.title || "API Error");
        this.name = "ApiError";
        this.status = problem.status || 500;
        this.title = problem.title || "エラーが発生しました";
        this.detail = problem.detail;
        this.instance = problem.instance;
        this.invalidParams = problem.invalidParams;
    }
}

const TOKEN_KEY = "auth_token";

export const getStoredToken = (): string | null => {
    return localStorage.getItem(TOKEN_KEY);
};

export const setStoredToken = (token: string): void => {
    localStorage.setItem(TOKEN_KEY, token);
};

export const removeStoredToken = (): void => {
    localStorage.removeItem(TOKEN_KEY);
};

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const baseUrl = clientEnv.VITE_API_TARGET_URL || "";
    const url = `${baseUrl.replace(/\/$/, "")}${endpoint}`;

    const token = getStoredToken();
    const headers = new Headers(options.headers || {});

    if (!headers.has("Content-Type")) {
        headers.set("Content-Type", "application/json");
    }

    if (token) {
        headers.set("Authorization", `Bearer ${token}`);
    }

    const response = await fetch(url, {
        ...options,
        headers,
    });

    if (!response.ok) {
        if (response.status === 401) {
            removeStoredToken();
        }

        let errorData: any = {};
        try {
            errorData = await response.json();
        } catch {
            errorData = {
                title: response.statusText || "HTTP Error",
                status: response.status,
            };
        }

        throw new ApiError(errorData);
    }

    if (response.status === 204) {
        return {} as T;
    }

    return response.json();
}

export const apiClient = {
    get: <T>(endpoint: string, options?: RequestInit) =>
        request<T>(endpoint, { ...options, method: "GET" }),

    post: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
        request<T>(endpoint, {
            ...options,
            method: "POST",
            body: body ? JSON.stringify(body) : undefined,
        }),

    put: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
        request<T>(endpoint, {
            ...options,
            method: "PUT",
            body: body ? JSON.stringify(body) : undefined,
        }),

    delete: <T>(endpoint: string, options?: RequestInit) =>
        request<T>(endpoint, { ...options, method: "DELETE" }),
};
