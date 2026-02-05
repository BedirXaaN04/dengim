'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { Card, StatCard } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { cn, formatRelativeTime } from '@/lib/utils';
import { NotificationService } from '@/services/notificationService';

export default function NotificationsPage() {
    const [activeTab, setActiveTab] = useState<'push' | 'email' | 'history'>('push');
    const [selectedSegment, setSelectedSegment] = useState('all');
    const [counts, setCounts] = useState({ all: 0, premium: 0, new: 0, inactive: 0 });
    const [loading, setLoading] = useState(false);
    const [sentStatus, setSentStatus] = useState<string | null>(null);

    // Form State
    const [title, setTitle] = useState('');
    const [body, setBody] = useState('');
    const [imageUrl, setImageUrl] = useState('');

    useEffect(() => {
        const fetchCounts = async () => {
            const data = await NotificationService.getSegmentCounts();
            setCounts(data);
        };
        fetchCounts();
    }, []);

    const handleSend = async () => {
        if (!title || !body) return alert("Başlık ve içeriği doldurun!");

        setLoading(true);
        const success = await NotificationService.sendPushNotification({
            title,
            body,
            segment: selectedSegment,
            imageUrl: imageUrl || undefined
        });

        if (success) {
            setSentStatus("Bildirim başarıyla sıraya alındı!");
            setTitle('');
            setBody('');
            setImageUrl('');
            setTimeout(() => setSentStatus(null), 3000);
        } else {
            alert("Bir hata oluştu.");
        }
        setLoading(false);
    };

    return (
        <div className="flex min-h-screen bg-background-dark">
            <Sidebar />
            <div className="flex-1 flex flex-col">
                <Header />
                <main className="flex-1 overflow-y-auto pb-24 md:pb-6 custom-scrollbar">
                    {/* Stats */}
                    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 p-4 md:p-6">
                        <StatCard title="Bugün Gönderilen" value="0" borderColor="border-l-primary" />
                        <StatCard title="Açılma Oranı" value="0%" borderColor="border-l-accent-indigo" />
                        <StatCard title="Tıklama Oranı" value="0%" borderColor="border-l-accent-emerald" />
                        <StatCard title="Toplam Abone" value={counts.all.toLocaleString()} borderColor="border-l-primary" />
                    </div>

                    {/* Tabs */}
                    <div className="flex border-b border-white/10 px-4 gap-6 sticky top-0 bg-background-dark z-10">
                        {['push', 'email', 'history'].map((key) => (
                            <button
                                key={key}
                                onClick={() => setActiveTab(key as any)}
                                className={cn(
                                    'pb-3 pt-4 text-sm font-bold border-b-[3px] transition-colors uppercase',
                                    activeTab === key ? 'text-white border-primary' : 'text-white/50 border-transparent hover:text-white/70'
                                )}
                            >
                                {key === 'push' ? 'Push Bildirimi' : key === 'email' ? 'E-posta' : 'Geçmiş'}
                            </button>
                        ))}
                    </div>

                    <div className="p-4 md:p-6">
                        {activeTab === 'push' && (
                            <div className="max-w-3xl">
                                <Card glass className="mb-6">
                                    <h3 className="text-lg font-bold text-white mb-4">Yeni Bildirim Oluştur</h3>

                                    {/* Segment Selection */}
                                    <div className="mb-6">
                                        <label className="text-xs font-bold text-white/40 mb-3 block uppercase tracking-wider">Hedef Kitle</label>
                                        <div className="flex flex-wrap gap-2">
                                            {[
                                                { id: 'all', label: 'Tüm Kullanıcılar', count: counts.all },
                                                { id: 'premium', label: 'Premium Üyeler', count: counts.premium },
                                                { id: 'new', label: 'Yeni Üyeler (7g)', count: counts.new },
                                                { id: 'inactive', label: 'Inaktif Üyeler', count: counts.inactive },
                                            ].map((segment) => (
                                                <button
                                                    key={segment.id}
                                                    onClick={() => setSelectedSegment(segment.id)}
                                                    className={cn(
                                                        'px-4 py-2.5 rounded-xl text-sm font-semibold transition-all border',
                                                        selectedSegment === segment.id
                                                            ? 'bg-primary text-black border-primary'
                                                            : 'bg-white/5 text-white/60 border-white/5 hover:border-white/20'
                                                    )}
                                                >
                                                    {segment.label}
                                                    <span className="ml-2 opacity-50 text-[10px]">{segment.count}</span>
                                                </button>
                                            ))}
                                        </div>
                                    </div>

                                    <div className="space-y-4">
                                        <div>
                                            <label className="text-xs font-bold text-white/40 mb-2 block uppercase tracking-wider">Başlık</label>
                                            <input
                                                value={title}
                                                onChange={(e) => setTitle(e.target.value)}
                                                placeholder="Örn: Merhaba Arda! Yeni biri seni beğendi."
                                                className="w-full h-12 bg-white/5 border border-white/10 rounded-xl px-4 text-white focus:border-primary outline-none transition-all"
                                            />
                                        </div>

                                        <div>
                                            <label className="text-xs font-bold text-white/40 mb-2 block uppercase tracking-wider">İçerik</label>
                                            <textarea
                                                value={body}
                                                onChange={(e) => setBody(e.target.value)}
                                                rows={3}
                                                placeholder="Bildirim detaylarını buraya yazın..."
                                                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white focus:border-primary outline-none transition-all resize-none"
                                            />
                                        </div>

                                        <div>
                                            <label className="text-xs font-bold text-white/40 mb-2 block uppercase tracking-wider">Görsel URL (Opsiyonel)</label>
                                            <input
                                                value={imageUrl}
                                                onChange={(e) => setImageUrl(e.target.value)}
                                                placeholder="https://..."
                                                className="w-full h-12 bg-white/5 border border-white/10 rounded-xl px-4 text-white focus:border-primary outline-none"
                                            />
                                        </div>

                                        {sentStatus && (
                                            <div className="p-3 bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 rounded-xl text-center text-sm font-medium">
                                                {sentStatus}
                                            </div>
                                        )}

                                        <Button
                                            onClick={handleSend}
                                            loading={loading}
                                            className="w-full h-14 text-base mt-2"
                                        >
                                            <span className="material-symbols-outlined mr-2">send_to_mobile</span>
                                            Bildirimi Hemen Gönder
                                        </Button>
                                    </div>
                                </Card>
                            </div>
                        )}

                        {activeTab === 'history' && (
                            <div className="text-center py-20 text-white/20">
                                <span className="material-symbols-outlined text-6xl mb-4">history</span>
                                <p>Bildirim geçmişi şu an boş.</p>
                            </div>
                        )}

                        {activeTab === 'email' && (
                            <div className="text-center py-20 text-white/20 italic">
                                E-posta servisi şu an devre dışı.
                            </div>
                        )}
                    </div>
                </main>
                <BottomNav />
            </div>
        </div>
    );
}
