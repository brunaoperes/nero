import admin from 'firebase-admin';
import * as path from 'path';
import * as fs from 'fs';

/**
 * Inicializa Firebase Admin SDK
 */
export function initializeFirebase() {
  try {
    // Se já foi inicializado, retorna
    if (admin.apps.length > 0) {
      console.log('✓ Firebase Admin SDK já inicializado');
      return admin.app();
    }

    // Opção 1: Usar arquivo JSON (desenvolvimento)
    const serviceAccountPath = path.join(__dirname, '../../firebase-service-account.json');

    if (fs.existsSync(serviceAccountPath)) {
      const serviceAccount = require(serviceAccountPath);

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: serviceAccount.project_id,
      });

      console.log('✓ Firebase Admin SDK initialized from JSON file');
      console.log(`✓ Project ID: ${serviceAccount.project_id}`);

      return admin.app();
    }

    // Opção 2: Usar variáveis de ambiente (produção)
    const {
      FIREBASE_PROJECT_ID,
      FIREBASE_PRIVATE_KEY,
      FIREBASE_CLIENT_EMAIL,
    } = process.env;

    if (FIREBASE_PROJECT_ID && FIREBASE_PRIVATE_KEY && FIREBASE_CLIENT_EMAIL) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: FIREBASE_PROJECT_ID,
          privateKey: FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
          clientEmail: FIREBASE_CLIENT_EMAIL,
        }),
        projectId: FIREBASE_PROJECT_ID,
      });

      console.log('✓ Firebase Admin SDK initialized from environment variables');
      console.log(`✓ Project ID: ${FIREBASE_PROJECT_ID}`);

      return admin.app();
    }

    throw new Error(
      'Firebase credentials not found. ' +
      'Please provide firebase-service-account.json or set environment variables.'
    );
  } catch (error) {
    console.error('❌ Error initializing Firebase Admin SDK:', error);
    throw error;
  }
}

// Inicializar automaticamente
const firebaseApp = initializeFirebase();

export default firebaseApp;
export const messaging = admin.messaging();
