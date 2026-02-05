'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { onAuthStateChanged } from 'firebase/auth';
import { auth } from '@/lib/firebase';
import { useAdminStore } from '@/store/adminStore';

export function AuthProvider({ children }: { children: React.ReactNode }) {
    const router = useRouter();
    const pathname = usePathname();
    const { setCurrentAdmin, currentAdmin } = useAdminStore();
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (user) => {
            // 🚨 Bypass Kontrolü: Eğer store'da master admin varsa, Firebase'in "yok" demesini yoksay
            // getState() kullanarak en güncel state'i alıyoruz (closure sorununu önlemek için)
            const currentState = useAdminStore.getState().currentAdmin;

            if (currentState?.id === 'master-admin') {
                setLoading(false);
                // Eğer login sayfasındaysak yönlendir
                if (pathname === '/login') {
                    router.push('/');
                }
                return;
            }

            if (user) {
                // Kullanıcı giriş yapmış (Firebase)
                if (!currentAdmin) {
                    setCurrentAdmin({
                        id: user.uid,
                        name: user.displayName || user.email?.split('@')[0] || 'Admin',
                        email: user.email || '',
                        role: 'super_admin',
                    });
                }

                if (pathname === '/login') {
                    router.push('/');
                }
            } else {
                // Kullanıcı çıkış yapmış veya giriş yok
                // Eğer zaten master-admin olarak içerideysek dokunma (Bu blok gereksiz olabilir ama garanti olsun)
                if (currentState?.id !== 'master-admin') {
                    setCurrentAdmin(null);
                    if (pathname !== '/login') {
                        router.push('/login');
                    }
                }
            }
            setLoading(false);
        });

        return () => unsubscribe();
    }, [router, pathname, currentAdmin, setCurrentAdmin]);

    if (loading) {
        return (
            <div className="flex min-h-screen items-center justify-center bg-background-dark">
                <div className="flex flex-col items-center gap-4">
                    <div className="h-12 w-12 rounded-full border-4 border-primary border-t-transparent animate-spin" />
                    <p className="text-white/50 text-sm">Yükleniyor...</p>
                </div>
            </div>
        );
    }

    return <>{children}</>;
}
