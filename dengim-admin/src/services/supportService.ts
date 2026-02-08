import {
    collection,
    getDocs,
    doc,
    getDoc,
    query,
    where,
    orderBy,
    limit,
    getCountFromServer,
    updateDoc,
    Timestamp
} from "firebase/firestore";
import { db } from "@/lib/firebase";

export interface TicketMessage {
    id: string;
    senderId: string;
    senderName: string;
    senderType: 'admin' | 'user';
    content: string;
    createdAt: any;
}

export interface SupportTicket {
    id: string;
    userId: string;
    userName: string;
    userEmail: string;
    subject: string;
    category: string;
    status: 'open' | 'in_progress' | 'resolved' | 'closed';
    messages: TicketMessage[];
    createdAt: any;
    updatedAt: any;
}

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
    },

    // Bilet detaylarını getir
    getTicketById: async (id: string): Promise<SupportTicket | null> => {
        try {
            const docSnap = await getDoc(doc(db, "support_tickets", id));
            if (docSnap.exists()) {
                return { id: docSnap.id, ...docSnap.data() } as SupportTicket;
            }
            return null;
        } catch (error) {
            console.error("Get ticket error:", error);
            return null;
        }
    },

    // Mesaj ekle (Yanıtla)
    addMessage: async (ticketId: string, message: Omit<TicketMessage, 'id' | 'createdAt'>) => {
        try {
            const ticketRef = doc(db, "support_tickets", ticketId);
            const ticketDoc = await getDoc(ticketRef);
            if (!ticketDoc.exists()) return false;

            const data = ticketDoc.data();
            const messages = data.messages || [];
            messages.push({
                ...message,
                id: Math.random().toString(36).substring(7),
                createdAt: Timestamp.now()
            });

            await updateDoc(ticketRef, {
                messages,
                updatedAt: Timestamp.now(),
                status: message.senderType === 'admin' ? 'in_progress' : 'open'
            });
            return true;
        } catch (error) {
            console.error("Add message error:", error);
            return false;
        }
    },

    // Bilet durumunu güncelle
    updateStatus: async (id: string, status: string) => {
        try {
            await updateDoc(doc(db, "support_tickets", id), {
                status,
                updatedAt: Timestamp.now()
            });
            return true;
        } catch (error) {
            console.error("Update status error:", error);
            return false;
        }
    }
};
