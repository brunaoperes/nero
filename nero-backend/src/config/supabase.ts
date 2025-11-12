import { createClient } from '@supabase/supabase-js';
import { config } from './env';

// Cliente Supabase com Service Key (acesso total)
export const supabaseAdmin = createClient(
  config.supabase.url,
  config.supabase.serviceKey,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
);

// Cliente Supabase com Anon Key (acesso limitado)
export const supabase = createClient(
  config.supabase.url,
  config.supabase.anonKey
);

export default supabaseAdmin;
