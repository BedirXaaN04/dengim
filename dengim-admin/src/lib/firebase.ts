import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getMessaging } from "firebase/messaging";

const firebaseConfig = {
    apiKey: "AIzaSyAlCLMEbzY45Ff3Lrj22EspoyNO1O3qFfs",
    authDomain: "dengim-kim.firebaseapp.com",
    projectId: "dengim-kim",
    storageBucket: "dengim-kim.firebasestorage.app",
    messagingSenderId: "12239103870",
    appId: "1:12239103870:web:b0dd97ac27cda36a21f52f", // Web App ID eklendi
};

// Singleton pattern for Firebase App
const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

// Messaging sadece tarayıcı ortamında (web) çalışır
export const messaging = typeof window !== 'undefined' ? getMessaging(app) : null;

// Sizin gönderdiğiniz Web Push Sertifikası (VAPID Key)
export const VAPID_KEY = "BHX6SzRp1uGY9SvV63rwACM8wiuef3LPfV2ykGNB_SQUmKFD91aRwP23kTsoJ9O3xpS1fytE6Im6UVX4cwjdUkw";

export default app;
