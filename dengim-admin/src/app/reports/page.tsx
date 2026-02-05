'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { PriorityBadge, StatusBadge } from '@/components/ui/Badge';
import { formatRelativeTime, cn } from '@/lib/utils';
import { ReportService } from '@/services/reportService';
import { Report } from '@/types';

export default function ReportsPage() {
    const [activeTab, setActiveTab] = useState<'pending' | 'resolved' | 'all'>('pending');
    const [reports, setReports] = useState<Report[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchReports();
    }, [activeTab]);

    const fetchReports = async () => {
        setLoading(true);
        try {
            const data = await ReportService.getReports(activeTab === 'all' ? 'all' : activeTab);
            setReports(data);
        } catch (error) {
            console.error('Reports fetch error:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleAction = async (reportId: string, status: Report['status']) => {
        try {
            await ReportService.updateReportStatus(reportId, status);
            setReports(prev => prev.filter(r => r.id !== reportId));
        } catch (error) {
            alert('İşlem başarısız');
        }
    };

    return (
        <div className="flex min-h-screen bg-background-dark">
            <Sidebar />
            <div className="flex-1 flex flex-col">
                <Header />
                <main className="flex-1 overflow-y-auto pb-24 md:pb-6 custom-scrollbar">
                    {/* Tabs */}
                    <div className="flex border-b border-white/10 px-4 gap-8 sticky top-0 bg-background-dark z-10">
                        {[
                            { key: 'pending', label: 'Bekleyenler' },
                            { key: 'resolved', label: 'Çözülenler' },
                            { key: 'all', label: 'Tümü' },
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
                            <div className="space-y-4">
                                {reports.length > 0 ? (
                                    reports.map((report) => (
                                        <div key={report.id} className="bg-surface-dark rounded-xl border border-white/10 p-4 hover:border-white/20 transition-all">
                                            <div className="flex justify-between items-start mb-4">
                                                <div className="flex gap-4">
                                                    <div className={cn(
                                                        'h-12 w-12 rounded-xl flex items-center justify-center shrink-0',
                                                        report.priority === 'critical' ? 'bg-rose-500/20 text-rose-500' : 'bg-amber-500/20 text-amber-500'
                                                    )}>
                                                        <span className="material-symbols-outlined">report</span>
                                                    </div>
                                                    <div>
                                                        <div className="flex items-center gap-2 mb-1">
                                                            <h4 className="font-bold text-white">{report.reasonDisplayName || report.reason}</h4>
                                                            <PriorityBadge priority={report.priority} />
                                                        </div>
                                                        <p className="text-xs text-white/50">
                                                            {report.reporterName} → {report.reportedUserName} • {formatRelativeTime(report.createdAt)}
                                                        </p>
                                                    </div>
                                                </div>
                                                <StatusBadge status={report.status} />
                                            </div>

                                            {report.description && (
                                                <div className="bg-white/5 p-3 rounded-lg text-sm text-white/70 mb-4 italic">
                                                    "{report.description}"
                                                </div>
                                            )}

                                            <div className="flex gap-2">
                                                <Button size="sm" variant="outline" className="flex-1" onClick={() => handleAction(report.id, 'reviewed')}>
                                                    İnceledi
                                                </Button>
                                                <Button size="sm" variant="secondary" className="flex-1" onClick={() => handleAction(report.id, 'action_taken')}>
                                                    İşlem Yap
                                                </Button>
                                                <Button size="sm" variant="ghost" className="flex-1 text-rose-500" onClick={() => handleAction(report.id, 'dismissed')}>
                                                    Yoksay
                                                </Button>
                                            </div>
                                        </div>
                                    ))
                                ) : (
                                    <div className="text-center py-20 text-white/30">
                                        <span className="material-symbols-outlined text-6xl mb-4 opacity-20">inventory_2</span>
                                        <p>Rapor kaydı bulunamadı.</p>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                </main>
                <BottomNav />
            </div>
        </div>
    );
}
