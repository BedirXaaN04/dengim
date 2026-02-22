'use client';

import { InputHTMLAttributes, forwardRef } from 'react';
import { cn } from '@/lib/utils';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement | HTMLTextAreaElement> {
    label?: string;
    error?: string;
    icon?: React.ReactNode;
    multiline?: boolean;
}

const Input = forwardRef<HTMLInputElement | HTMLTextAreaElement, InputProps>(
    ({ className, label, error, icon, multiline, ...props }, ref) => {
        const inputClasses = cn(
            'w-full bg-white/5 border border-white/10 rounded-xl px-4 text-white placeholder:text-white/30',
            'focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20',
            'transition-all duration-200',
            multiline ? 'py-3 min-height-[120px] resize-none' : 'h-12',
            icon && 'pl-10',
            error && 'border-rose-500 focus:border-rose-500 focus:ring-rose-500/20',
            className
        );

        return (
            <div className="space-y-1.5">
                {label && (
                    <label className="text-sm font-medium text-white/70">
                        {label}
                    </label>
                )}
                <div className="relative">
                    {icon && (
                        <div className="absolute left-3 top-1/2 -translate-y-1/2 text-white/40">
                            {icon}
                        </div>
                    )}
                    {multiline ? (
                        <textarea
                            ref={ref as React.Ref<HTMLTextAreaElement>}
                            className={inputClasses}
                            {...(props as React.TextareaHTMLAttributes<HTMLTextAreaElement>)}
                        />
                    ) : (
                        <input
                            ref={ref as React.Ref<HTMLInputElement>}
                            className={inputClasses}
                            {...(props as React.InputHTMLAttributes<HTMLInputElement>)}
                        />
                    )}
                </div>
                {error && (
                    <p className="text-xs text-rose-500">{error}</p>
                )}
            </div>
        );
    }
);

Input.displayName = 'Input';

export { Input };
