import { NextResponse } from 'next/server';
import admin from 'firebase-admin';
import path from 'path';
import fs from 'fs';

// Initialize Firebase Admin only once
if (!admin.apps.length) {
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log('Firebase Admin Initialized via ENV');
    } else {
      // Fallback to local file for dev
      const serviceAccountPath = path.resolve(process.cwd(), 'serviceAccountKey.json');
      if (fs.existsSync(serviceAccountPath)) {
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        console.log('Firebase Admin Initialized via JSON File');
      } else {
        console.warn('Firebase Admin failed to initialize: No credentials found!');
      }
    }
  } catch (error) {
    console.error('Firebase admin initialization error:', error);
  }
}

// POST endpoint
export async function POST(req: Request) {
  // Add CORS headers for cross-origin requests from Flutter
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'OPTIONS, POST',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  try {
    const body = await req.json();
    const { token, title, body: msgBody, data } = body;

    if (!token) {
      return NextResponse.json({ error: 'FCM Token missing' }, { status: 400, headers: corsHeaders });
    }

    const payload = {
      notification: {
        title: title || 'Dengim',
        body: msgBody || 'Yeni bir bildiriminiz var',
      },
      data: data || {},
      token: token,
      android: {
         notification: { sound: "default" }
      },
      apns: {
         payload: {
             aps: { sound: "default", badge: 1 }
         }
      }
    };

    const response = await admin.messaging().send(payload);
    return NextResponse.json({ success: true, response }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Push notification error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500, headers: corsHeaders });
  }
}

// Handle OPTIONS request for CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS, POST',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}
