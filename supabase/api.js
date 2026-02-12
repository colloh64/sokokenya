// Simple wrapper functions for common Supabase operations.
// Usage (in a module script):
// <script src="/supabase/config.js"></script>
// <script type="module">
//   import { supabase } from '/supabase/client.js';
//   import { createSeller, getProducts } from '/supabase/api.js';
// </script>

import { supabase } from './client.js';

export async function createSeller(seller) {
  const { data, error } = await supabase
    .from('sellers')
    .insert([seller])
    .select();
  return { data, error };
}

export async function getSellerByEmail(email) {
  const { data, error } = await supabase
    .from('sellers')
    .select('*')
    .eq('email', email)
    .limit(1)
    .single();
  return { data, error };
}

export async function createProduct(product) {
  const { data, error } = await supabase
    .from('products')
    .insert([product])
    .select();
  return { data, error };
}

export async function getProducts(filter = {}) {
  let query = supabase.from('products').select('*');
  if (filter.sellerId) query = query.eq('seller_id', filter.sellerId);
  if (filter.county) query = query.eq('county', filter.county);
  const { data, error } = await query;
  return { data, error };
}

export async function signIn(email, password) {
  // Example: using RLS and auth would require Supabase Auth; here we show a basic example
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  return { data, error };
}

export async function signUp(email, password) {
  const { data, error } = await supabase.auth.signUp({ email, password });
  return { data, error };
}

export async function uploadImage(bucket, file, fileName) {
  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(fileName, file, { cacheControl: '3600', upsert: false });
  return { data, error };
}

export async function getPublicUrl(bucket, path) {
  const { data, error } = supabase.storage.from(bucket).getPublicUrl(path);
  return { data, error };
}

// ==========================================
// REALTIME SUBSCRIPTIONS
// ==========================================
// Subscribe to all changes on a table. Optional `filter` uses Postgres filter syntax
// Example: subscribeToTable('products', cb, 'seller_id=eq.123')
export function subscribeToTable(table, onEvent, filter = '') {
  const channelName = `realtime-${table}`;
  const sub = supabase
    .channel(channelName)
    .on('postgres_changes', { event: '*', schema: 'public', table, filter }, payload => {
      try { onEvent(payload); } catch (e) { console.error(e); }
    })
    .subscribe();

  return sub;
}

// Unsubscribe and remove channel
export async function unsubscribeChannel(channel) {
  try {
    // supabase.removeChannel works in newer clients; fallback to unsubscribe method
    if (typeof supabase.removeChannel === 'function') {
      await supabase.removeChannel(channel);
    } else if (channel?.unsubscribe) {
      channel.unsubscribe();
    }
  } catch (err) {
    console.warn('Failed to unsubscribe channel', err);
  }
}

// Convenience: subscribe to changes only for a specific seller's products
export function subscribeToSellerProducts(sellerId, onEvent) {
  const filter = `seller_id=eq.${sellerId}`;
  return subscribeToTable('products', onEvent, filter);
}
