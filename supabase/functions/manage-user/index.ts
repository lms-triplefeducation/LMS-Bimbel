import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
Deno.serve(async req=>{
 if(req.method==='OPTIONS') return new Response('ok',{headers:cors});
 try{
  const url=Deno.env.get('SUPABASE_URL')!, service=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin=createClient(url,service);
  const token=(req.headers.get('Authorization')||'').replace('Bearer ','');
  const {data:{user},error:ue}=await admin.auth.getUser(token); if(ue||!user) throw new Error('Sesi tidak valid');
  const {data:me}=await admin.from('profiles').select('role').eq('auth_user_id',user.id).single(); if(me?.role!=='admin') throw new Error('Hanya admin yang boleh membuat akun');
  const b=await req.json(); const email=String(b.email||'').trim().toLowerCase(), password=String(b.password||''); const full_name=String(b.full_name||'').trim(); const role=['admin','teacher','student'].includes(b.role)?b.role:'student';
  if(!email||!full_name||password.length<8) throw new Error('Nama, email dan password minimal 8 karakter wajib diisi');
  const {data:created,error}=await admin.auth.admin.createUser({email,password,email_confirm:true,user_metadata:{full_name,role}}); if(error) throw error;
  const {data:profile,error:pe}=await admin.from('profiles').update({full_name,email,phone:b.phone||null,role,status:'active'}).eq('auth_user_id',created.user.id).select().single(); if(pe) throw pe;
  if(role==='student'){
    const {error:e}=await admin.from('students').insert({profile_id:profile.id,student_code:b.student_code||('STD-'+Date.now()),full_name,email,phone:b.phone||null,class_id:b.class_id||null,school:b.school||null,parent_name:b.parent_name||null,parent_phone:b.parent_phone||null,status:'active'}); if(e) throw e;
  }
  if(role==='teacher'){
    const {error:e}=await admin.from('teachers').insert({profile_id:profile.id,teacher_code:b.teacher_code||('GURU-'+Date.now()),full_name,email,phone:b.phone||null,specialization:b.specialization||null,status:'active'}); if(e) throw e;
  }
  return new Response(JSON.stringify({ok:true,user_id:created.user.id,profile_id:profile.id}),{headers:{...cors,'Content-Type':'application/json'}});
 }catch(e){return new Response(JSON.stringify({ok:false,error:e.message||String(e)}),{status:400,headers:{...cors,'Content-Type':'application/json'}})}
});
