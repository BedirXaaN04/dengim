'use client';

import { cn } from '@/lib/utils';

interface CardProps {
    children: React.ReactNode;
    className?: string;
    hover?: boolean;
    glass?: boolean;
    padding?: 'none' | 'sm' | 'md' | 'lg';
    onClick?: () => void;
}

export function Card({ children, className, hover = false, glass = false, padding = 'md', onClick }: CardProps) {
    const paddingStyles = {
        none: '',
        sm: 'p-4',
        md: 'p-6',
        lg: 'p-8',
    };

    return (
        <div
            onClick={onClick}
            className={cn(
                'rounded-xl border',
                glass
                    ? 'glass'
                    : 'bg-surface-dark border-white/10',
                (hover || onClick) && 'card-hover cursor-pointer',
                paddingStyles[padding],
                className
            )}
        >
            {children}
        </div>
    );
}

interface StatCardProps {
    title: string;
    value: string | number;
    subValue?: string;
    change?: {
        value: number;
        type: 'increase' | 'decrease';
    };
    icon?: React.ReactNode;
    borderColor?: string;
    onClick?: () => void;
}

export function StatCard({ title, value, subValue, change, icon, borderColor = 'border-l-primary', onClick }: StatCardProps) {
    return (
        <div
            className={cn(
                'glass p-6 rounded-xl flex flex-col gap-2 border-l-4',
                borderColor,
                onClick && 'cursor-pointer card-hover'
            )}
            onClick={onClick}
        >
            <div className="flex items-center justify-between">
                <p className="text-zinc-400 text-xs font-semibold uppercase tracking-wider">{title}</p>
                {icon && <div className="text-primary">{icon}</div>}
            </div>
            <div className="flex flex-col">
                <div className="flex items-end justify-between">
                    <h3 className="text-3xl font-bold text-white">{value}</h3>
                    {change && (
                        <span className={cn(
                            'text-sm font-medium flex items-center gap-1',
                            change.type === 'increase' ? 'text-emerald-400' : 'text-rose-400'
                        )}>
                            <span className="material-symbols-outlined text-sm">
                                {change.type === 'increase' ? 'trending_up' : 'trending_down'}
                            </span>
                            {change.value}%
                        </span>
                    )}
                </div>
                {subValue && (
                    <p className="text-[10px] text-zinc-500 font-medium mt-1">{subValue}</p>
                )}
            </div>
        </div>
    );
}

interface AlertCardProps {
    type: 'success' | 'warning' | 'error' | 'info';
    title: string;
    description?: string;
    time?: string;
    icon?: string;
    onClick?: () => void;
}

export function AlertCard({ type, title, description, time, icon, onClick }: AlertCardProps) {
    const colors = {
        success: 'bg-emerald-500/20 text-emerald-500',
        warning: 'bg-amber-500/20 text-amber-500',
        error: 'bg-rose-500/20 text-rose-500',
        info: 'bg-blue-500/20 text-blue-500',
    };

    return (
        <div
            className={cn(
                'flex gap-4 p-4 rounded-xl bg-white/5 border border-white/5',
                onClick && 'cursor-pointer hover:bg-white/10 transition-colors'
            )}
            onClick={onClick}
        >
            <div className={cn('h-10 w-10 rounded-full flex items-center justify-center shrink-0', colors[type])}>
                <span className="material-symbols-outlined text-lg">{icon || 'info'}</span>
            </div>
            <div className="flex-1 overflow-hidden">
                <p className="text-sm font-semibold truncate text-white">{title}</p>
                {description && <p className="text-xs text-white/50 mt-0.5 line-clamp-2">{description}</p>}
                {time && <p className="text-[10px] text-primary mt-1">{time}</p>}
            </div>
        </div>
    );
}
