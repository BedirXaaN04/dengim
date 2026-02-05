import {
    collection,
    getDocs,
    doc,
    updateDoc,
    query,
    orderBy,
    limit,
    where
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Report } from "@/types";

const REPORTS_COLLECTION = "reports";

export const ReportService = {
    // Raporları getir
    getReports: async (status: string = 'all', limitCount: number = 20) => {
        try {
            let q = query(
                collection(db, REPORTS_COLLECTION),
                orderBy("createdAt", "desc"),
                limit(limitCount)
            );

            if (status !== 'all') {
                q = query(q, where("status", "==", status));
            }

            const snapshot = await getDocs(q);
            const reports: Report[] = [];

            snapshot.forEach((doc) => {
                const data = doc.data();
                reports.push({
                    id: doc.id,
                    ...data,
                    createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(),
                    updatedAt: data.updatedAt?.toDate ? data.updatedAt.toDate() : new Date(),
                } as unknown as Report);
            });

            return reports;
        } catch (error) {
            console.error("Error fetching reports:", error);
            return [];
        }
    },

    // Rapor durumunu güncelle
    updateReportStatus: async (reportId: string, status: Report['status'], resolution?: string) => {
        try {
            const reportRef = doc(db, REPORTS_COLLECTION, reportId);
            await updateDoc(reportRef, {
                status,
                resolution,
                resolvedAt: new Date(),
                updatedAt: new Date()
            });
            return true;
        } catch (error) {
            console.error("Error updating report:", error);
            throw error;
        }
    }
};
