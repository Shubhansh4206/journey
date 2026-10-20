import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://gwisnrgiuunhfcjernar.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3aXNucmdpdXVuaGZjamVybmFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0MDkwNjcsImV4cCI6MjEwNTk4NTA2N30.sg5Oau_pet5rBNrpgiVu7NSjyvc-K-m-zbnTN8gYooQ';

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});

export const isSupabaseConfigured = () => {
  return Boolean(supabaseUrl && supabaseAnonKey && !supabaseUrl.includes('placeholder'));
};
