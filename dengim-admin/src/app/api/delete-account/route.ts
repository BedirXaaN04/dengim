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
    } else {
      const serviceAccountPath = path.resolve(process.cwd(), 'serviceAccountKey.json');
      if (fs.existsSync(serviceAccountPath)) {
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
      }
    }
  } catch (error) {
    console.error('Firebase admin initialization error:', error);
  }
}

export async function POST(req: Request) {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'OPTIONS, POST',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  try {
    const body = await req.json();
    const { userId } = body;

    if (!userId) {
      return NextResponse.json({ error: 'User ID missing' }, { status: 400, headers: corsHeaders });
    }

    const db = admin.firestore();
    const batch = db.batch();
    let ops = 0;

    console.log(`Starting cascade cleanup for user ${userId}`);

    // 1. Delete conversations where userIds contains userId
    const conversations = await db.collection('conversations').where('userIds', 'array-contains', userId).get();
    conversations.docs.forEach((doc) => {
        batch.delete(doc.ref);
        ops++;
    });

    // 2. Delete matches
    const matches = await db.collection('matches').where('userIds', 'array-contains', userId).get();
    matches.docs.forEach((doc) => {
        batch.delete(doc.ref);
        ops++;
    });
    
    // 3. Delete the user profile document
    const userDocRef = db.collection('users').doc(userId);
    batch.delete(userDocRef);
    ops++;

    // Execute batch
    if (ops > 0) {
        await batch.commit();
    }

    // 4. Delete the user strictly from Firebase Auth (Admin SDK bypasses client restrictions)
    try {
      await admin.auth().deleteUser(userId);
      console.log(`Successfully deleted user ${userId} from Firebase Auth.`);
    } catch (authError: any) {
      console.warn(`Auth delete warning: ${authError.message}`);
    }

    return NextResponse.json({ success: true, deletedItems: ops }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Delete account error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500, headers: corsHeaders });
  }
}

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
