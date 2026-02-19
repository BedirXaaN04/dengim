import {
    collection,
    getDocs,
    getDoc,
    doc,
    updateDoc,
    setDoc,
    query,
    orderBy,
    limit,
    where,
    Timestamp
} from "firebase/firestore";
import { db } from "@/lib/firebase";

// --- Premium Config (system/premium_config) ---
export interface PremiumConfig {
    // Fiyatlar (TRY)
    goldMonthlyPrice: number;
    goldQuarterlyPrice: number;
    goldYearlyPrice: number;
    platinumMonthlyPrice: number;
    platinumQuarterlyPrice: number;
    platinumYearlyPrice: number;

    // Gold Limitleri
    goldDailyLikes: number;
    goldDailySuperLikes: number;
    goldMaxPhotos: number;
    goldRewindsPerDay: number;
    goldCanBoost: boolean;
    goldVoiceMessage: boolean;
    goldReadReceipts: boolean;
    goldAdvancedFilters: boolean;
    goldNoAds: boolean;

    // Platinum Limitleri
    platinumDailyLikes: number;
    platinumDailySuperLikes: number;
    platinumMaxPhotos: number;
    platinumRewindsPerDay: number;
    platinumCanBoost: boolean;
    platinumVoiceMessage: boolean;
    platinumReadReceipts: boolean;
    platinumAdvancedFilters: boolean;
    platinumNoAds: boolean;
    platinumVideoCall: boolean;
    platinumSeeWhoLikedYou: boolean;
    platinumPrioritySupport: boolean;

    // Free Limitleri
    freeDailyLikes: number;
    freeDailySuperLikes: number;
    freeMaxPhotos: number;
    freeRewindsPerDay: number;

    // Kredi Sistemi
    creditEnabled: boolean;
    creditPerAdWatch: number;
    creditDailyLogin: number;
    creditStreakBonus: number;
    creditMaxAdsPerDay: number;
    creditCostSuperLike: number;
    creditCostBoost: number;
    creditCostSeeWhoLiked: number;
    creditCostUndoSwipe: number;

    updatedAt?: Date;
}

const PREMIUM_CONFIG_DOC = "premium_config";
const SYSTEM_COLLECTION = "system";

const defaultConfig: PremiumConfig = {
    goldMonthlyPrice: 149.99,
    goldQuarterlyPrice: 349.99,
    goldYearlyPrice: 999.99,
    platinumMonthlyPrice: 249.99,
    platinumQuarterlyPrice: 599.99,
    platinumYearlyPrice: 1699.99,

    goldDailyLikes: 100,
    goldDailySuperLikes: 5,
    goldMaxPhotos: 9,
    goldRewindsPerDay: 5,
    goldCanBoost: true,
    goldVoiceMessage: true,
    goldReadReceipts: true,
    goldAdvancedFilters: true,
    goldNoAds: true,

    platinumDailyLikes: 999999,
    platinumDailySuperLikes: 10,
    platinumMaxPhotos: 12,
    platinumRewindsPerDay: 999999,
    platinumCanBoost: true,
    platinumVoiceMessage: true,
    platinumReadReceipts: true,
    platinumAdvancedFilters: true,
    platinumNoAds: true,
    platinumVideoCall: true,
    platinumSeeWhoLikedYou: true,
    platinumPrioritySupport: true,

    freeDailyLikes: 25,
    freeDailySuperLikes: 0,
    freeMaxPhotos: 5,
    freeRewindsPerDay: 0,

    creditEnabled: true,
    creditPerAdWatch: 5,
    creditDailyLogin: 3,
    creditStreakBonus: 2,
    creditMaxAdsPerDay: 10,
    creditCostSuperLike: 15,
    creditCostBoost: 50,
    creditCostSeeWhoLiked: 30,
    creditCostUndoSwipe: 5,
};

