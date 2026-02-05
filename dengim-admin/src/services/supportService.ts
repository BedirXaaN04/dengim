import {
    collection,
    getDocs,
    query,
    where,
    orderBy,
    limit,
    getCountFromServer
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { SupportTicket } from "@/types";

export const SupportService = {
    // Açık destek taleplerini getir
    getTickets: async (status: string = 'open') => {
        try {
            const q = query(
                collection(db, "support_tickets"),
                where("status", "==", status),
                orderBy("createdAt", "desc"),
                limit(50)
            );
            const snapshot = await getDocs(q);
            return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        } catch (error) {
            console.error("Fetch tickets error:", error);
            return [];
        }
    },

    // Bekleyen talep sayısını getir
    getPendingCount: async () => {
        try {
            const q = query(collection(db, "support_tickets"), where("status", "==", "open"));
            const snapshot = await getCountFromServer(q);
            return snapshot.data().count;
        } catch (e) {
            return 0;
        }
    }
};
