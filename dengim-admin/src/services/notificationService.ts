import {
    collection,
    getCountFromServer,
    query,
    where,
    Timestamp,
    addDoc,
    orderBy,
    limit,
    getDocs
} from "firebase/firestore";
import { db } from "@/lib/firebase";

export const NotificationService = {
    // Bildirim Segment Sayılarını Hesapla
    getSegmentCounts: async () => {
        try {
            const usersColl = collection(db, "users");
            const sevenDaysAgo = new Date();
            sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
            const sevenDaysAgoTimestamp = Timestamp.fromDate(sevenDaysAgo);

            const [all, premium, newUsers, inactive] = await Promise.all([
                getCountFromServer(usersColl),
                getCountFromServer(query(usersColl, where("isPremium", "==", true))),
                getCountFromServer(query(usersColl, where("createdAt", ">=", sevenDaysAgoTimestamp))),
                getCountFromServer(query(usersColl, where("lastActive", "<", sevenDaysAgoTimestamp)))
            ]);

            return {
                all: all.data().count,
                premium: premium.data().count,
                new: newUsers.data().count,
                inactive: inactive.data().count
            };
        } catch (error) {
            console.error("Segment counts error:", error);
            return { all: 0, premium: 0, new: 0, inactive: 0 };
        }
    },

    // Yeni Bildirim Gönder (Kuyruğa Ekle)
    sendPushNotification: async (data: {
        title: string;
        body: string;
        segment: string;
        imageUrl?: string;
    }) => {
        try {
            await addDoc(collection(db, "notification_queue"), {
                ...data,
                status: 'pending',
                createdAt: Timestamp.now(),
                sentCount: 0
            });
            return true;
        } catch (error) {
            console.error("Send notification error:", error);
            return false;
        }
    },

    // Bildirim Geçmişini Getir
    getHistory: async () => {
        try {
            const q = query(
                collection(db, "notification_queue"),
                orderBy("createdAt", "desc"),
                limit(20)
            );
            const snapshot = await getDocs(q);
            return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        } catch (error) {
            console.error("Get history error:", error);
            return [];
        }
    }
};
