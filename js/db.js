import {supabase} from './supabase.js';
export async function list(table,{select='*',filters=[],order='created_at',ascending=false,limit=200}={}){const s=await supabase();if(!s)throw Error('Supabase belum dikonfigurasi.');let q=s.from(table).select(select).order(order,{ascending});for(const f of filters)q=q[f.op](f.col,f.val);if(limit)q=q.limit(limit);const {data,error}=await q;if(error)throw error;return data||[]}
export async function one(table,id,select='*'){const s=await supabase();const {data,error}=await s.from(table).select(select).eq('id',id).single();if(error)throw error;return data}
export async function insert(table,row){const s=await supabase();const {data,error}=await s.from(table).insert(row).select().single();if(error)throw error;return data}
export async function update(table,id,row){const s=await supabase();const {data,error}=await s.from(table).update(row).eq('id',id).select().single();if(error)throw error;return data}
export async function remove(table,id){const s=await supabase();const {error}=await s.from(table).delete().eq('id',id);if(error)throw error}
export async function count(table){const s=await supabase();const {count,error}=await s.from(table).select('*',{count:'exact',head:true});if(error)throw error;return count||0}
