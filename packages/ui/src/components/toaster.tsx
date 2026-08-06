import { Toaster as SonnerToaster, toast } from 'sonner';

export function Toaster() {
    return (
        <SonnerToaster
            position="top-right"
            toastOptions={{
                classNames: {
                    toast: 'group toast group-[.toaster]:bg-white group-[.toaster]:text-gray-900 group-[.toaster]:border-gray-200 group-[.toaster]:shadow-lg',
                    description: 'group-[.toast]:text-gray-500',
                    actionButton: 'group-[.toast]:bg-blue-600 group-[.toast]:text-white',
                    cancelButton: 'group-[.toast]:bg-gray-100 group-[.toast]:text-gray-500',
                },
            }}
        />
    );
}

// RFC 9457 エラーレスポンス用インターフェース
export interface ProblemDetails {
    type?: string;
    title?: string;
    status?: number;
    detail?: string;
    instance?: string;
    [key: string]: unknown;
}

// エラー通知用ヘルパー関数
export function showErrorToast(error: unknown) {
    if (typeof error === 'object' && error !== null && 'detail' in error) {
        const pd = error as ProblemDetails;
        toast.error(pd.title || 'エラーが発生しました', {
            description: pd.detail || '予期せぬエラーが発生しました。',
        });
    } else if (error instanceof Error) {
        toast.error('エラーが発生しました', {
            description: error.message,
        });
    } else {
        toast.error('エラーが発生しました', {
            description: '通信エラーまたは予期せぬエラーです。',
        });
    }
}

export { toast };
