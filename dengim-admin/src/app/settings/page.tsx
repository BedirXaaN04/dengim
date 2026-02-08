'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { BottomNav } from '@/components/layout/BottomNav';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { cn } from '@/lib/utils';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';

const settingSections = [
    { id: 'general', label: 'Genel', icon: 'tune' },
    { id: 'security', label: 'Güvenlik', icon: 'shield' },
    { id: 'admins', label: 'Yöneticiler', icon: 'admin_panel_settings' },
    { id: 'api', label: 'API', icon: 'api' },
    { id: 'logs', label: 'Loglar', icon: 'history' },
];

export default function SettingsPage() {
    const [activeSection, setActiveSection] = useState('general');
    const [darkMode, setDarkMode] = useState(true);
    const [isVipEnabled, setIsVipEnabled] = useState(false);
    const [isAdsEnabled, setIsAdsEnabled] = useState(true);
    const [isCreditsEnabled, setIsCreditsEnabled] = useState(false);
    const [isSaving, setIsSaving] = useState(false);

    // Yeni state'ler - tüm ayarları kaydetmek için
    const [minimumAge, setMinimumAge] = useState(18);
    const [maxDistance, setMaxDistance] = useState(100);
    const [dailyLikeLimit, setDailyLikeLimit] = useState(25);
    const [locationWeight, setLocationWeight] = useState(35);
    const [interestsWeight, setInterestsWeight] = useState(40);
    const [activityWeight, setActivityWeight] = useState(25);
    const [isMaintenanceMode, setIsMaintenanceMode] = useState(false);
    const [maintenanceMessage, setMaintenanceMessage] = useState('');

    // Initial load from Firestore
    useEffect(() => {
        const loadConfig = async () => {
            const docSnap = await getDoc(doc(db, 'system', 'config'));
            if (docSnap.exists()) {
                const data = docSnap.data();
                setIsVipEnabled(data.isVipEnabled ?? false);
                setIsAdsEnabled(data.isAdsEnabled ?? true);
                setIsCreditsEnabled(data.isCreditsEnabled ?? false);
                // Yeni alanları yükle
                setMinimumAge(data.minimumAge ?? 18);
                setMaxDistance(data.maxDistance ?? 100);
                setDailyLikeLimit(data.dailyLikeLimit ?? 25);
                setLocationWeight(data.locationWeight ?? 35);
                setInterestsWeight(data.interestsWeight ?? 40);
                setActivityWeight(data.activityWeight ?? 25);
                setIsMaintenanceMode(data.isMaintenanceMode ?? false);
                setMaintenanceMessage(data.maintenanceMessage ?? '');
            }
        };
        loadConfig();
    }, []);

    const handleSave = async () => {
        setIsSaving(true);
        try {
            await setDoc(doc(db, 'system', 'config'), {
                isVipEnabled,
                isAdsEnabled,
                isCreditsEnabled,
                // Yeni alanları kaydet
                minimumAge,
                maxDistance,
                dailyLikeLimit,
                locationWeight,
                interestsWeight,
                activityWeight,
                isMaintenanceMode,
                maintenanceMessage,
                updatedAt: new Date().toISOString()
            }, { merge: true });

            alert('Ayarlar başarıyla kaydedildi!');
        } catch (error) {
            console.error('Error saving settings:', error);
            alert('Hata oluştu!');
        } finally {
            setIsSaving(false);
        }
    };

    return (
        <div className="flex min-h-screen bg-background-dark">
            <Sidebar />
            <div className="flex-1 flex flex-col">
                <Header />
                <main className="flex-1 overflow-y-auto p-4 md:p-6 pb-24 md:pb-6 custom-scrollbar">
                    <div className="max-w-4xl mx-auto">
                        {/* Page Header */}
                        <div className="mb-6">
                            <h2 className="text-2xl font-bold text-white">Ayarlar</h2>
                            <p className="text-slate-400 text-sm">Platform yapılandırması ve güvenlik ayarları</p>
                        </div>

                        {/* Section Tabs */}
                        <div className="flex gap-2 mb-6 overflow-x-auto scrollbar-hide pb-2">
                            {settingSections.map((section) => (
                                <button
                                    key={section.id}
                                    onClick={() => setActiveSection(section.id)}
                                    className={cn(
                                        'flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all shrink-0',
                                        activeSection === section.id
                                            ? 'bg-primary text-black'
                                            : 'bg-white/5 text-white/70 hover:bg-white/10'
                                    )}
                                >
                                    <span className="material-symbols-outlined text-lg">{section.icon}</span>
                                    {section.label}
                                </button>
                            ))}
                        </div>

                        {/* General Settings */}
                        {activeSection === 'general' && (
                            <div className="space-y-6">
                                <Card glass>
                                    <h3 className="text-lg font-bold text-white mb-4">Sistem Kontrolü (Aç/Kapat)</h3>
                                    <div className="space-y-4">
                                        <div className="flex items-center justify-between py-3 border-b border-white/5">
                                            <div>
                                                <p className="font-medium text-white">VIP / Premium Sistemi</p>
                                                <p className="text-xs text-white/50">Aktif edildiğinde bazı özellikler VIP şartına bağlanır</p>
                                            </div>
                                            <button
                                                onClick={() => setIsVipEnabled(!isVipEnabled)}
                                                className={cn(
                                                    'relative w-14 h-8 rounded-full transition-colors',
                                                    isVipEnabled ? 'bg-primary' : 'bg-white/20'
                                                )}
                                            >
                                                <span className={cn(
                                                    'absolute top-1 w-6 h-6 rounded-full bg-white shadow-lg transition-transform',
                                                    isVipEnabled ? 'left-7' : 'left-1'
                                                )} />
                                            </button>
                                        </div>
                                        <div className="flex items-center justify-between py-3 border-b border-white/5">
                                            <div>
                                                <p className="font-medium text-white">AdMob Reklamları</p>
                                                <p className="text-xs text-white/50">Uygulama içi ödüllü reklamları aktif eder</p>
                                            </div>
                                            <button
                                                onClick={() => setIsAdsEnabled(!isAdsEnabled)}
                                                className={cn(
                                                    'relative w-14 h-8 rounded-full transition-colors',
                                                    isAdsEnabled ? 'bg-primary' : 'bg-white/20'
                                                )}
                                            >
                                                <span className={cn(
                                                    'absolute top-1 w-6 h-6 rounded-full bg-white shadow-lg transition-transform',
                                                    isAdsEnabled ? 'left-7' : 'left-1'
                                                )} />
                                            </button>
                                        </div>
                                        <div className="flex items-center justify-between py-3">
                                            <div>
                                                <p className="font-medium text-white">Kredi Sistemi</p>
                                                <p className="text-xs text-white/50">Mesajlaşma ve diğer eylemler için kredi şartı</p>
                                            </div>
                                            <button
                                                onClick={() => setIsCreditsEnabled(!isCreditsEnabled)}
                                                className={cn(
                                                    'relative w-14 h-8 rounded-full transition-colors',
                                                    isCreditsEnabled ? 'bg-primary' : 'bg-white/20'
                                                )}
                                            >
                                                <span className={cn(
                                                    'absolute top-1 w-6 h-6 rounded-full bg-white shadow-lg transition-transform',
                                                    isCreditsEnabled ? 'left-7' : 'left-1'
                                                )} />
                                            </button>
                                        </div>
                                    </div>
                                </Card>

                                <Card glass>
                                    <h3 className="text-lg font-bold text-white mb-4">Uygulama Ayarları</h3>
                                    <div className="space-y-4">
                                        <div className="flex items-center justify-between py-3 border-b border-white/5">
                                            <div>
                                                <p className="font-medium text-white">Minimum Yaş</p>
                                                <p className="text-xs text-white/50">Kayıt için minimum yaş sınırı</p>
                                            </div>
                                            <input
                                                type="number"
                                                defaultValue={18}
                                                className="w-20 h-10 bg-white/5 border border-white/10 rounded-lg px-3 text-center text-white"
                                            />
                                        </div>
                                        <div className="flex items-center justify-between py-3 border-b border-white/5">
                                            <div>
                                                <p className="font-medium text-white">Maksimum Mesafe</p>
                                                <p className="text-xs text-white/50">Varsayılan arama mesafesi (km)</p>
                                            </div>
                                            <input
                                                type="number"
                                                defaultValue={100}
                                                className="w-20 h-10 bg-white/5 border border-white/10 rounded-lg px-3 text-center text-white"
                                            />
                                        </div>
                                        <div className="flex items-center justify-between py-3 border-b border-white/5">
                                            <div>
                                                <p className="font-medium text-white">Günlük Beğeni Limiti</p>
                                                <p className="text-xs text-white/50">Ücretsiz kullanıcılar için</p>
                                            </div>
                                            <input
                                                type="number"
                                                defaultValue={25}
                                                className="w-20 h-10 bg-white/5 border border-white/10 rounded-lg px-3 text-center text-white"
                                            />
                                        </div>
                                        <div className="flex items-center justify-between py-3">
                                            <div>
                                                <p className="font-medium text-white">Dark Mode</p>
                                                <p className="text-xs text-white/50">Admin panel teması</p>
                                            </div>
                                            <button
                                                onClick={() => setDarkMode(!darkMode)}
                                                className={cn(
                                                    'relative w-14 h-8 rounded-full transition-colors',
                                                    darkMode ? 'bg-primary' : 'bg-white/20'
                                                )}
                                            >
                                                <span className={cn(
                                                    'absolute top-1 w-6 h-6 rounded-full bg-white shadow-lg transition-transform',
                                                    darkMode ? 'left-7' : 'left-1'
                                                )} />
                                            </button>
                                        </div>
                                    </div>
                                </Card>

                                <Card glass>
                                    <h3 className="text-lg font-bold text-white mb-4">Algoritma Parametreleri</h3>
                                    <div className="space-y-4">
                                        <div>
                                            <label className="text-sm font-medium text-white/70 mb-2 block">Eşleşme Ağırlıkları</label>
                                            <div className="grid grid-cols-3 gap-3">
                                                <div className="p-3 bg-white/5 rounded-lg text-center">
                                                    <p className="text-xs text-white/50 mb-1">Konum</p>
                                                    <p className="text-lg font-bold text-primary">35%</p>
                                                </div>
                                                <div className="p-3 bg-white/5 rounded-lg text-center">
                                                    <p className="text-xs text-white/50 mb-1">İlgi Alanları</p>
                                                    <p className="text-lg font-bold text-primary">40%</p>
                                                </div>
                                                <div className="p-3 bg-white/5 rounded-lg text-center">
                                                    <p className="text-xs text-white/50 mb-1">Aktivite</p>
                                                    <p className="text-lg font-bold text-primary">25%</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </Card>

                                <Button
                                    className="w-full h-12"
                                    onClick={handleSave}
                                    disabled={isSaving}
                                >
                                    <span className="material-symbols-outlined mr-2">
                                        {isSaving ? 'sync' : 'save'}
                                    </span>
                                    {isSaving ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet'}
                                </Button>
                            </div>
                        )}

                        {/* Security Settings */}
                        {activeSection === 'security' && (
                            <div className="space-y-6">
                                <Card glass>
                                    <h3 className="text-lg font-bold text-white mb-4">Güvenlik Ayarları</h3>
                                    <div className="space-y-4">
                                        <div className="flex items-center justify-between py-3 border-b border-white/5">
                                            <div>
                                                <p className="font-medium text-white">İki Faktörlü Doğrulama (2FA)</p>
                                                <p className="text-xs text-white/50">Tüm admin hesapları için zorunlu</p>
                                            </div>
                                            <div className="px-3 py-1 bg-emerald-500/20 text-emerald-400 text-xs font-bold rounded-full">
                                                AKTİF
                                            </div>
                                        </div>
                                        <div className="flex items-center justify-between py-3 border-b border-white/5">
                                            <div>
                                                <p className="font-medium text-white">Session Timeout</p>
                                                <p className="text-xs text-white/50">Otomatik çıkış süresi (dakika)</p>
                                            </div>
                                            <input
                                                type="number"
                                                defaultValue={30}
                                                className="w-20 h-10 bg-white/5 border border-white/10 rounded-lg px-3 text-center text-white"
                                            />
                                        </div>
                                        <div className="flex items-center justify-between py-3">
                                            <div>
                                                <p className="font-medium text-white">IP Whitelist</p>
                                                <p className="text-xs text-white/50">Yalnızca belirli IP'lerden erişim</p>
                                            </div>
                                            <Button variant="outline" size="sm">Yapılandır</Button>
                                        </div>
                                    </div>
                                </Card>

                                <Card glass>
                                    <h3 className="text-lg font-bold text-white mb-4">Rate Limiting</h3>
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="p-4 bg-white/5 rounded-xl">
                                            <p className="text-xs text-white/50 mb-1">API İstekleri</p>
                                            <p className="text-xl font-bold text-white">100/dk</p>
                                        </div>
                                        <div className="p-4 bg-white/5 rounded-xl">
                                            <p className="text-xs text-white/50 mb-1">Login Denemeleri</p>
                                            <p className="text-xl font-bold text-white">5/saat</p>
                                        </div>
                                    </div>
                                </Card>
                            </div>
                        )}

                        {/* Admin Management */}
                        {activeSection === 'admins' && (
                            <div className="space-y-6">
                                <div className="flex items-center justify-between">
                                    <h3 className="text-lg font-bold text-white">Yönetici Hesapları</h3>
                                    <Button size="sm">
                                        <span className="material-symbols-outlined text-sm">person_add</span>
                                        Yönetici Ekle
                                    </Button>
                                </div>

                                <div className="space-y-3">
                                    {[
                                        { name: 'Admin User', email: 'admin@dengim.com', role: 'Super Admin', status: 'active' },
                                        { name: 'Moderator', email: 'mod@dengim.com', role: 'Moderator', status: 'active' },
                                        { name: 'Support Agent', email: 'support@dengim.com', role: 'Support', status: 'active' },
                                    ].map((admin, i) => (
                                        <Card key={i} padding="md">
                                            <div className="flex items-center gap-4">
                                                <div className="h-12 w-12 rounded-full bg-primary/20 flex items-center justify-center">
                                                    <span className="text-primary font-bold">{admin.name.substring(0, 2)}</span>
                                                </div>
                                                <div className="flex-1">
                                                    <p className="font-semibold text-white">{admin.name}</p>
                                                    <p className="text-xs text-white/50">{admin.email}</p>
                                                </div>
                                                <div className="text-right">
                                                    <span className={cn(
                                                        'px-2 py-1 text-[10px] font-bold rounded-full',
                                                        admin.role === 'Super Admin'
                                                            ? 'bg-primary/20 text-primary'
                                                            : 'bg-white/10 text-white/70'
                                                    )}>
                                                        {admin.role}
                                                    </span>
                                                </div>
                                                <Button variant="ghost" size="icon">
                                                    <span className="material-symbols-outlined">more_vert</span>
                                                </Button>
                                            </div>
                                        </Card>
                                    ))}
                                </div>
                            </div>
                        )}

                        {/* API Settings */}
                        {activeSection === 'api' && (
                            <div className="space-y-6">
                                <Card glass>
                                    <h3 className="text-lg font-bold text-white mb-4">API Anahtarları</h3>
                                    <div className="space-y-4">
                                        <div className="p-4 bg-white/5 rounded-xl">
                                            <div className="flex items-center justify-between mb-2">
                                                <p className="text-sm font-medium text-white">Production API Key</p>
                                                <Button variant="ghost" size="sm">
                                                    <span className="material-symbols-outlined text-sm">copy</span>
                                                    Kopyala
                                                </Button>
                                            </div>
                                            <code className="text-xs text-white/50 font-mono break-all">
                                                pk_live_••••••••••••••••••••••••••••••••
                                            </code>
                                        </div>
                                        <div className="p-4 bg-white/5 rounded-xl">
                                            <div className="flex items-center justify-between mb-2">
                                                <p className="text-sm font-medium text-white">Test API Key</p>
                                                <Button variant="ghost" size="sm">
                                                    <span className="material-symbols-outlined text-sm">visibility</span>
                                                    Göster
                                                </Button>
                                            </div>
                                            <code className="text-xs text-white/50 font-mono break-all">
                                                pk_test_••••••••••••••••••••••••••••••••
                                            </code>
                                        </div>
                                    </div>
                                    <Button variant="outline" className="w-full mt-4">
                                        <span className="material-symbols-outlined mr-2">refresh</span>
                                        Anahtarları Yenile
                                    </Button>
                                </Card>

                                <Card glass>
                                    <h3 className="text-lg font-bold text-white mb-4">Webhook URL</h3>
                                    <Input
                                        placeholder="https://your-domain.com/webhook"
                                        defaultValue="https://api.dengim.com/webhooks"
                                    />
                                    <Button className="w-full mt-4">Kaydet</Button>
                                </Card>
                            </div>
                        )}

                        {/* Logs */}
                        {activeSection === 'logs' && (
                            <Card glass>
                                <div className="flex items-center justify-between mb-4">
                                    <h3 className="text-lg font-bold text-white">Son Aktiviteler</h3>
                                    <Button variant="outline" size="sm">
                                        <span className="material-symbols-outlined text-sm">download</span>
                                        Dışa Aktar
                                    </Button>
                                </div>
                                <div className="space-y-2">
                                    {[
                                        { action: 'Kullanıcı yasaklandı', admin: 'Admin', time: '2 dk önce', type: 'danger' },
                                        { action: 'Yeni admin eklendi', admin: 'Super Admin', time: '15 dk önce', type: 'info' },
                                        { action: 'Ayarlar güncellendi', admin: 'Admin', time: '1 saat önce', type: 'default' },
                                        { action: 'Rapor çözüldü', admin: 'Moderator', time: '2 saat önce', type: 'success' },
                                    ].map((log, i) => (
                                        <div key={i} className="flex items-center gap-3 p-3 rounded-lg hover:bg-white/5 transition-colors">
                                            <div className={cn(
                                                'h-2 w-2 rounded-full',
                                                log.type === 'danger' ? 'bg-rose-500' :
                                                    log.type === 'success' ? 'bg-emerald-500' :
                                                        log.type === 'info' ? 'bg-blue-500' : 'bg-white/30'
                                            )} />
                                            <p className="flex-1 text-sm text-white">{log.action}</p>
                                            <span className="text-xs text-white/50">{log.admin}</span>
                                            <span className="text-xs text-primary">{log.time}</span>
                                        </div>
                                    ))}
                                </div>
                            </Card>
                        )}
                    </div>
                </main>
                <BottomNav />
            </div>
        </div>
    );
}
