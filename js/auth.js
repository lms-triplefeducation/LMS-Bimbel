import {supabase,currentAuth} from './supabase.js';
export async function signIn(email,password){const s=await supabase();if(!s)return{ok:false,message:'Isi js/config.js terlebih dahulu.'};const {data,error}=await s.auth.signInWithPassword({email,password});if(error)return{ok:false,message:error.message};return{ok:true,user:data.user}}
export async function signOut(){const s=await supabase();if(s)await s.auth.signOut();localStorage.removeItem('tfe_demo');location.href='login.html'}
export async function getProfile(){const s=await supabase();if(!s)return null;const u=await currentAuth();if(!u)return null;const {data,error}=await s.from('profiles').select('*').eq('auth_user_id',u.id).maybeSingle();if(error)throw error;return data}
export function demoLogin(role='admin'){localStorage.setItem('tfe_demo',JSON.stringify({role,full_name:role==='admin'?'Administrator Demo':role==='teacher'?'Guru Demo':'Siswa Demo',email:'demo@triplef.local'}))}
export async function getCurrentUser(){const d=localStorage.getItem('tfe_demo');if(d)return JSON.parse(d);const p=await getProfile();return p}
