'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { StatusBadge, TierBadge, Badge } from '@/components/ui/Badge';
import { cn, formatRelativeTime } from '@/lib/utils';
import { User } from '@/types';
import { UserService } from '@/services/userService';

export default function UsersPage() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState<string>('all');
    const [selectedUsers, setSelectedUsers] = useState<string[]>([]);
    const [lastDoc, setLastDoc] = useState<any>(null);

    // Verileri Çek
    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        setLoading(true);
        try {
            const result = await UserService.getUsers(null, 50); // İlk 50 kullanıcıyı çek
            setUsers(result.users);
            setLastDoc(result.lastDoc);
        } catch (error) {
            console.error('Kullanıcılar yüklenemedi:', error);
        } finally {
            setLoading(false);
        }
    };

    // Filtreleme (Client-side şimdilik)
    const filteredUsers = users.filter(user => {
        const matchesSearch = (user.name?.toLowerCase() || '').includes(searchQuery.toLowerCase()) ||
            (user.email?.toLowerCase() || '').includes(searchQuery.toLowerCase());
        const matchesStatus = statusFilter === 'all' || user.status === statusFilter;
        return matchesSearch && matchesStatus;
    });

    const toggleUserSelection = (userId: string) => {
        setSelectedUsers(prev =>
            prev.includes(userId)
                ? prev.filter(id => id !== userId)
                : [...prev, userId]
        );
    };

    const handleAction = async (userId: string, action: 'ban' | 'verify' | 'suspend') => {
        if (!confirm('Bu işlemi yapmak istediğinize emin misiniz?')) return;
        try {
            await UserService.updateUserStatus(userId, action);
            // Listeyi güncelle
            setUsers(prev => prev.map(u => {
                if (u.id === userId) {
                    return {
                        ...u,
                        status: action === 'ban' ? 'banned' : (action === 'verify' ? 'verified' : 'banned'),
                        isVerified: action === 'verify',
                    } as User;
                }
                return u;
            }));
        } catch (error) {
            alert('İşlem başarısız oldu.');
        }
    };

    // Pending verifications (gerçek veriden türetiliyor)
    const pendingVerifications = users.filter(u => !u.isVerified && u.photos && u.photos.length > 0).slice(0, 5);

    return (
        <div className="flex min-h-screen bg-background-dark">
            <Sidebar />
            <div className="flex-1 flex flex-col">
                <Header />
                <main className="flex-1 overflow-y-auto p-4 md:p-6 pb-24 md:pb-6 custom-scrollbar">
                    {/* Page Header */}
                    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
                        <div className="flex items-center gap-3">
                            <div className="h-12 w-12 rounded-xl bg-primary/20 flex items-center justify-center">
                                <span className="material-symbols-outlined text-primary text-2xl">admin_panel_settings</span>
                            </div>
                            <div>
                                <h2 className="text-xl font-bold text-white">Kullanıcı Yönetimi</h2>
                                <p className="text-sm text-slate-400">
                                    {loading ? 'Yükleniyor...' : `${users.length} kullanıcı gösteriliyor`}
                                </p>
                            </div>
                        </div>
                        <div className="flex gap-2">
                            <Button variant="outline" size="sm" onClick={fetchUsers}>
                                <span className="material-symbols-outlined text-sm">refresh</span>
                                Yenile
                            </Button>
                        </div>
                    </div>

                    {/* Search and Filters */}
                    <div className="mb-6">
                        <div className="flex flex-col md:flex-row gap-4 mb-4">
                            <div className="flex-1">
                                <div className="flex items-center h-14 bg-white/5 rounded-xl border border-white/10 px-4 gap-3">
                                    <span className="material-symbols-outlined text-primary">search</span>
                                    <input
                                        type="text"
                                        placeholder="Kullanıcı adı veya e-posta ile ara..."
                                        className="flex-1 bg-transparent border-none text-white placeholder:text-white/30 focus:outline-none"
                                        value={searchQuery}
                                        onChange={(e) => setSearchQuery(e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        <div className="flex gap-2 overflow-x-auto scrollbar-hide py-2">
                            {['all', 'active', 'verified', 'banned'].map((status) => (
                                <button
                                    key={status}
                                    onClick={() => setStatusFilter(status)}
                                    className={cn(
                                        'flex h-10 shrink-0 items-center justify-center rounded-full px-6 font-semibold text-sm transition-all',
                                        statusFilter === status
                                            ? 'bg-primary text-black'
                                            : 'bg-white/5 border border-white/10 text-white hover:bg-white/10'
                                    )}
                                >
                                    {status === 'all' ? 'Tümü' : status === 'active' ? 'Aktif' : status === 'verified' ? 'Doğrulanmış' : 'Yasaklı'}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Content */}
                    {loading ? (
                        <div className="flex justify-center py-20">
                            <div className="h-10 w-10 border-4 border-primary border-t-transparent rounded-full animate-spin" />
                        </div>
                    ) : (
                        <>
                            {/* Pending Verifications Strip */}
                            {pendingVerifications.length > 0 && (
                                <div className="mb-8">
                                    <h3 className="text-lg font-bold text-white mb-4">Hızlı Onay (Son Kayıtlar)</h3>
                                    <div className="flex overflow-x-auto gap-4 scrollbar-hide pb-2">
                                        {pendingVerifications.map((user) => (
                                            <div
                                                key={user.id}
                                                className="flex flex-col gap-3 min-w-[160px] bg-surface-dark p-3 rounded-xl border border-white/10 shadow-lg"
                                            >
                                                <div
                                                    className="w-full aspect-[3/4] bg-cover bg-center rounded-lg relative bg-white/5"
                                                    style={{ backgroundImage: user.photos[0] ? `url(${user.photos[0]})` : undefined }}
                                                >
                                                    {!user.photos[0] && (
                                                        <div className="absolute inset-0 flex items-center justify-center text-white/20">
                                                            <span className="material-symbols-outlined text-4xl">person</span>
                                                        </div>
                                                    )}
                                                </div>
                                                <div className="px-1">
                                                    <p className="font-bold text-sm text-white truncate">{user.name}</p>
                                                    <p className="text-xs text-white/50">{formatRelativeTime(user.createdAt)}</p>
                                                </div>
                                                <Button size="sm" className="w-full" onClick={() => handleAction(user.id, 'verify')}>
                                                    Doğrula
                                                </Button>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}

                            {/* User List */}
                            <h3 className="text-lg font-bold text-white mb-4">Kullanıcı Listesi</h3>
                            <div className="space-y-3">
                                {filteredUsers.map((user) => (
                                    <UserCard
                                        key={user.id}
                                        user={user}
                                        selected={selectedUsers.includes(user.id)}
                                        onSelect={() => toggleUserSelection(user.id)}
                                        onAction={handleAction}
                                    />
                                ))}

                                {filteredUsers.length === 0 && (
                                    <div className="text-center py-12">
                                        <span className="material-symbols-outlined text-6xl text-white/20 mb-4">search_off</span>
                                        <p className="text-white/50">Kullanıcı bulunamadı</p>
                                    </div>
                                )}
                            </div>
                        </>
                    )}
                </main>
                <BottomNav />
            </div>
        </div>
    );
}

function UserCard({ user, selected, onSelect, onAction }: {
    user: User;
    selected: boolean;
    onSelect: () => void;
    onAction: (id: string, action: 'ban' | 'verify' | 'suspend') => void;
}) {
    return (
        <div className={cn(
            'bg-surface-dark rounded-xl p-4 border transition-all',
            selected ? 'border-primary bg-primary/5' : 'border-white/10 hover:border-white/20'
        )}>
            <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-3">
                    <input
                        type="checkbox"
                        checked={selected}
                        onChange={onSelect}
                        className="h-4 w-4 rounded border-white/20 bg-white/5 text-primary focus:ring-primary/50"
                    />
                    <Avatar
                        src={user.photos[0]}
                        name={user.name}
                        size="lg"
                        verified={user.isVerified}
                        premium={user.isPremium}
                    />
                    <div>
                        <h4 className="font-bold text-white flex items-center gap-2">
                            {user.name}
                            {user.isVerified && (
                                <span className="material-symbols-outlined text-blue-400 text-sm">verified</span>
                            )}
                        </h4>
                        <p className="text-slate-400 text-xs">
                            ID: {user.id.substring(0, 8)}... | {user.location?.city || 'Bilinmiyor'}
                        </p>
                    </div>
                </div>
                <div className="flex flex-col items-end gap-1">
                    {user.isPremium && <TierBadge tier={user.premiumTier || 'basic'} />}
                    <StatusBadge status={user.status} />
                </div>
            </div>

            {/* Actions */}
            <div className="grid grid-cols-4 gap-2 border-t border-white/5 pt-3">
                <button className="flex flex-col items-center gap-1 py-2 text-slate-400 hover:text-white transition-colors">
                    <span className="material-symbols-outlined text-lg">visibility</span>
                    <span className="text-[10px] font-semibold">Gör</span>
                </button>
                <button className="flex flex-col items-center gap-1 py-2 text-slate-400 hover:text-white transition-colors">
                    <span className="material-symbols-outlined text-lg">edit</span>
                    <span className="text-[10px] font-semibold">Düzenle</span>
                </button>
                <button
                    onClick={() => onAction(user.id, 'verify')}
                    className="flex flex-col items-center gap-1 py-2 text-primary hover:text-primary/80 transition-colors"
                >
                    <span className="material-symbols-outlined text-lg">verified_user</span>
                    <span className="text-[10px] font-semibold">Doğrula</span>
                </button>
                <button
                    onClick={() => onAction(user.id, 'ban')}
                    className="flex flex-col items-center gap-1 py-2 text-rose-400 hover:text-rose-300 transition-colors"
                >
                    <span className="material-symbols-outlined text-lg">block</span>
                    <span className="text-[10px] font-semibold">Yasakla</span>
                </button>
            </div>
        </div>
    );
}
