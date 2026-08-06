import * as React from 'react';
import { cn } from '../lib/utils';

interface LayoutProps {
    children: React.ReactNode;
    sidebar?: React.ReactNode;
    header?: React.ReactNode;
    className?: string;
}

export function AppLayout({ children, sidebar, header, className }: LayoutProps) {
    return (
        <div className="flex min-h-screen flex-col bg-gray-50 text-gray-900">
            {/* Header */}
            {header && (
                <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/80 backdrop-blur">
                    {header}
                </header>
            )}

            <div className="flex flex-1">
                {/* Sidebar */}
                {sidebar && (
                    <aside className="w-64 shrink-0 border-r border-gray-200 bg-white p-4 hidden md:block">
                        {sidebar}
                    </aside>
                )}

                {/* Main Content */}
                <main className={cn('flex-1 p-6 max-w-7xl mx-auto w-full', className)}>
                    {children}
                </main>
            </div>
        </div>
    );
}

export function HeaderContent({ title }: { title: string }) {
    return (
        <div className="flex h-16 items-center justify-between px-6">
            <h1 className="text-xl font-bold tracking-tight text-gray-900">{title}</h1>
            <div className="flex items-center gap-4">
                <span className="text-sm text-gray-500">Dev App</span>
            </div>
        </div>
    );
}

export function SidebarNav({ items }: { items: { label: string; href: string; active?: boolean }[] }) {
    return (
        <nav className="flex flex-col gap-1">
            {items.map((item) => (
                <a
                    key={item.href}
                    href={item.href}
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
