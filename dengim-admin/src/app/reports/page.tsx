'use client';

import React, { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { PriorityBadge, StatusBadge } from '@/components/ui/Badge';
import { formatRelativeTime, cn } from '@/lib/utils';
import { ReportService } from '@/services/reportService';
import { UserService } from '@/services/userService';
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
            setReports(data as Report[]);
        } catch (error) {
            console.error('Reports fetch error:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleAction = async (reportId: string, status: Report['status'], collectionName: string = 'reports') => {
        try {
            await ReportService.updateReportStatus(reportId, status, undefined, collectionName);
            setReports(prev => prev.filter((r) => r.id !== reportId));
        } catch (error) {
            alert('İşlem başarısız');
        }
    };

    const handleBanUser = async (report: Report) => {
        if (!confirm('Bu kullanıcıyı banlamak istediğinize emin misiniz?')) return;

        try {
            await UserService.updateUserStatus(report.reportedUserId, 'ban');
            await ReportService.updateReportStatus(report.id, 'action_taken', 'Kullanıcı banlandı.', report.collection);
            setReports(prev => prev.filter((r) => r.id !== report.id));
            alert('Kullanıcı başarıyla banlandı.');
        } catch (error) {
            alert('Banlama işlemi başarısız oldu.');
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
                        {(['pending', 'resolved', 'all'] as const).map((tabKey) => (
                            <button
                                key={tabKey}
                                onClick={() => setActiveTab(tabKey)}
                                className={cn(
                                    'pb-3 pt-4 text-sm font-bold border-b-[3px] transition-colors',
                                    activeTab === tabKey
                                        ? 'text-white border-primary'
                                        : 'text-white/50 border-transparent hover:text-white/70'
                                )}
                            >
                                {tabKey === 'pending' ? 'Bekleyenler' : tabKey === 'resolved' ? 'Çözülenler' : 'Tümü'}
                            </button>
                        ))}
                    </div>

                    <div className="p-4 md:p-6">
                        {loading ? (
                            <div className="flex justify-center py-20">
                                <div className="h-10 w-10 border-4 border-primary border-t-transparent rounded-full animate-spin" />
                            </div>
                        ) : (
                            <div className="space-y-6">
                                {reports.length > 0 ? (
                                    reports.map((report) => (
                                        <div key={report.id}>
                                            <Card padding="md" className="hover:border-white/20 transition-all border-white/10">
                                                <div className="flex flex-col lg:flex-row justify-between gap-6">
                                                    <div className="flex-1 space-y-4">
                                                        {/* Header Info */}
                                                        <div className="flex justify-between items-start">
                                                            <div className="flex items-center gap-3">
                                                                <div className={cn(
                                                                    'h-10 w-10 rounded-lg flex items-center justify-center',
                                                                    report.priority === 'critical' || report.priority === 'high' ? 'bg-rose-500/20 text-rose-500' : 'bg-amber-500/20 text-amber-500'
                                                                )}>
                                                                    <span className="material-symbols-outlined">report</span>
                                                                </div>
                                                                <div>
                                                                    <h4 className="font-bold text-white text-lg">
                                                                        <span className="text-white/40 mr-2">[{report.type}]</span>
                                                                        {report.reasonDisplayName || report.reason}
                                                                    </h4>
                                                                    <p className="text-xs text-white/40">{formatRelativeTime(report.createdAt)} bildirildi</p>
                                                                </div>
                                                            </div>
                                                            <div className="flex gap-2">
                                                                <PriorityBadge priority={report.priority} />
                                                                <StatusBadge status={report.status} />
                                                            </div>
                                                        </div>

                                                        {/* Comparative Info */}
                                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                                            <div className="p-3 bg-white/5 rounded-xl border border-white/5">
                                                                <p className="text-[10px] text-white/30 uppercase font-bold mb-1">Raporlayan</p>
                                                                <p className="font-bold text-sm text-white">{report.reporterName}</p>
                                                                <p className="text-xs text-white/50">{report.reporterEmail || '-'}</p>
                                                                <p className="text-[10px] text-white/10 mt-1">ID: {report.reporterId}</p>
                                                            </div>
                                                            <div className="p-3 bg-rose-500/5 rounded-xl border border-rose-500/10">
                                                                <p className="text-[10px] text-rose-500/50 uppercase font-bold mb-1">Raporlanan</p>
                                                                <p className="font-bold text-sm text-white">{report.reportedUserName}</p>
                                                                <p className="text-xs text-white/50">{report.reportedUserEmail || '-'}</p>
                                                                <p className="text-[10px] text-white/20 mt-1 italic">UID: {report.reportedUserId}</p>
                                                            </div>
                                                        </div>

                                                        {/* Description */}
                                                        {report.description && (
                                                            <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                                                                <p className="text-[10px] text-white/30 uppercase font-bold mb-2">Detaylar / Mesaj İçeriği</p>
                                                                <p className="text-sm text-white/80 italic leading-relaxed">"{report.description}"</p>
                                                            </div>
                                                        )}
                                                    </div>

                                                    {/* Actions */}
                                                    <div className="lg:w-48 flex flex-col gap-2 pt-2 border-t lg:border-t-0 lg:border-l border-white/10 lg:pl-6">
                                                        <p className="text-[10px] text-white/30 uppercase font-bold mb-1 hidden lg:block">İşlemler</p>
                                                        <Button variant="outline" size="sm" onClick={() => handleAction(report.id, 'reviewed', report.collection)}>
                                                            <span className="material-symbols-outlined text-sm mr-2">visibility</span>
                                                            İnceledi
                                                        </Button>
                                                        <Button variant="secondary" size="sm" onClick={() => handleBanUser(report)}>
                                                            <span className="material-symbols-outlined text-sm mr-2">block</span>
                                                            Kullanıcıyı Banla
                                                        </Button>
                                                        <Button variant="ghost" size="sm" className="text-rose-500 hover:bg-rose-500/10" onClick={() => handleAction(report.id, 'dismissed', report.collection)}>
                                                            <span className="material-symbols-outlined text-sm mr-2">delete</span>
                                                            Yoksay
                                                        </Button>
                                                    </div>
                                                </div>
                                            </Card>
                                        </div>
                                    ))
                                ) : (
                                    <div className="text-center py-32 bg-surface-dark/50 rounded-3xl border border-dashed border-white/10">
                                        <span className="material-symbols-outlined text-7xl mb-4 opacity-10">shield_person</span>
                                        <p className="text-white/40 font-medium">Şu an müdahale gerektiren rapor bulunmuyor.</p>
                                        <p className="text-white/20 text-sm mt-2">Her şey yolunda görünüyor!</p>
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
