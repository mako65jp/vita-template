import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { Button } from './button';

describe('Button Component', () => {
    it('子要素（テキスト）が正しくレンダリングされること', () => {
        render(<Button>テストボタン</Button>);
        expect(screen.getByRole('button', { name: 'テストボタン' })).toBeInTheDocument();
    });

    it('クリックイベントが発火すること', async () => {
        const handleClick = vi.fn();
        render(<Button onClick={handleClick}>クリック</Button>);

        await userEvent.click(screen.getByRole('button', { name: 'クリック' }));
        expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('disabled 属性が設定されている場合、クリックイベントが発火しないこと', async () => {
        const handleClick = vi.fn();
        render(<Button disabled onClick={handleClick}>無効ボタン</Button>);

        const button = screen.getByRole('button', { name: '無効ボタン' });
        expect(button).toBeDisabled();

        await userEvent.click(button);
        expect(handleClick).not.toHaveBeenCalled();
    });
});
