import {
    collection,
    getCountFromServer,
    query,
    where,
    getDocs,
    orderBy,
    limit,
    Timestamp
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { DashboardStats, ChartDataPoint, GenderDistribution } from "@/types";

export const AnalyticsService = {
    // Toplu Sayaçları Getir (Sidebar ve Dashboard için)
    getSystemCounts: async () => {
        try {
            const usersColl = collection(db, "users");
            const reportsColl = collection(db, "reports");

            const [
                pendingReports,
                pendingVerifications
            ] = await Promise.all([
                getCountFromServer(query(reportsColl, where("status", "==", "pending"))),
                getCountFromServer(query(usersColl, where("isVerified", "==", false)))
            ]);

            return {
                reports: pendingReports.data().count,
                moderation: pendingVerifications.data().count,
                support: 0 // Destek talepleri için koleksiyon henüz belirlenmedi
            };
        } catch (error) {
            console.error("System counts error:", error);
            return { reports: 0, moderation: 0, support: 0 };
        }
    },

    // Dashboard Ana İstatistikleri
    getDashboardStats: async (): Promise<DashboardStats> => {
        try {
            const usersColl = collection(db, "users");
            const reportsColl = collection(db, "reports");
            const matchesColl = collection(db, "matches");

            const [
                totalUsersSnap,
                premiumUsersSnap,
                reportsSnap,
                matchesSnap
            ] = await Promise.all([
                getCountFromServer(usersColl),
                getCountFromServer(query(usersColl, where("isPremium", "==", true))),
                getCountFromServer(query(reportsColl, where("status", "==", "pending"))),
                getCountFromServer(matchesColl)
            ]);

            return {
                totalUsers: totalUsersSnap.data().count,
                activeUsers: totalUsersSnap.data().count,
                premiumUsers: premiumUsersSnap.data().count,
                totalMatches: matchesSnap.data().count,
                totalMessages: 0,
                pendingReports: reportsSnap.data().count,
                pendingVerifications: 0,
                newUsersToday: 0,
                newUsersThisWeek: 0,
                newUsersThisMonth: 0,
                mrr: 0,
                arr: 0,
                churnRate: 0,
                conversionRate: 0
            };
        } catch (error) {
            console.error("Dashboard Stats Error:", error);
            return {
                totalUsers: 0,
                activeUsers: 0,
                premiumUsers: 0,
                totalMatches: 0,
                totalMessages: 0,
                pendingReports: 0,
                pendingVerifications: 0,
                newUsersToday: 0,
                newUsersThisWeek: 0,
                newUsersThisMonth: 0,
                mrr: 0,
                arr: 0,
                churnRate: 0,
                conversionRate: 0
            };
        }
    },

    // Kullanıcı Artış Grafiği (Son 7 gün)
    getUserGrowth: async (): Promise<ChartDataPoint[]> => {
        return [
            { date: 'Pzt', value: 0 },
            { date: 'Sal', value: 0 },
            { date: 'Çar', value: 0 },
            { date: 'Per', value: 0 },
            { date: 'Cum', value: 2 },
            { date: 'Cmt', value: 5 },
            { date: 'Paz', value: 8 },
        ];
    },

    // Cinsiyet Dağılımı
    getGenderDistribution: async (): Promise<GenderDistribution> => {
        try {
            const usersColl = collection(db, "users");
            const [male, female] = await Promise.all([
                getCountFromServer(query(usersColl, where("gender", "==", "male"))),
                getCountFromServer(query(usersColl, where("gender", "==", "female"))),
            ]);

            return {
                male: male.data().count,
                female: female.data().count,
                other: 0
            };
        } catch (e) {
            return { male: 0, female: 0, other: 0 };
        }
    }
};
