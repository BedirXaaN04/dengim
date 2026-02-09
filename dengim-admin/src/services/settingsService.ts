import { doc, getDoc, setDoc, updateDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";

const SETTINGS_COLLECTION = "settings";
const MODERATION_DOC = "moderation";

export interface ModerationSettings {
    profanityFilter: boolean;
    aiPhotoCheck: boolean;
    autoShadowBan: boolean;
    reportThreshold: number;
}

export const SettingsService = {
    getModerationSettings: async (): Promise<ModerationSettings> => {
        try {
            const docRef = doc(db, SETTINGS_COLLECTION, MODERATION_DOC);
            const snapshot = await getDoc(docRef);

            if (snapshot.exists()) {
                return snapshot.data() as ModerationSettings;
            }

            // Default settings
            const defaults: ModerationSettings = {
                profanityFilter: true,
                aiPhotoCheck: false,
                autoShadowBan: true,
                reportThreshold: 5
            };

            await setDoc(docRef, defaults);
            return defaults;
        } catch (error) {
            console.error("Error fetching moderation settings:", error);
            throw error;
        }
    },

    updateModerationSettings: async (settings: Partial<ModerationSettings>) => {
        try {
            const docRef = doc(db, SETTINGS_COLLECTION, MODERATION_DOC);
            await updateDoc(docRef, {
                ...settings,
                updatedAt: new Date()
            });
            return true;
        } catch (error) {
            console.error("Error updating moderation settings:", error);
            throw error;
        }
    }
};
