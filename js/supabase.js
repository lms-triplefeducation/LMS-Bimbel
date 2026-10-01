import {CONFIG} from './config.js';
let client;
export async function supabase(){
 if(client)return client;
 if(!CONFIG.SUPABASE_URL.startsWith('http')||CONFIG.SUPABASE_ANON_KEY.includes('PASTE_')) return null;
 const {createClient}=await import('https://esm.sh/@supabase/supabase-js@2');
 client=createClient(CONFIG.SUPABASE_URL,CONFIG.SUPABASE_ANON_KEY,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}});
 return client;
}
export async function db(table){const s=await supabase();if(!s)throw Error('Supabase belum dikonfigurasi.');return s.from(table)}
export async function currentAuth(){const s=await supabase();if(!s)return null;const {data}=await s.auth.getUser();return data.user||null}
