import {
    collection,
    getDocs,
    doc,
    setDoc,
    updateDoc,
    deleteDoc,
    query,
    orderBy,
    Timestamp
} from "firebase/firestore";
import { db } from "@/lib/firebase";

export interface AdminUser {
    id?: string;
    email: string;
    name: string;
    role: 'super_admin' | 'admin' | 'moderator' | 'support';
    status: 'active' | 'inactive';
    createdAt: any;
    lastLogin?: any;
}

export const adminService = {
    // Admin listesini getir
    getAdmins: async (): Promise<AdminUser[]> => {
        try {
            const q = query(collection(db, "admins"), orderBy("createdAt", "desc"));
            const snapshot = await getDocs(q);
            return snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            } as AdminUser));
        } catch (error) {
            console.error("Fetch admins error:", error);
            return [];
        }
    },

    // Yeni admin ekle
    addAdmin: async (admin: Omit<AdminUser, 'id' | 'createdAt'>) => {
        try {
            const adminDoc = doc(db, 'admins', admin.email);
            await setDoc(adminDoc, {
                ...admin,
                createdAt: Timestamp.now(),
                status: 'active'
            });
            return true;
        } catch (error) {
            console.error("Add admin error:", error);
            return false;
        }
    },

    // Admin durumunu güncelle
    updateAdminStatus: async (email: string, status: 'active' | 'inactive') => {
        try {
            const adminDoc = doc(db, 'admins', email);
            await updateDoc(adminDoc, { status });
            return true;
        } catch (error) {
            console.error("Update admin status error:", error);
            return false;
        }
    },

    // Admin sil
    deleteAdmin: async (email: string) => {
        try {
            await deleteDoc(doc(db, 'admins', email));
            return true;
        } catch (error) {
            console.error("Delete admin error:", error);
            return false;
        }
    }
};
