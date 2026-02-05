'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import {
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
    sendPasswordResetEmail,
    GoogleAuthProvider,
    signInWithPopup
} from 'firebase/auth';
import { auth } from '@/lib/firebase';
import { useAdminStore } from '@/store/adminStore';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';

export default function LoginPage() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [resetSent, setResetSent] = useState(false);
    const [error, setError] = useState('');
    const router = useRouter();
    const { setCurrentAdmin } = useAdminStore();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        // 🚨 Master Admin Bypass (Geçici)
        if (email === 'omerbedirhano@gmail.com' && password === 'admin123') {
            setCurrentAdmin({
                id: 'master-admin',
                name: 'Ömer Bedirhan',
                email: email,
                role: 'super_admin',
            });
            router.push('/');
            return;
        }

        try {
            const userCredential = await signInWithEmailAndPassword(auth, email, password);
            setCurrentAdmin({
                id: userCredential.user.uid,
                name: userCredential.user.displayName || email.split('@')[0],
                email: userCredential.user.email || '',
                role: 'super_admin',
            });
            router.push('/');
        } catch (err: any) {
            console.error("Login Error:", err.code);
            if (err.code === 'auth/user-not-found') {
                await tryCreateAccount();
            }
            else if (err.code === 'auth/wrong-password') {
                setError('Şifre hatalı. Lütfen kontrol edin.');
            }
            else if (err.code === 'auth/invalid-credential' || err.code === 'auth/invalid-login-credentials') {
                await tryCreateAccount();
            } else {
                setError('Giriş yapılırken bir hata oluştu: ' + err.message);
            }
        } finally {
            setLoading(false);
        }
    };

    const handleGoogleLogin = async () => {
        setLoading(true);
        setError('');
        const provider = new GoogleAuthProvider();
        try {
            const result = await signInWithPopup(auth, provider);
            // Sadece belirli maillere admin yetkisi ver (Güvenlik için)
            if (result.user.email === 'omerbedirhano@gmail.com') {
                setCurrentAdmin({
                    id: result.user.uid,
                    name: result.user.displayName || 'Admin',
                    email: result.user.email || '',
                    role: 'super_admin',
                });
                router.push('/');
            } else {
                setError('Bu Google hesabı admin yetkisine sahip değil.');
            }
        } catch (err: any) {
            console.error("Google Login Error:", err);
            if (err.code === 'auth/popup-closed-by-user') {
                setError('Giriş penceresi kapatıldı.');
            } else if (err.code === 'auth/operation-not-allowed') {
                setError('Google ile giriş Firebase konsolunda aktif değil.');
            } else {
                setError('Google ile giriş hatası: ' + err.message);
            }
        } finally {
            setLoading(false);
        }
    };

    const tryCreateAccount = async () => {
        if (email === 'omerbedirhano@gmail.com') {
            try {
                const newUser = await createUserWithEmailAndPassword(auth, email, password);
                setCurrentAdmin({
                    id: newUser.user.uid,
                    name: 'Ömer Bedirhan',
                    email: newUser.user.email || '',
                    role: 'super_admin',
                });
                router.push('/');
            } catch (createErr: any) {
                if (createErr.code === 'auth/email-already-in-use') {
                    setError('Bu e-posta kayıtlı ancak şifre yanlış. Lütfen "admin123" ile deneyin.');
                } else {
                    setError('Hesap oluşturulamadı: ' + createErr.message);
                }
            }
        } else {
            setError('E-posta veya şifre hatalı.');
        }
    };

    const handleForgotPassword = async () => {
        if (!email) {
            setError('Lütfen e-posta adresinizi girin.');
            return;
        }
        try {
            await sendPasswordResetEmail(auth, email);
            setResetSent(true);
            setError('');
        } catch (err: any) {
            setError('Sıfırlama e-postası gönderilemedi: ' + err.message);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-background-dark p-4">
            <div className="w-full max-w-md space-y-8 glass p-8 rounded-2xl border border-primary/20">
                <div className="text-center">
                    <h1 className="text-3xl font-bold text-primary mb-2">DENGIM</h1>
                    <p className="text-white/60 text-sm">Admin Paneli Girişi</p>
                </div>

                <div className="space-y-4">
                    <form onSubmit={handleLogin} className="space-y-6">
                        <Input
                            label="E-posta"
                            type="email"
                            placeholder="admin@dengim.com"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                            className="bg-background-dark border-white/10"
                        />

                        <div>
                            <Input
                                label="Şifre"
                                type="password"
                                placeholder="••••••••"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                required
                                className="bg-background-dark border-white/10"
                            />
                            <div className="flex justify-end mt-1">
                                <button
                                    type="button"
                                    onClick={handleForgotPassword}
                                    className="text-xs text-primary hover:text-primary/80 transition-colors"
                                >
                                    Şifremi Unuttum
                                </button>
                            </div>
                        </div>

                        <Button type="submit" className="w-full h-12 text-base" loading={loading}>
                            Giriş Yap
                        </Button>
                    </form>

                    <div className="relative">
                        <div className="absolute inset-0 flex items-center">
                            <div className="w-full border-t border-white/10"></div>
                        </div>
                        <div className="relative flex justify-center text-xs uppercase">
                            <span className="bg-background-dark px-2 text-white/30 italic">ya da</span>
                        </div>
                    </div>

                    <button
                        onClick={handleGoogleLogin}
                        disabled={loading}
                        className="w-full h-12 flex items-center justify-center gap-3 bg-white text-black font-semibold rounded-xl hover:bg-white/90 transition-all disabled:opacity-50"
                    >
                        <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" className="w-5 h-5" />
                        Google ile Devam Et
                    </button>
                </div>

                {error && (
                    <div className="p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-rose-500 text-sm font-medium text-center">
                        {error}
                    </div>
                )}

                {resetSent && (
                    <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-sm font-medium text-center">
                        Şifre sıfırlama bağlantısı e-posta adresinize gönderildi!
                    </div>
                )}

                <p className="text-center text-[10px] text-white/20 mt-6">
                    Bu alan sadece yetkili personel içindir. IP Adresiniz kaydedilmektedir.
                </p>
            </div>
        </div>
    );
}
