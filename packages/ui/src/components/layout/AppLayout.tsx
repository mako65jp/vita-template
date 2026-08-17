import * as React from 'react';
import { cn } from '../../lib/utils';

interface LayoutProps {
    children: React.ReactNode;
    sidebar?: React.ReactNode;
    header?: React.ReactNode;
    className?: string;
}

export function AppLayout({ children, sidebar, header, className }: LayoutProps) {
    const [isMobileOpen, setIsMobileOpen] = React.useState(false);

    return (
        <div className="flex min-h-screen flex-col bg-gray-50 text-gray-900">
            {/* Header */}
            {header && (
                <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/80 backdrop-blur">
                    <div className="flex items-center justify-between px-4">
                        {sidebar && (
                            <button
                                type="button"
                                onClick={() => setIsMobileOpen(!isMobileOpen)}
                                className="mr-2 rounded-md p-2 text-gray-600 hover:bg-gray-100 md:hidden"
                                aria-label="Toggle Menu"
                            >
                                <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                                </svg>
                            </button>
                        )}
                        <div className="flex-1">{header}</div>
                    </div>
                </header>
            )}

            <div className="flex flex-1 relative">
                {/* Desktop Sidebar */}
                {sidebar && (
                    <aside className="w-64 shrink-0 border-r border-gray-200 bg-white p-4 hidden md:block">
                        {sidebar}
                    </aside>
                )}

                {/* Mobile Drawer (Overlay Sidebar) */}
                {sidebar && isMobileOpen && (
                    <>
                        <div
                            className="fixed inset-0 z-50 bg-black/50 md:hidden"
                            onClick={() => setIsMobileOpen(false)}
                        />
                        <aside className="fixed inset-y-0 left-0 z-50 w-64 border-r border-gray-200 bg-white p-4 shadow-xl md:hidden">
                            <div className="flex justify-end mb-2">
                                <button
                                    type="button"
                                    onClick={() => setIsMobileOpen(false)}
                                    className="rounded-md p-1 text-gray-500 hover:bg-gray-100"
                                    aria-label="Close Menu"
                                >
                                    <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                </button>
                            </div>
                            <div onClick={() => setIsMobileOpen(false)}>
                                {sidebar}
                            </div>
                        </aside>
                    </>
                )}

                {/* Main Content */}
                <main className={cn('flex-1 p-6 max-w-7xl mx-auto w-full', className)}>
                    {children}
                </main>
            </div>
        </div>
    );
}

export interface HeaderContentProps {
    title: string;
    children?: React.ReactNode;
}

export function HeaderContent({ title, children }: HeaderContentProps) {
    return (
        <div className="flex h-16 items-center justify-between px-2 md:px-6">
            <h1 className="text-lg md:text-xl font-bold tracking-tight text-gray-900">{title}</h1>
            <div className="flex items-center gap-4">
                {children ?? <span className="text-sm text-gray-500">Dev App</span>}
            </div>
        </div>
    );
}