export const PremiumService = {
    getConfig: async (): Promise<PremiumConfig> => {
        try {
            const docRef = doc(db, SYSTEM_COLLECTION, PREMIUM_CONFIG_DOC);
            const snapshot = await getDoc(docRef);
            if (snapshot.exists()) {
                return { ...defaultConfig, ...snapshot.data() } as PremiumConfig;
            }
            // İlk kez oluştur
            await setDoc(docRef, defaultConfig);
            return defaultConfig;
        } catch (error) {
            console.error("Error fetching premium config:", error);
            return defaultConfig;
        }
    },

    updateConfig: async (config: Partial<PremiumConfig>) => {
        try {
            const docRef = doc(db, SYSTEM_COLLECTION, PREMIUM_CONFIG_DOC);
            await setDoc(docRef, { ...config, updatedAt: new Date() }, { merge: true });
            return true;
        } catch (error) {
            console.error("Error updating premium config:", error);
            throw error;
        }
    },

    // Kullanıcının premium tier bilgisini güncelle (admin upgrade/downgrade)
    updateUserTier: async (userId: string, tier: 'free' | 'gold' | 'platinum', expiryDays?: number) => {
        try {
            const userRef = doc(db, "users", userId);
            const updates: any = {
                subscriptionTier: tier === 'free' ? null : tier,
                isPremium: tier !== 'free',
                updatedAt: new Date()
            };
            if (tier !== 'free' && expiryDays) {
                const expiry = new Date();
                expiry.setDate(expiry.getDate() + expiryDays);
                updates.premiumExpiry = Timestamp.fromDate(expiry);
            }
            await updateDoc(userRef, updates);
            return true;
        } catch (error) {
            console.error("Error updating user tier:", error);
            throw error;
        }
    },

    // Kullanıcının kredi bakiyesini güncelle (admin adjust)
    adjustUserCredits: async (userId: string, amount: number, reason: string) => {
        try {
            const userRef = doc(db, "users", userId);
            const userSnap = await getDoc(userRef);
            const currentCredits = userSnap.data()?.credits || 0;
            const newBalance = Math.max(0, currentCredits + amount);

            await updateDoc(userRef, {
                credits: newBalance,
                updatedAt: new Date()
            });

            // İşlem geçmişine kaydet
            const txRef = doc(collection(db, "users", userId, "credit_transactions"));
            await setDoc(txRef, {
                amount,
                reason: `Admin: ${reason}`,
                type: amount > 0 ? 'earn' : 'spend',
                balance: newBalance,
                createdAt: new Date()
            });

            return true;
        } catch (error) {
            console.error("Error adjusting credits:", error);
            throw error;
        }
    },

    // Premium istatistikler
    getStats: async () => {
        try {
            const usersRef = collection(db, "users");

            const [goldSnap, platinumSnap, totalSnap] = await Promise.all([
                getDocs(query(usersRef, where("subscriptionTier", "==", "gold"))),
                getDocs(query(usersRef, where("subscriptionTier", "==", "platinum"))),
                getDocs(query(usersRef, limit(1000)))
            ]);

            let totalCredits = 0;
            let totalCreditUsers = 0;
            totalSnap.docs.forEach(d => {
                const credits = d.data().credits || 0;
                if (credits > 0) {
                    totalCredits += credits;
                    totalCreditUsers++;
                }
            });

            return {
                goldCount: goldSnap.size,
                platinumCount: platinumSnap.size,
                totalPremium: goldSnap.size + platinumSnap.size,
                totalCreditsInCirculation: totalCredits,
                avgCreditsPerUser: totalCreditUsers > 0 ? Math.round(totalCredits / totalCreditUsers) : 0,
                creditUsers: totalCreditUsers
            };
        } catch (error) {
            console.error("Error fetching premium stats:", error);
            return {
                goldCount: 0, platinumCount: 0, totalPremium: 0,
                totalCreditsInCirculation: 0, avgCreditsPerUser: 0, creditUsers: 0
            };
        }
    }
};
