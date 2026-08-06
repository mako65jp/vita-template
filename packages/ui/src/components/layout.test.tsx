import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { AppLayout, HeaderContent, SidebarNav } from './layout';

describe('AppLayout Component', () => {
    it('メインコンテンツ（children）が正しく描画されること', () => {
        render(
            <AppLayout>
                <div data-testid="test-content">メインコンテンツ</div>
            </AppLayout>
        );

        expect(screen.getByTestId('test-content')).toBeInTheDocument();
    });

    it('Header と Sidebar が指定された場合、正しく描画されること', () => {
        render(
            <AppLayout
                header={<HeaderContent title="テストヘッダー" />}
                sidebar={<SidebarNav items={[{ label: 'メニュー1', href: '#' }]} />}
            >
                <div>コンテンツ</div>
            </AppLayout>
        );

        expect(screen.getByRole('heading', { name: 'テストヘッダー' })).toBeInTheDocument();
        expect(screen.getByRole('link', { name: 'メニュー1' })).toBeInTheDocument();
    });

    it('SidebarNav で active フラグが立っている要素にアクティブスタイルが適用されること', () => {
        const navItems = [
            { label: 'アクティブ項目', href: '#1', active: true },
            { label: '通常項目', href: '#2', active: false },
        ];

        render(<SidebarNav items={navItems} />);

        const activeLink = screen.getByRole('link', { name: 'アクティブ項目' });
        const normalLink = screen.getByRole('link', { name: '通常項目' });

        expect(activeLink).toHaveClass('bg-blue-50');
        expect(normalLink).not.toHaveClass('bg-blue-50');
    });
});
