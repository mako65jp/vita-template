import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ForbiddenPage } from './ForbiddenPage';

describe('ForbiddenPage Component', () => {
    it('403 エラーメッセージとタイトルが正しく表示されること', () => {
        render(<ForbiddenPage onBackToDashboard={vi.fn()} />);

        expect(screen.getByText('403')).toBeInTheDocument();
        expect(screen.getByText('アクセス権限がありません')).toBeInTheDocument();
        expect(
            screen.getByText(/このページを閲覧・操作するための権限が付与されていません/)
        ).toBeInTheDocument();
    });

    it('「ダッシュボードへ戻る」ボタンを押すとコールバックが実行されること', () => {
        const handleBack = vi.fn();
        render(<ForbiddenPage onBackToDashboard={handleBack} />);

        const backButton = screen.getByRole('button', { name: 'ダッシュボードへ戻る' });
        fireEvent.click(backButton);

        expect(handleBack).toHaveBeenCalledTimes(1);
    });
});
