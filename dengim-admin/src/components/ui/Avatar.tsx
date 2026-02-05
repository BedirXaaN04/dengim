'use client';

import { cn } from '@/lib/utils';
import { getInitials } from '@/lib/utils';
import Image from 'next/image';

interface AvatarProps {
    src?: string;
    name: string;
    size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
    verified?: boolean;
    premium?: boolean;
    online?: boolean;
    className?: string;
}

export function Avatar({ src, name, size = 'md', verified, premium, online, className }: AvatarProps) {
    const sizes = {
        xs: 'h-6 w-6 text-[8px]',
        sm: 'h-8 w-8 text-xs',
        md: 'h-10 w-10 text-sm',
        lg: 'h-12 w-12 text-base',
        xl: 'h-16 w-16 text-lg',
    };

    const borderSizes = {
        xs: 'border',
        sm: 'border',
        md: 'border-2',
        lg: 'border-2',
        xl: 'border-2',
    };

    const badgeSizes = {
        xs: 'h-2 w-2 -right-0 -bottom-0',
        sm: 'h-2.5 w-2.5 -right-0.5 -bottom-0.5',
        md: 'h-3 w-3 -right-0.5 -bottom-0.5',
        lg: 'h-3.5 w-3.5 -right-1 -bottom-1',
        xl: 'h-4 w-4 -right-1 -bottom-1',
    };

    return (
        <div className={cn('relative inline-block', className)}>
            <div className={cn(
                'rounded-full overflow-hidden flex items-center justify-center bg-surface-dark',
                sizes[size],
                premium ? 'border-primary' : 'border-white/20',
                borderSizes[size]
            )}>
                {src ? (
                    <Image
                        src={src}
                        alt={name}
                        width={64}
                        height={64}
                        className="h-full w-full object-cover"
                    />
                ) : (
                    <span className="font-bold text-primary">{getInitials(name)}</span>
                )}
            </div>

            {/* Verified Badge */}
            {verified && (
                <div className={cn(
                    'absolute flex items-center justify-center rounded-full bg-blue-500',
                    badgeSizes[size]
                )}>
                    <span className="material-symbols-outlined text-white text-[8px]" style={{ fontSize: size === 'xs' || size === 'sm' ? '6px' : '10px' }}>
                        check
                    </span>
                </div>
            )}

            {/* Online Indicator */}
            {online && !verified && (
                <div className={cn(
                    'absolute rounded-full bg-emerald-500 border-2 border-background-dark',
                    badgeSizes[size]
                )} />
            )}
        </div>
    );
}

interface AvatarGroupProps {
    users: { src?: string; name: string }[];
    max?: number;
    size?: 'sm' | 'md';
}

export function AvatarGroup({ users, max = 4, size = 'md' }: AvatarGroupProps) {
    const displayed = users.slice(0, max);
    const remaining = users.length - max;

    return (
        <div className="flex -space-x-2">
            {displayed.map((user, i) => (
                <Avatar
                    key={i}
                    src={user.src}
                    name={user.name}
                    size={size}
                    className="ring-2 ring-background-dark"
                />
            ))}
            {remaining > 0 && (
                <div className={cn(
                    'rounded-full bg-white/10 flex items-center justify-center text-xs font-bold text-white/70 ring-2 ring-background-dark',
                    size === 'sm' ? 'h-8 w-8' : 'h-10 w-10'
                )}>
                    +{remaining}
                </div>
            )}
        </div>
    );
}
