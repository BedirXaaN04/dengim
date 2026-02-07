'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { StatCard } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { cn, formatRelativeTime } from '@/lib/utils';
import { UserService } from '@/services/userService';
import { VerificationService } from '@/services/verificationService';
import { User, VerificationRequest } from '@/types';

export default function ModerationPage() {
    const [activeTab, setActiveTab] = useState<'photos' | 'bios' | 'id_verify' | 'settings'>('photos');
    const [pendingUsers, setPendingUsers] = useState<User[]>([]);
    const [pendingBios, setPendingBios] = useState<User[]>([]);
    const [verificationRequests, setVerificationRequests] = useState<VerificationRequest[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (activeTab === 'photos') {
            fetchPending();
        } else if (activeTab === 'bios') {
            fetchBios();
        } else if (activeTab === 'id_verify') {
            fetchVerifications();
        }
    }, [activeTab]);

    const fetchPending = async () => {
        setLoading(true);
        try {
            const data = await UserService.getPendingVerifications();
            setPendingUsers(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const fetchBios = async () => {
        setLoading(true);
        try {
            const data = await UserService.getFlaggedBios();
            setPendingBios(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const fetchVerifications = async () => {
        setLoading(true);
        try {
            const data = await VerificationService.getPendingRequests();
            setVerificationRequests(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleVerifyUser = async (userId: string, status: 'verify' | 'ban') => {
        try {
            await UserService.updateUserStatus(userId, status);
            setPendingUsers(prev => prev.filter(u => u.id !== userId));
        } catch (error) {
            alert('Hata oluştu');
        }
    };

    const handleVerificationAction = async (requestId: string, userId: string, action: 'approve' | 'reject') => {
        try {
            if (action === 'approve') {
                await VerificationService.approveRequest(requestId, userId);
            } else {
                const reason = prompt('Reddetme nedeni:') || 'Düşük kaliteli selfie veya yetersiz bilgi';
                await VerificationService.rejectRequest(requestId, userId, reason);
            }
            setVerificationRequests(prev => prev.filter(r => r.id !== requestId));
        } catch (error) {
            alert('Hata oluştu');
        }
    };

    const handleUpdateBio = async (userId: string, action: 'approve' | 'reject') => {
        try {
            if (action === 'reject') {
                await UserService.updateUser(userId, { bio: '' });
            }
            // For approve, we just clear it from the moderation list (local state)
            // In a real system you might have a 'isBioVerified' flag
            setPendingBios(prev => prev.filter(u => u.id !== userId));
        } catch (error) {
            alert('Hata oluştu');
        }
    };

    return (
        <div className="flex min-h-screen bg-background-dark">
            <Sidebar />
            <div className="flex-1 flex flex-col">
                <Header />
                <main className="flex-1 overflow-y-auto pb-24 md:pb-6 custom-scrollbar">
                    {/* Stats */}
                    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 p-4 md:p-6">
                        <StatCard
                            title="Bekleyen Onay"
                            value={pendingUsers.length}
                            icon={<span className="material-symbols-outlined text-xl">hourglass_empty</span>}
                            borderColor="border-l-primary"
                        />
                        <StatCard
                            title="Günlük Hedef"
                            value="500"
                            icon={<span className="material-symbols-outlined text-xl">task</span>}
                            borderColor="border-l-accent-indigo"
                        />
                    </div>

                    {/* Tabs */}
                    <div className="flex border-b border-white/10 px-4 gap-6 sticky top-0 bg-background-dark z-10">
                        {[
                            { key: 'photos', label: 'Fotoğraf Onayı', count: pendingUsers.length },
                            { key: 'id_verify', label: 'Mavi Tik Onayı', count: verificationRequests.length },
                            { key: 'bios', label: 'İçerik Kontrol' },
                            { key: 'settings', label: 'Kurallar' },
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
                                {tab.count !== undefined && (
                                    <span className={cn(
                                        'ml-2 px-1.5 py-0.5 text-[10px] rounded',
                                        activeTab === tab.key ? 'bg-primary text-black' : 'bg-white/10'
                                    )}>
                                        {tab.count}
                                    </span>
                                )}
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
                                {activeTab === 'photos' && (
                                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                                        {pendingUsers.length > 0 ? pendingUsers.map((user) => (
                                            <div key={user.id} className="bg-surface-dark rounded-2xl border border-white/10 overflow-hidden group">
                                                <div className="aspect-[3/4] relative bg-white/5">
                                                    {user.photos && user.photos.length > 0 ? (
                                                        <img src={user.photos[0]} alt={user.name} className="w-full h-full object-cover" />
                                                    ) : (
                                                        <div className="flex items-center justify-center h-full text-white/20">
                                                            <span className="material-symbols-outlined text-6xl">person</span>
                                                        </div>
                                                    )}
                                                    <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-4">
                                                        <button
                                                            onClick={() => handleVerifyUser(user.id, 'verify')}
                                                            className="h-14 w-14 rounded-full bg-emerald-500 flex items-center justify-center text-white hover:bg-emerald-400"
                                                        >
                                                            <span className="material-symbols-outlined">check</span>
                                                        </button>
                                                        <button
                                                            onClick={() => handleVerifyUser(user.id, 'ban')}
                                                            className="h-14 w-14 rounded-full bg-rose-500 flex items-center justify-center text-white hover:bg-rose-400"
                                                        >
                                                            <span className="material-symbols-outlined">close</span>
                                                        </button>
                                                    </div>
                                                </div>
                                                <div className="p-4">
                                                    <h4 className="font-bold text-white text-sm truncate">{user.name}</h4>
                                                    <p className="text-xs text-white/40">{formatRelativeTime(user.createdAt)} kayıt oldu</p>
                                                </div>
                                            </div>
                                        )) : (
                                            <div className="col-span-full py-20 text-center text-white/20">
                                                <span className="material-symbols-outlined text-6xl mb-4">verified</span>
                                                <p>Onay bekleyen içerik bulunmuyor.</p>
                                            </div>
                                        )}
                                    </div>
                                )}

                                {activeTab === 'id_verify' && (
                                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                                        {verificationRequests.length > 0 ? verificationRequests.map((req) => (
                                            <div key={req.id} className="bg-surface-dark rounded-2xl border border-white/10 overflow-hidden group">
                                                <div className="aspect-[3/4] relative bg-white/5">
                                                    <img src={req.selfieUrl} alt={req.email} className="w-full h-full object-cover" />
                                                    <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-4">
                                                        <button
                                                            onClick={() => handleVerificationAction(req.id, req.userId, 'approve')}
                                                            className="h-14 w-14 rounded-full bg-emerald-500 flex items-center justify-center text-white hover:bg-emerald-400"
                                                            title="Onayla"
                                                        >
                                                            <span className="material-symbols-outlined">check</span>
                                                        </button>
                                                        <button
                                                            onClick={() => handleVerificationAction(req.id, req.userId, 'reject')}
                                                            className="h-14 w-14 rounded-full bg-rose-500 flex items-center justify-center text-white hover:bg-rose-400"
                                                            title="Reddet"
                                                        >
                                                            <span className="material-symbols-outlined">close</span>
                                                        </button>
                                                    </div>
                                                </div>
                                                <div className="p-4">
                                                    <h4 className="font-bold text-white text-sm truncate">{req.email}</h4>
                                                    <p className="text-xs text-white/40">{formatRelativeTime(req.createdAt)}</p>
                                                    <Badge className="mt-2" variant="warning">Onay Bekliyor</Badge>
                                                </div>
                                            </div>
                                        )) : (
                                            <div className="col-span-full py-20 text-center text-white/20">
                                                <span className="material-symbols-outlined text-6xl mb-4">face</span>
                                                <p>Onay bekleyen kimlik doğrulaması bulunmuyor.</p>
                                            </div>
                                        )}
                                    </div>
                                )}

                                {activeTab === 'bios' && (
                                    <div className="space-y-4">
                                        {pendingBios.length > 0 ? pendingBios.map((user) => (
                                            <div key={user.id} className="bg-surface-dark rounded-xl border border-white/10 p-4">
                                                <div className="flex justify-between items-start mb-3">
                                                    <div className="flex items-center gap-3">
                                                        <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center text-primary">
                                                            <span className="material-symbols-outlined">person</span>
                                                        </div>
                                                        <div>
                                                            <h4 className="font-bold text-white text-sm">{user.name}</h4>
                                                            <p className="text-xs text-white/40">{formatRelativeTime(user.createdAt)}</p>
                                                        </div>
                                                    </div>
                                                    <div className="flex gap-2">
                                                        <Button
                                                            size="sm"
                                                            variant="secondary"
                                                            className="h-9 px-4 bg-emerald-500 hover:bg-emerald-400 border-none"
                                                            onClick={() => handleUpdateBio(user.id, 'approve')}
                                                        >
                                                            Onayla
                                                        </Button>
                                                        <Button
                                                            size="sm"
                                                            variant="ghost"
                                                            className="h-9 px-4 text-rose-500 hover:bg-rose-500/10"
                                                            onClick={() => handleUpdateBio(user.id, 'reject')}
                                                        >
                                                            Kaldır
                                                        </Button>
                                                    </div>
                                                </div>
                                                <div className="bg-white/5 p-4 rounded-xl text-white/80 text-sm leading-relaxed italic border border-white/5">
                                                    "{user.bio}"
                                                </div>
                                            </div>
                                        )) : (
                                            <div className="py-20 text-center text-white/20">
                                                <span className="material-symbols-outlined text-6xl mb-4">description</span>
                                                <p>İncelenecek biyografi bulunmuyor.</p>
                                            </div>
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
