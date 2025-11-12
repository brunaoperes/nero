import dotenv from 'dotenv';

dotenv.config();

export const pluggyConfig = {
  clientId: process.env.PLUGGY_CLIENT_ID || '',
  clientSecret: process.env.PLUGGY_CLIENT_SECRET || '',
  baseUrl: process.env.PLUGGY_BASE_URL || 'https://api.pluggy.ai',
  apiVersion: 'v1',
};

if (!pluggyConfig.clientId || !pluggyConfig.clientSecret) {
  console.warn('⚠️  Pluggy credentials not configured. Open Finance features will be disabled.');
}
