'use client';

import React, { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { Card, StatCard } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { TierBadge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { GrowthChart } from '@/components/dashboard/Charts';
import { AnalyticsService } from '@/services/analyticsService';
import { UserService } from '@/services/userService';
import { formatCurrency, formatRelativeTime, cn } from '@/lib/utils';
import { User, DashboardStats } from '@/types';

export default function PremiumPage() {
    const [activeTab, setActiveTab] = useState<'overview' | 'subscribers'>('overview');
    const [stats, setStats] = useState<DashboardStats | null>(null);
    const [subscribers, setSubscribers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const loadData = async () => {
            setLoading(true);
            try {
                const [statsData, subsData] = await Promise.all([
                    AnalyticsService.getDashboardStats(),
                    UserService.getPremiumUsers()
                ]);
                setStats(statsData);
                setSubscribers(subsData);
            } catch (error) {
                console.error(error);
            } finally {
                setLoading(false);
            }
        };
        loadData();
    }, []);

    const revenueData = [
        { date: 'Ara 23', value: 12500 },
        { date: 'Oca 24', value: 18400 },
        { date: 'Şub 24', value: 24600 },
        { date: 'Mar 24', value: 31200 },
        { date: 'Nis 24', value: 28500 },
        { date: 'May 24', value: 35800 },
    ];

    return (
        <div className="flex min-h-screen bg-background-dark">
            <Sidebar />
            <div className="flex-1 flex flex-col">
                <Header />
                <main className="flex-1 overflow-y-auto pb-24 md:pb-6 custom-scrollbar">
                    {/* Tabs */}
                    <div className="flex border-b border-white/10 px-4 gap-6 sticky top-0 bg-background-dark z-10">
                        {[
                            { key: 'overview', label: 'Gelir Özeti' },
                            { key: 'subscribers', label: 'Aboneler' },
                        ].map((tab) => (
                            <button
                                key={tab.key}
                                onClick={() => setActiveTab(tab.key as any)}
                                className={cn(
                                    'pb-3 pt-4 text-sm font-bold border-b-[3px] transition-colors',
                                    activeTab === tab.key
                                        ? 'text-white border-primary'
                                        : 'text-white/50 border-transparent hover:text-white/70'
                                )}
                            >
                                {tab.label}
                            </button>
                        ))}
                    </div>

                    <div className="p-4 md:p-6">
                        {loading ? (
                            <div className="flex justify-center py-20">
                                <div className="h-10 w-10 border-4 border-primary border-t-transparent rounded-full animate-spin" />
                            </div>
                        ) : (
                            <>
                                {activeTab === 'overview' && (
                                    <div className="space-y-8">
                                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                                            <StatCard
                                                title="Aylık Gelir (MRR)"
                                                value={formatCurrency(stats?.mrr || 0, 'TRY')}
                                                borderColor="border-l-primary"
                                            />
                                            <StatCard
                                                title="Premium Üyeler"
                                                value={stats?.premiumUsers || 0}
                                                borderColor="border-l-accent-indigo"
                                            />
                                            <StatCard
                                                title="Dönüşüm"
                                                value={`${((stats?.premiumUsers || 0) / (stats?.totalUsers || 1) * 100).toFixed(1)}%`}
                                                borderColor="border-l-accent-emerald"
                                            />
                                        </div>

                                        <Card glass>
                                            <h3 className="text-lg font-bold text-white mb-6">Gelir Trendi</h3>
                                            <div className="h-[250px]">
                                                <GrowthChart data={revenueData} color="#ecb613" />
                                            </div>
                                        </Card>
                                    </div>
                                )}

                                {activeTab === 'subscribers' && (
                                    <div className="space-y-3">
                                        {subscribers.length > 0 ? subscribers.map((sub) => (
                                            <div key={sub.id} className="flex items-center gap-4 p-4 bg-surface-dark rounded-xl border border-white/10">
                                                <Avatar name={sub.name} premium />
                                                <div className="flex-1">
                                                    <div className="flex items-center gap-2 mb-1">
                                                        <p className="font-semibold text-white">{sub.name}</p>
                                                        <TierBadge tier={sub.premiumTier as any || 'basic'} />
                                                    </div>
                                                    <p className="text-xs text-white/40">
                                                        {formatRelativeTime(sub.createdAt)} katıldı
                                                    </p>
                                                </div>
                                                <Button variant="ghost" size="sm">Detay</Button>
                                            </div>
                                        )) : (
                                            <div className="py-20 text-center text-white/20">Henüz premium abonelik bulunmuyor.</div>
                                        )}
                                    </div>
                                )}
                            </>
                        )}
                    </div>
                </main>
                <BottomNav />
            </div>
        </div>
    );
}
