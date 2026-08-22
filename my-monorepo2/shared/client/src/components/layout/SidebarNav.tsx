import * as React from 'react';
import { cn } from '../../lib/utils';

export interface SidebarNavItem {
    label: string;
    href: string;
    active?: boolean;
    onClick?: (e: React.MouseEvent<HTMLAnchorElement>) => void;
}

export function SidebarNav({ items }: { items: SidebarNavItem[] }) {
    return (
        <nav className="flex flex-col gap-1">
            {items.map((item, index) => (
                <a
                    key={`${item.label}-${item.href}-${index}`}
                    href={item.href}
                    onClick={item.onClick}
                    className={cn(
                        'flex items-center rounded-md px-3 py-2 text-sm font-medium transition-colors',
                        item.active
                            ? 'bg-blue-50 text-blue-700 font-semibold'
                            : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                    )}
                >
                    {item.label}
                </a>
            ))}
        </nav>
    );
}
