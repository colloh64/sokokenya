// Initializes Supabase client for browser use. This file is an ES module.
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

const cfg = window.SUPABASE_CONFIG || {};
if (!cfg.url || !cfg.anonKey) {
  console.warn('Supabase config not set. Fill supabase/config.js with your URL and anon key.');
}

export const supabase = createClient(cfg.url || '', cfg.anonKey || '');
