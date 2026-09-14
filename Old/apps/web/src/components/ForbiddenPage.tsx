import React from 'react';
import { Button } from '@shared/client';

interface ForbiddenPageProps {
    onBackToDashboard: () => void;
}

export const ForbiddenPage: React.FC<ForbiddenPageProps> = ({ onBackToDashboard }) => {
    return (
        <div className="flex min-h-[60vh] flex-col items-center justify-center text-center p-6">
            <div className="rounded-full bg-red-100 p-4 mb-4">
                <svg
                    className="h-12 w-12 text-red-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                >
                    <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                    />
                </svg>
            </div>

            <h1 className="text-4xl font-extrabold text-gray-900 mb-2">403</h1>
            <h2 className="text-xl font-semibold text-gray-800 mb-2">アクセス権限がありません</h2>
            <p className="text-sm text-gray-600 max-w-md mb-6">
                このページを閲覧・操作するための権限が付与されていません。管理者にお問い合わせいただくか、ダッシュボードへお戻りください。
            </p>

            <Button variant="default" onClick={onBackToDashboard}>
                ダッシュボードへ戻る
            </Button>
        </div>
    );
};
