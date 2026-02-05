import { clsx, type ClassValue } from "clsx";

export function cn(...inputs: ClassValue[]) {
    return clsx(inputs);
}

export function formatNumber(num: number): string {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    }
    if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toString();
}

export function formatCurrency(amount: number, currency: string = 'TRY'): string {
    return new Intl.NumberFormat('tr-TR', {
        style: 'currency',
        currency,
        minimumFractionDigits: 0,
        maximumFractionDigits: 2,
    }).format(amount);
}

export function formatDate(date: Date | string): string {
    const d = typeof date === 'string' ? new Date(date) : date;
    return new Intl.DateTimeFormat('tr-TR', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
    }).format(d);
}

export function formatDateTime(date: Date | string): string {
    const d = typeof date === 'string' ? new Date(date) : date;
    return new Intl.DateTimeFormat('tr-TR', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    }).format(d);
}

export function formatRelativeTime(date: Date | string): string {
    const d = typeof date === 'string' ? new Date(date) : date;
    const now = new Date();
    const diff = now.getTime() - d.getTime();

    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return 'Şimdi';
    if (minutes < 60) return `${minutes} dk önce`;
    if (hours < 24) return `${hours} saat önce`;
    if (days < 7) return `${days} gün önce`;

    return formatDate(d);
}

export function getInitials(name: string): string {
    return name
        .split(' ')
        .map(n => n[0])
        .slice(0, 2)
        .join('')
        .toUpperCase();
}

export function getStatusColor(status: string): string {
    const colors: Record<string, string> = {
        active: 'text-emerald-500',
        banned: 'text-rose-500',
        deleted: 'text-gray-500',
        pending: 'text-amber-500',
        reviewed: 'text-blue-500',
        dismissed: 'text-gray-500',
        action_taken: 'text-emerald-500',
    };
    return colors[status] || 'text-gray-500';
}

export function getStatusBgColor(status: string): string {
    const colors: Record<string, string> = {
        active: 'bg-emerald-500/20',
        banned: 'bg-rose-500/20',
        deleted: 'bg-gray-500/20',
        pending: 'bg-amber-500/20',
        reviewed: 'bg-blue-500/20',
        dismissed: 'bg-gray-500/20',
        action_taken: 'bg-emerald-500/20',
    };
    return colors[status] || 'bg-gray-500/20';
}

export function getPriorityColor(priority: string): string {
    const colors: Record<string, string> = {
        low: 'text-gray-400',
        medium: 'text-blue-400',
        high: 'text-amber-400',
        critical: 'text-rose-400',
    };
    return colors[priority] || 'text-gray-400';
}

export function truncateText(text: string, maxLength: number): string {
    if (text.length <= maxLength) return text;
    return text.slice(0, maxLength) + '...';
}

export function generateId(): string {
    return Math.random().toString(36).substring(2, 9);
}

export function debounce<T extends (...args: unknown[]) => unknown>(
    func: T,
    wait: number
): (...args: Parameters<T>) => void {
    let timeoutId: NodeJS.Timeout | null = null;

    return (...args: Parameters<T>) => {
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
        timeoutId = setTimeout(() => func(...args), wait);
    };
}

export function sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
}
