import {
    collection,
    getDocs,
    doc,
    updateDoc,
    query,
    orderBy,
    limit,
    where,
    startAfter
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { User } from "@/types";

const USERS_COLLECTION = "users";

export const UserService = {
    // Tüm kullanıcıları getir (Pagination destekli)
    getUsers: async (lastDoc: any = null, pageSize: number = 20) => {
        try {
            let q = query(
                collection(db, USERS_COLLECTION),
                orderBy("createdAt", "desc"),
                limit(pageSize)
            );

            if (lastDoc) {
                q = query(q, startAfter(lastDoc));
            }

            const snapshot = await getDocs(q);
            const users: User[] = [];

            snapshot.forEach((doc) => {
                const data = doc.data();
                const photoList = data.photoUrls || data.photos || (data.profileImageUrl ? [data.profileImageUrl] : []) || [];

                users.push({
                    id: doc.id,
                    name: data.name || data.fullName || 'İsimsiz',
                    email: data.email || '',
                    photos: photoList,
                    status: data.isBanned ? 'banned' : (data.isVerified ? 'verified' : 'active'),
                    lastActive: data.lastActive?.toDate ? data.lastActive.toDate() : new Date(),
                    isPremium: data.isPremium || false,
                    premiumTier: data.premiumTier || undefined,
                    gender: data.gender || 'male',
                    age: data.age || 18,
                    location: data.location || { city: '', country: '' },
                    isVerified: data.isVerified || false,
                    reportCount: data.reportCount || 0,
                    matchCount: data.matchCount || 0,
                    messageCount: data.messageCount || 0,
                    bio: data.bio || '',
                    createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(),
                    updatedAt: data.updatedAt?.toDate ? data.updatedAt.toDate() : new Date(),
                    phone: data.phoneNumber || data.phone || undefined,
                    interests: data.interests || [],
                } as unknown as User);
            });

            return { users, lastDoc: snapshot.docs[snapshot.docs.length - 1] };
        } catch (error) {
            console.error("Fetch Users Error:", error);
            throw error;
        }
    },

    // Onay bekleyen kullanıcıları getir
    getPendingVerifications: async () => {
        try {
            const q = query(
                collection(db, USERS_COLLECTION),
                where("isVerified", "==", false),
                orderBy("createdAt", "desc"),
                limit(50)
            );
            const snapshot = await getDocs(q);
            const users: User[] = [];
            snapshot.forEach((doc) => {
                const data = doc.data();
                const photoList = data.photoUrls || data.photos || [];
                users.push({
                    id: doc.id,
                    name: data.name || 'İsimsiz',
                    photos: photoList,
                    createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(),
                    isVerified: false,
                    status: 'pending'
                } as unknown as User);
            });
            return users;
        } catch (e) {
            console.error("Pending Verifications Error:", e);
            return [];
        }
    },

    // Premium kullanıcıları getir
    getPremiumUsers: async () => {
        try {
            const q = query(
                collection(db, USERS_COLLECTION),
                where("isPremium", "==", true),
                limit(50)
            );
            const snapshot = await getDocs(q);
            const users: User[] = [];
            snapshot.forEach((doc) => {
                const data = doc.data();
                users.push({
                    id: doc.id,
                    name: data.name || 'İsimsiz',
                    premiumTier: data.premiumTier || 'basic',
                    createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(),
                    isPremium: true
                } as unknown as User);
            });
            return users;
        } catch (e) {
            console.error("Premium Users Error:", e);
            return [];
        }
    },

    // Kullanıcı durumunu güncelle
    updateUserStatus: async (userId: string, action: 'ban' | 'verify' | 'suspend') => {
        try {
            const userRef = doc(db, USERS_COLLECTION, userId);
            const updates: any = {};
            if (action === 'ban') { updates.isBanned = true; updates.status = 'banned'; }
            else if (action === 'verify') { updates.isVerified = true; updates.status = 'verified'; }
            else if (action === 'suspend') { updates.isBanned = true; updates.status = 'suspended'; }
            await updateDoc(userRef, updates);
            return true;
        } catch (e) {
            console.error("Update User Error:", e);
            throw e;
        }
    }
};
