'use client';

import { cn } from '@/lib/utils';
import { getStatusColor, getStatusBgColor, getPriorityColor } from '@/lib/utils';

interface BadgeProps {
    children: React.ReactNode;
    variant?: 'primary' | 'success' | 'warning' | 'danger' | 'info' | 'default';
    size?: 'sm' | 'md';
    className?: string;
}

export function Badge({ children, variant = 'default', size = 'sm', className }: BadgeProps) {
    const variants = {
        primary: 'bg-primary/20 text-primary',
        success: 'bg-emerald-500/20 text-emerald-500',
        warning: 'bg-amber-500/20 text-amber-500',
        danger: 'bg-rose-500/20 text-rose-500',
        info: 'bg-blue-500/20 text-blue-500',
        default: 'bg-white/10 text-white/70',
    };

    const sizes = {
        sm: 'px-2 py-0.5 text-[10px]',
        md: 'px-3 py-1 text-xs',
    };

    return (
        <span className={cn(
            'inline-flex items-center font-bold uppercase tracking-wider rounded-full',
            variants[variant],
            sizes[size],
            className
        )}>
            {children}
        </span>
    );
}

interface StatusBadgeProps {
    status: string;
    size?: 'sm' | 'md';
}

export function StatusBadge({ status, size = 'sm' }: StatusBadgeProps) {
    const statusLabels: Record<string, string> = {
        active: 'Aktif',
        banned: 'Yasaklı',
        deleted: 'Silinmiş',
        pending: 'Beklemede',
        reviewed: 'İncelendi',
        dismissed: 'Reddedildi',
        action_taken: 'İşlem Yapıldı',
        open: 'Açık',
        in_progress: 'İşlemde',
        waiting: 'Bekliyor',
        resolved: 'Çözüldü',
        closed: 'Kapalı',
        cancelled: 'İptal',
        expired: 'Süresi Doldu',
        paused: 'Duraklatıldı',
    };

    return (
        <span className={cn(
            'inline-flex items-center font-bold uppercase tracking-wider rounded-full',
            getStatusBgColor(status),
            getStatusColor(status),
            size === 'sm' ? 'px-2 py-0.5 text-[10px]' : 'px-3 py-1 text-xs'
        )}>
            {statusLabels[status] || status}
        </span>
    );
}

interface PriorityBadgeProps {
    priority: 'low' | 'medium' | 'high' | 'critical' | 'urgent';
}

export function PriorityBadge({ priority }: PriorityBadgeProps) {
    const labels: Record<string, string> = {
        low: 'Düşük',
        medium: 'Orta',
        high: 'Yüksek',
        critical: 'Kritik',
        urgent: 'Acil',
    };

    const colors: Record<string, string> = {
        low: 'bg-gray-500/20 text-gray-400',
        medium: 'bg-blue-500/20 text-blue-400',
        high: 'bg-amber-500/20 text-amber-400',
        critical: 'bg-rose-500/20 text-rose-400',
        urgent: 'bg-rose-500/20 text-rose-400',
    };

    return (
        <span className={cn(
            'inline-flex items-center px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded-full',
            colors[priority]
        )}>
            <span className={cn('w-1.5 h-1.5 rounded-full mr-1.5', {
                'bg-gray-400': priority === 'low',
                'bg-blue-400': priority === 'medium',
                'bg-amber-400': priority === 'high',
                'bg-rose-400 animate-pulse': priority === 'critical' || priority === 'urgent',
            })} />
            {labels[priority]}
        </span>
    );
}

interface TierBadgeProps {
    tier: 'basic' | 'gold' | 'platinum';
}

export function TierBadge({ tier }: TierBadgeProps) {
    const colors: Record<string, string> = {
        basic: 'bg-gray-500/20 text-gray-400 border-gray-500/30',
        gold: 'bg-primary/20 text-primary border-primary/30',
        platinum: 'bg-purple-500/20 text-purple-400 border-purple-500/30',
    };

    const labels: Record<string, string> = {
        basic: 'Basic',
        gold: 'Gold',
        platinum: 'Platinum',
    };

    return (
        <span className={cn(
            'inline-flex items-center px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded border',
            colors[tier]
        )}>
            {labels[tier]}
        </span>
    );
}
