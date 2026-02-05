'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { Card, StatCard } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { SupportService } from '@/services/supportService';
import { cn } from '@/lib/utils';

export default function SupportPage() {
    const [tickets, setTickets] = useState<any[]>([]);
    const [pendingCount, setPendingCount] = useState(0);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            const [data, count] = await Promise.all([
                SupportService.getTickets(),
                SupportService.getPendingCount()
            ]);
            setTickets(data);
            setPendingCount(count);
            setLoading(false);
        };
        fetchData();
    }, []);

    return (
        <div className="flex min-h-screen bg-background-dark">
            <Sidebar />
            <div className="flex-1 flex flex-col">
                <Header />
                <main className="flex-1 overflow-y-auto pb-24 md:pb-6 custom-scrollbar">
                    {/* Stats */}
                    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 p-4 md:p-6">
                        <StatCard
                            title="Açık Talepler"
                            value={pendingCount}
                            icon={<span className="material-symbols-outlined">confirmation_number</span>}
                            borderColor="border-l-primary"
                        />
                        <StatCard
                            title="Yanıt Bekleyen"
                            value="0"
                            borderColor="border-l-accent-indigo"
                        />
                        <StatCard
                            title="Ort. Yanıt Süresi"
                            value="-"
                            borderColor="border-l-accent-emerald"
                        />
                        <StatCard
                            title="Müşteri Memnuniyeti"
                            value="%100"
                            borderColor="border-l-primary"
                        />
                    </div>

                    <div className="p-4 md:p-6">
                        <div className="flex items-center justify-between mb-6">
                            <h2 className="text-xl font-bold text-white">Destek Talepleri</h2>
                            <div className="flex gap-2">
                                <Button size="sm" variant="outline">Tümünü Gör</Button>
                                <Button size="sm">Ayarlar</Button>
                            </div>
                        </div>

                        {loading ? (
                            <div className="flex justify-center py-20">
                                <div className="h-10 w-10 border-4 border-primary border-t-transparent rounded-full animate-spin" />
                            </div>
                        ) : (
                            <div className="space-y-4">
                                {tickets.length > 0 ? (
                                    tickets.map((ticket) => (
                                        <Card key={ticket.id} padding="md" hover>
                                            {/* Ticket Row */}
                                            <div className="flex items-center gap-4">
                                                <div className="h-10 w-10 rounded-full bg-white/5 flex items-center justify-center">
                                                    <span className="material-symbols-outlined text-white/40">person</span>
                                                </div>
                                                <div className="flex-1">
                                                    <h4 className="font-bold text-white">{ticket.subject || 'Konu Yok'}</h4>
                                                    <p className="text-xs text-white/40">{ticket.userName} • {ticket.category}</p>
                                                </div>
                                                <div className="hidden md:block px-3 py-1 bg-primary/10 text-primary border border-primary/20 rounded-full text-[10px] font-bold uppercase tracking-wider">
                                                    {ticket.status}
                                                </div>
                                            </div>
                                        </Card>
                                    ))
                                ) : (
                                    <div className="text-center py-24 bg-surface-dark/50 rounded-3xl border border-dashed border-white/10">
                                        <div className="h-20 w-20 bg-primary/5 rounded-full flex items-center justify-center mx-auto mb-6">
                                            <span className="material-symbols-outlined text-4xl text-primary/30">support_agent</span>
                                        </div>
                                        <h3 className="text-white font-bold mb-1">Şu an talep bulunmuyor</h3>
                                        <p className="text-white/30 text-sm">Kullanıcılar destek talebi açtığında burada görünecek.</p>
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
