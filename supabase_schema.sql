-- ============================================================
-- TRIPLE-F EDUCATION LMS - SUPABASE DATABASE
-- Jalankan seluruh file ini di Supabase SQL Editor.
-- ============================================================
create extension if not exists pgcrypto;

do $$ begin create type user_role as enum ('admin','teacher','student'); exception when duplicate_object then null; end $$;

create table if not exists profiles(
 id uuid primary key default gen_random_uuid(),
 auth_user_id uuid unique references auth.users(id) on delete cascade,
 full_name text not null,
 email text,
 phone text,
 avatar_url text,
 role user_role not null default 'student',
 status text not null default 'active',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists classes(id uuid primary key default gen_random_uuid(),name text not null,level text,description text,status text default 'active',created_at timestamptz default now());
create table if not exists subjects(id uuid primary key default gen_random_uuid(),name text not null,status text default 'active',created_at timestamptz default now());
create table if not exists teachers(id uuid primary key default gen_random_uuid(),profile_id uuid references profiles(id) on delete cascade,teacher_code text unique,full_name text,email text,phone text,specialization text,status text default 'active',created_at timestamptz default now());
create table if not exists students(id uuid primary key default gen_random_uuid(),profile_id uuid references profiles(id) on delete set null,student_code text unique,full_name text,email text,phone text,class_id uuid references classes(id),birth_date date,school text,parent_name text,parent_phone text,address text,status text default 'active',created_at timestamptz default now());
create table if not exists teacher_classes(id uuid primary key default gen_random_uuid(),teacher_id uuid references teachers(id) on delete cascade,class_id uuid references classes(id) on delete cascade,created_at timestamptz default now(),unique(teacher_id,class_id));
create table if not exists packages(id uuid primary key default gen_random_uuid(),name text not null,description text,class_id uuid references classes(id),price numeric(14,2) default 0,duration_month int,status text default 'active',created_at timestamptz default now());
create table if not exists student_packages(id uuid primary key default gen_random_uuid(),student_id uuid references students(id) on delete cascade,package_id uuid references packages(id),start_date date,end_date date,status text default 'active',created_at timestamptz default now());
create table if not exists meetings(id uuid primary key default gen_random_uuid(),class_id uuid references classes(id),package_id uuid references packages(id),teacher_id uuid references teachers(id),subject_id uuid references subjects(id),meeting_number int,title text not null,description text,meeting_date date,start_time time,end_time time,status text default 'upcoming',created_at timestamptz default now());
create table if not exists materials(id uuid primary key default gen_random_uuid(),meeting_id uuid references meetings(id),teacher_id uuid references teachers(id),class_id uuid references classes(id),package_id uuid references packages(id),subject_id uuid references subjects(id),title text not null,description text,content_type text default 'text',content text,drive_file_id text,drive_url text,file_name text,file_type text,file_size bigint,published boolean default false,created_at timestamptz default now(),updated_at timestamptz default now());
create table if not exists attendance(id uuid primary key default gen_random_uuid(),meeting_id uuid references meetings(id) on delete cascade,student_id uuid references students(id) on delete cascade,status text not null check(status in ('Hadir','Izin','Sakit','Alpa')),attendance_date date default current_date,teacher_note text,created_at timestamptz default now(),unique(meeting_id,student_id));
create table if not exists quizzes(id uuid primary key default gen_random_uuid(),title text not null,class_id uuid references classes(id),package_id uuid references packages(id),subject_id uuid references subjects(id),meeting_id uuid references meetings(id),duration_minutes int,start_at timestamptz,end_at timestamptz,status text default 'draft',random_questions boolean default false,random_options boolean default false,attempt_limit int default 1,created_at timestamptz default now());
create table if not exists quiz_questions(id uuid primary key default gen_random_uuid(),quiz_id uuid references quizzes(id) on delete cascade,question_text text not null,image_url text,formula text,explanation text,answer_key text,weight numeric default 1,created_at timestamptz default now());
create table if not exists quiz_options(id uuid primary key default gen_random_uuid(),question_id uuid references quiz_questions(id) on delete cascade,option_key text,option_text text,image_url text);
create table if not exists quiz_attempts(id uuid primary key default gen_random_uuid(),quiz_id uuid references quizzes(id),student_id uuid references students(id),started_at timestamptz default now(),completed_at timestamptz,total_questions int default 0,correct_answers int default 0,wrong_answers int default 0,score numeric default 0,status text default 'in_progress');
create table if not exists quiz_answers(id uuid primary key default gen_random_uuid(),attempt_id uuid references quiz_attempts(id) on delete cascade,question_id uuid references quiz_questions(id),answer text,is_correct boolean,answered_at timestamptz default now(),unique(attempt_id,question_id));
create table if not exists tryouts(id uuid primary key default gen_random_uuid(),title text not null,description text,class_id uuid references classes(id),package_id uuid references packages(id),subject_id uuid references subjects(id),duration_minutes int not null,start_at timestamptz,end_at timestamptz,question_count int default 0,attempt_limit int default 1,random_questions boolean default true,random_options boolean default true,show_explanation boolean default false,status text default 'draft',created_at timestamptz default now());
create table if not exists tryout_questions(id uuid primary key default gen_random_uuid(),tryout_id uuid references tryouts(id) on delete cascade,question_text text not null,image_url text,formula text,explanation text,answer_key text,weight numeric default 1);
create table if not exists tryout_options(id uuid primary key default gen_random_uuid(),question_id uuid references tryout_questions(id) on delete cascade,option_key text,option_text text,image_url text);
create table if not exists tryout_attempts(id uuid primary key default gen_random_uuid(),tryout_id uuid references tryouts(id),student_id uuid references students(id),started_at timestamptz default now(),expires_at timestamptz,completed_at timestamptz,total_questions int default 0,correct_answers int default 0,wrong_answers int default 0,blank_answers int default 0,score numeric default 0,status text default 'in_progress');
create table if not exists tryout_answers(id uuid primary key default gen_random_uuid(),attempt_id uuid references tryout_attempts(id) on delete cascade,question_id uuid references tryout_questions(id),answer text,is_correct boolean,answered_at timestamptz default now(),unique(attempt_id,question_id));
create table if not exists drill_programs(id uuid primary key default gen_random_uuid(),name text not null,package_id uuid references packages(id),class_id uuid references classes(id),subject_id uuid references subjects(id),topic text,start_date date not null,end_date date not null,total_questions int not null default 0,effective_days int not null default 0,daily_target numeric default 0,difficulty text,duration_minutes int,max_attempts int default 1,status text default 'active',created_at timestamptz default now(),updated_at timestamptz default now());
create table if not exists drill_schedules(id uuid primary key default gen_random_uuid(),drill_program_id uuid references drill_programs(id) on delete cascade,weekday int not null check(weekday between 0 and 6),is_effective boolean default true,unique(drill_program_id,weekday));
create table if not exists drill_holidays(id uuid primary key default gen_random_uuid(),date date unique not null,description text,status text default 'holiday',created_at timestamptz default now());
create table if not exists drill_questions(id uuid primary key default gen_random_uuid(),drill_program_id uuid references drill_programs(id) on delete cascade,class_id uuid references classes(id),package_id uuid references packages(id),subject_id uuid references subjects(id),topic text,difficulty text default 'medium',question_text text not null,image_url text,formula text,option_data jsonb,answer_key text,explanation text,weight numeric default 1,created_at timestamptz default now());
create table if not exists drill_daily_targets(id uuid primary key default gen_random_uuid(),student_id uuid references students(id) on delete cascade,drill_program_id uuid references drill_programs(id) on delete cascade,date date not null,is_effective_day boolean default true,target_questions int default 0,completed_questions int default 0,correct_answers int default 0,wrong_answers int default 0,score numeric default 0,status text default 'not_started',created_at timestamptz default now(),updated_at timestamptz default now(),unique(student_id,drill_program_id,date));
create table if not exists drill_attempts(id uuid primary key default gen_random_uuid(),student_id uuid references students(id) on delete cascade,drill_program_id uuid references drill_programs(id),daily_target_id uuid references drill_daily_targets(id),started_at timestamptz default now(),completed_at timestamptz,total_questions int default 0,correct_answers int default 0,wrong_answers int default 0,score numeric default 0,status text default 'in_progress');
create table if not exists drill_answers(id uuid primary key default gen_random_uuid(),attempt_id uuid references drill_attempts(id) on delete cascade,question_id uuid references drill_questions(id),answer text,is_correct boolean,answered_at timestamptz default now(),unique(attempt_id,question_id));
create table if not exists drill_progress(id uuid primary key default gen_random_uuid(),student_id uuid references students(id) on delete cascade,drill_program_id uuid references drill_programs(id) on delete cascade,total_target int default 0,total_completed int default 0,total_correct int default 0,total_wrong int default 0,average_score numeric default 0,updated_at timestamptz default now(),unique(student_id,drill_program_id));
create table if not exists student_streaks(id uuid primary key default gen_random_uuid(),student_id uuid unique references students(id) on delete cascade,current_streak int default 0,longest_streak int default 0,last_effective_activity_date date,updated_at timestamptz default now());
create table if not exists bills(id uuid primary key default gen_random_uuid(),student_id uuid references students(id) on delete cascade,package_id uuid references packages(id),bill_number text unique not null,period_start date,period_end date,amount numeric(14,2) default 0,due_date date,status text default 'unpaid',created_at timestamptz default now());
create table if not exists payments(id uuid primary key default gen_random_uuid(),bill_id uuid references bills(id) on delete cascade,student_id uuid references students(id),amount numeric(14,2) default 0,payment_date date,proof_drive_file_id text,proof_drive_url text,status text default 'pending',admin_note text,created_at timestamptz default now());
create table if not exists reports(id uuid primary key default gen_random_uuid(),student_id uuid references students(id) on delete cascade,period_start date,period_end date,drive_file_id text,drive_url text,created_at timestamptz default now());
create table if not exists notifications(id uuid primary key default gen_random_uuid(),user_profile_id uuid references profiles(id) on delete cascade,title text not null,message text,type text,is_read boolean default false,created_at timestamptz default now());
create table if not exists activity_logs(id uuid primary key default gen_random_uuid(),profile_id uuid references profiles(id),action text not null,entity_type text,entity_id uuid,metadata jsonb,created_at timestamptz default now());

create index if not exists idx_students_class on students(class_id); create index if not exists idx_students_profile on students(profile_id); create index if not exists idx_meetings_date on meetings(meeting_date); create index if not exists idx_drill_targets_date on drill_daily_targets(date); create index if not exists idx_drill_questions_program on drill_questions(drill_program_id); create index if not exists idx_activity_created on activity_logs(created_at);

-- Auto profile ketika akun Auth dibuat. Role selalu student untuk mencegah self-escalation.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(auth_user_id,full_name,email,role) values(new.id,coalesce(new.raw_user_meta_data->>'full_name',split_part(new.email,'@',1)),new.email,'student') on conflict(auth_user_id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.my_role() returns text language sql stable security definer set search_path=public as $$select role::text from profiles where auth_user_id=auth.uid() limit 1$$;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$select coalesce(public.my_role()='admin',false)$$;
create or replace function public.is_teacher() returns boolean language sql stable security definer set search_path=public as $$select coalesce(public.my_role()='teacher',false)$$;
create or replace function public.my_student_id() returns uuid language sql stable security definer set search_path=public as $$select id from students s join profiles p on p.id=s.profile_id where p.auth_user_id=auth.uid() limit 1$$;
create or replace function public.my_teacher_id() returns uuid language sql stable security definer set search_path=public as $$select id from teachers t join profiles p on p.id=t.profile_id where p.auth_user_id=auth.uid() limit 1$$;

-- RLS
alter table profiles enable row level security; alter table students enable row level security; alter table teachers enable row level security; alter table teacher_classes enable row level security; alter table classes enable row level security; alter table subjects enable row level security; alter table packages enable row level security; alter table student_packages enable row level security; alter table meetings enable row level security; alter table materials enable row level security; alter table attendance enable row level security; alter table quizzes enable row level security; alter table quiz_questions enable row level security; alter table quiz_options enable row level security; alter table quiz_attempts enable row level security; alter table quiz_answers enable row level security; alter table tryouts enable row level security; alter table tryout_questions enable row level security; alter table tryout_options enable row level security; alter table tryout_attempts enable row level security; alter table tryout_answers enable row level security; alter table drill_programs enable row level security; alter table drill_schedules enable row level security; alter table drill_holidays enable row level security; alter table drill_questions enable row level security; alter table drill_daily_targets enable row level security; alter table drill_attempts enable row level security; alter table drill_answers enable row level security; alter table drill_progress enable row level security; alter table student_streaks enable row level security; alter table bills enable row level security; alter table payments enable row level security; alter table reports enable row level security; alter table notifications enable row level security; alter table activity_logs enable row level security;

do $$ declare t text; begin for t in select tablename from pg_tables where schemaname='public' and tablename in ('profiles','students','teachers','teacher_classes','classes','subjects','packages','student_packages','meetings','materials','attendance','quizzes','quiz_questions','quiz_options','quiz_attempts','quiz_answers','tryouts','tryout_questions','tryout_options','tryout_attempts','tryout_answers','drill_programs','drill_schedules','drill_holidays','drill_questions','drill_daily_targets','drill_attempts','drill_answers','drill_progress','student_streaks','bills','payments','reports','notifications','activity_logs') loop execute format('drop policy if exists admin_all_%I on public.%I',t,t); execute format('create policy admin_all_%I on public.%I for all using(public.is_admin()) with check(public.is_admin())',t,t); end loop; end $$;

create policy profiles_self on profiles for select using(auth_user_id=auth.uid() or public.is_admin());
create policy profiles_self_update on profiles for update using(auth_user_id=auth.uid() or public.is_admin()) with check(auth_user_id=auth.uid() or public.is_admin());
create policy classes_read on classes for select using(auth.uid() is not null); create policy subjects_read on subjects for select using(auth.uid() is not null); create policy packages_read on packages for select using(auth.uid() is not null);
create policy students_read on students for select using(profile_id=(select id from profiles where auth_user_id=auth.uid()) or public.is_teacher() or public.is_admin());
create policy students_teacher_update on students for update using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy teachers_read on teachers for select using(auth.uid() is not null);
create policy teacher_classes_read on teacher_classes for select using(auth.uid() is not null);
create policy student_packages_read on student_packages for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin());
create policy meetings_read on meetings for select using(auth.uid() is not null);
create policy materials_read on materials for select using(published=true or public.is_teacher() or public.is_admin());
create policy materials_teacher_write on materials for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy attendance_student_read on attendance for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin());
create policy attendance_teacher_write on attendance for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy quizzes_read on quizzes for select using(auth.uid() is not null);
create policy quiz_questions_read on quiz_questions for select using(auth.uid() is not null);
create policy quiz_options_read on quiz_options for select using(auth.uid() is not null);
create policy quiz_attempts_self on quiz_attempts for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin());
create policy quiz_attempts_student_insert on quiz_attempts for insert with check(student_id=public.my_student_id() or public.is_admin());
create policy quiz_answers_self on quiz_answers for all using(exists(select 1 from quiz_attempts a where a.id=attempt_id and (a.student_id=public.my_student_id() or public.is_admin()))) with check(exists(select 1 from quiz_attempts a where a.id=attempt_id and (a.student_id=public.my_student_id() or public.is_admin())));
create policy tryouts_read on tryouts for select using(auth.uid() is not null); create policy tryout_questions_read on tryout_questions for select using(auth.uid() is not null); create policy tryout_options_read on tryout_options for select using(auth.uid() is not null);
create policy tryout_attempts_self on tryout_attempts for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin()); create policy tryout_attempts_student_insert on tryout_attempts for insert with check(student_id=public.my_student_id() or public.is_admin());
create policy tryout_answers_self on tryout_answers for all using(exists(select 1 from tryout_attempts a where a.id=attempt_id and (a.student_id=public.my_student_id() or public.is_admin()))) with check(exists(select 1 from tryout_attempts a where a.id=attempt_id and (a.student_id=public.my_student_id() or public.is_admin())));
create policy drill_programs_read on drill_programs for select using(auth.uid() is not null); create policy drill_programs_teacher_write on drill_programs for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy drill_schedules_read on drill_schedules for select using(auth.uid() is not null); create policy drill_schedules_teacher_write on drill_schedules for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy drill_holidays_read on drill_holidays for select using(auth.uid() is not null); create policy drill_holidays_admin_write on drill_holidays for all using(public.is_admin()) with check(public.is_admin());
create policy drill_questions_read on drill_questions for select using(auth.uid() is not null); create policy drill_questions_teacher_write on drill_questions for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy drill_targets_self on drill_daily_targets for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin());
create policy drill_targets_self_update on drill_daily_targets for update using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin()) with check(student_id=public.my_student_id() or public.is_teacher() or public.is_admin());
create policy drill_attempts_self on drill_attempts for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin()); create policy drill_attempts_student_insert on drill_attempts for insert with check(student_id=public.my_student_id() or public.is_admin());
create policy drill_answers_self on drill_answers for all using(exists(select 1 from drill_attempts a where a.id=attempt_id and (a.student_id=public.my_student_id() or public.is_admin()))) with check(exists(select 1 from drill_attempts a where a.id=attempt_id and (a.student_id=public.my_student_id() or public.is_admin())));
create policy drill_progress_self on drill_progress for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin()); create policy streak_self on student_streaks for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin());
create policy bills_self on bills for select using(student_id=public.my_student_id() or public.is_admin() or public.is_teacher()); create policy payments_self on payments for select using(student_id=public.my_student_id() or public.is_admin()); create policy payments_student_insert on payments for insert with check(student_id=public.my_student_id() or public.is_admin());
create policy reports_self on reports for select using(student_id=public.my_student_id() or public.is_teacher() or public.is_admin()); create policy notifications_self on notifications for select using(user_profile_id=(select id from profiles where auth_user_id=auth.uid()) or public.is_admin());
create policy activity_self on activity_logs for insert with check(profile_id=(select id from profiles where auth_user_id=auth.uid()) or public.is_admin()); create policy activity_read_admin on activity_logs for select using(public.is_admin());

-- Generator target harian. Jalankan manual/cron setiap hari:
-- select public.generate_drill_targets(current_date);
create or replace function public.generate_drill_targets(p_date date default current_date) returns integer language plpgsql security definer set search_path=public as $$
declare inserted_count integer:=0; p record; d record; target integer; base integer; rem integer; seq integer; totaldays integer; begin
 for p in select * from drill_programs where status='active' and p_date between start_date and end_date loop
  if exists(select 1 from drill_holidays h where h.date=p_date) then continue; end if;
  if not exists(select 1 from drill_schedules s where s.drill_program_id=p.id and s.weekday=extract(dow from p_date)::int and s.is_effective) then continue; end if;
  select count(*) into totaldays from generate_series(p.start_date,p.end_date,'1 day') g(d) where not exists(select 1 from drill_holidays h where h.date=g.d::date) and exists(select 1 from drill_schedules s where s.drill_program_id=p.id and s.weekday=extract(dow from g.d)::int and s.is_effective);
  select count(*) into seq from generate_series(p.start_date,p_date,'1 day') g(d) where not exists(select 1 from drill_holidays h where h.date=g.d::date) and exists(select 1 from drill_schedules s where s.drill_program_id=p.id and s.weekday=extract(dow from g.d)::int and s.is_effective);
  if totaldays=0 then continue; end if; base:=floor(p.total_questions::numeric/totaldays); rem:=mod(p.total_questions,totaldays); target:=base+case when seq<=rem then 1 else 0 end;
  for d in select sp.student_id from student_packages sp where sp.package_id=p.package_id and sp.status='active' and p_date between sp.start_date and sp.end_date loop
   insert into drill_daily_targets(student_id,drill_program_id,date,is_effective_day,target_questions,status) values(d.student_id,p.id,p_date,true,target,'not_started') on conflict(student_id,drill_program_id,date) do update set target_questions=excluded.target_questions,updated_at=now(); inserted_count:=inserted_count+1;
  end loop;
 end loop; return inserted_count; end; $$;

-- Setelah membuat akun Admin pertama di Authentication, ubah role profilnya:
-- update public.profiles set role='admin' where email='EMAIL_ADMIN_ANDA';
-- Untuk akun guru: buat Auth user -> update profile role='teacher' -> isi tabel teachers.

-- ============================================================
-- HARDENING + MESIN PENGERJAAN LMS
-- Jalankan bagian ini setelah schema utama.
-- Siswa TIDAK diberi akses langsung ke answer_key; soal peserta
-- diberikan melalui RPC security-definer di bawah.
-- ============================================================
drop policy if exists quiz_questions_read on public.quiz_questions;
drop policy if exists quiz_options_read on public.quiz_options;
drop policy if exists tryout_questions_read on public.tryout_questions;
drop policy if exists tryout_options_read on public.tryout_options;
create policy quiz_questions_staff_read on public.quiz_questions for select using(public.is_teacher() or public.is_admin());
create policy quiz_questions_staff_write on public.quiz_questions for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy quiz_options_staff_read on public.quiz_options for select using(public.is_teacher() or public.is_admin());
create policy quiz_options_staff_write on public.quiz_options for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy tryout_questions_staff_read on public.tryout_questions for select using(public.is_teacher() or public.is_admin());
create policy tryout_questions_staff_write on public.tryout_questions for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
create policy tryout_options_staff_read on public.tryout_options for select using(public.is_teacher() or public.is_admin());
create policy tryout_options_staff_write on public.tryout_options for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());

drop policy if exists quiz_attempts_student_update on public.quiz_attempts;
create policy quiz_attempts_student_update on public.quiz_attempts for update using(student_id=public.my_student_id() or public.is_admin()) with check(student_id=public.my_student_id() or public.is_admin());
drop policy if exists tryout_attempts_student_update on public.tryout_attempts;
create policy tryout_attempts_student_update on public.tryout_attempts for update using(student_id=public.my_student_id() or public.is_admin()) with check(student_id=public.my_student_id() or public.is_admin());
drop policy if exists drill_attempts_student_update on public.drill_attempts;
create policy drill_attempts_student_update on public.drill_attempts for update using(student_id=public.my_student_id() or public.is_admin()) with check(student_id=public.my_student_id() or public.is_admin());

create or replace function public.assert_my_student(p_student uuid) returns void language plpgsql security definer set search_path=public as $$ begin if public.is_admin() then return; end if; if public.my_student_id() is distinct from p_student then raise exception 'Akses siswa tidak valid'; end if; end; $$;

create or replace function public.start_quiz_attempt(p_set_id uuid,p_student_id uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare q record; attempt uuid; used int; payload jsonb; dur int; ttl int;
begin
 perform public.assert_my_student(p_student_id);
 select duration_minutes,attempt_limit into dur,ttl from quizzes where id=p_set_id and status='published';
 if dur is null then raise exception 'Kuis tidak tersedia'; end if;
 select count(*) into used from quiz_attempts where quiz_id=p_set_id and student_id=p_student_id;
 if used >= coalesce(ttl,1) then raise exception 'Batas percobaan sudah habis'; end if;
 insert into quiz_attempts(quiz_id,student_id,total_questions,status) values(p_set_id,p_student_id,0,'in_progress') returning id into attempt;
 select jsonb_agg(jsonb_build_object('id',x.id,'question_text',x.question_text,'image_url',x.image_url,'formula',x.formula,'options',x.options)) into payload
 from (select qq.*,coalesce((select jsonb_agg(jsonb_build_object('option_key',qo.option_key,'option_text',qo.option_text,'image_url',qo.image_url) order by qo.option_key) from quiz_options qo where qo.question_id=qq.id),'[]'::jsonb) options from quiz_questions qq where qq.quiz_id=p_set_id order by random()) x;
 update quiz_attempts set total_questions=coalesce(jsonb_array_length(payload),0) where id=attempt;
 return jsonb_build_object('attempt_id',attempt,'title',(select title from quizzes where id=p_set_id),'duration_minutes',dur,'duration_seconds',dur*60,'questions',coalesce(payload,'[]'::jsonb));
end; $$;

create or replace function public.submit_quiz_attempt(p_attempt_id uuid,p_answers jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare a record; q record; ans text; correct int:=0; total int:=0; wrong int:=0; blank int:=0; score numeric:=0;
begin
 select * into a from quiz_attempts where id=p_attempt_id;
 if not found then raise exception 'Percobaan tidak ditemukan'; end if;
 perform public.assert_my_student(a.student_id);
 if a.status='completed' then return jsonb_build_object('correct_answers',a.correct_answers,'wrong_answers',a.wrong_answers,'blank_answers',greatest(a.total_questions-a.correct_answers-a.wrong_answers,0),'score',a.score); end if;
 for q in select id,answer_key,weight from quiz_questions where quiz_id=a.quiz_id loop
  total:=total+1; ans:=nullif(upper(trim(p_answers->>q.id::text)),'');
  if ans is null then blank:=blank+1; else if ans=upper(trim(q.answer_key)) then correct:=correct+1; else wrong:=wrong+1; end if; end if;
  insert into quiz_answers(attempt_id,question_id,answer,is_correct) values(a.id,q.id,ans,case when ans is not null then ans=upper(trim(q.answer_key)) else false end) on conflict(attempt_id,question_id) do update set answer=excluded.answer,is_correct=excluded.is_correct,answered_at=now();
 end loop;
 if total>0 then score:=round(correct::numeric/total*100,2); end if;
 update quiz_attempts set completed_at=now(),total_questions=total,correct_answers=correct,wrong_answers=wrong,score=score,status='completed' where id=a.id;
 return jsonb_build_object('correct_answers',correct,'wrong_answers',wrong,'blank_answers',blank,'score',score);
end; $$;

create or replace function public.start_tryout_attempt(p_set_id uuid,p_student_id uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare payload jsonb; attempt uuid; dur int; ttl int; used int;
begin
 perform public.assert_my_student(p_student_id);
 select duration_minutes,attempt_limit into dur,ttl from tryouts where id=p_set_id and status='published';
 if dur is null then raise exception 'Tryout tidak tersedia'; end if;
 select count(*) into used from tryout_attempts where tryout_id=p_set_id and student_id=p_student_id;
 if used >= coalesce(ttl,1) then raise exception 'Batas percobaan sudah habis'; end if;
 select jsonb_agg(jsonb_build_object('id',x.id,'question_text',x.question_text,'image_url',x.image_url,'formula',x.formula,'options',x.options)) into payload from (select tq.*,coalesce((select jsonb_agg(jsonb_build_object('option_key',to2.option_key,'option_text',to2.option_text,'image_url',to2.image_url) order by to2.option_key) from tryout_options to2 where to2.question_id=tq.id),'[]'::jsonb) options from tryout_questions tq where tq.tryout_id=p_set_id order by random()) x;
 insert into tryout_attempts(tryout_id,student_id,expires_at,total_questions,status) values(p_set_id,p_student_id,now()+make_interval(mins=>dur),coalesce(jsonb_array_length(payload),0),'in_progress') returning id into attempt;
 return jsonb_build_object('attempt_id',attempt,'title',(select title from tryouts where id=p_set_id),'duration_minutes',dur,'duration_seconds',dur*60,'questions',coalesce(payload,'[]'::jsonb));
end; $$;

create or replace function public.submit_tryout_attempt(p_attempt_id uuid,p_answers jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare a record; q record; ans text; correct int:=0; total int:=0; wrong int:=0; blank int:=0; score numeric:=0;
begin
 select * into a from tryout_attempts where id=p_attempt_id;
 if not found then raise exception 'Percobaan tidak ditemukan'; end if;
 perform public.assert_my_student(a.student_id);
 if a.status='completed' then return jsonb_build_object('correct_answers',a.correct_answers,'wrong_answers',a.wrong_answers,'blank_answers',a.blank_answers,'score',a.score); end if;
 for q in select id,answer_key,weight from tryout_questions where tryout_id=a.tryout_id loop
  total:=total+1; ans:=nullif(upper(trim(p_answers->>q.id::text)),'');
  if ans is null then blank:=blank+1; else if ans=upper(trim(q.answer_key)) then correct:=correct+1; else wrong:=wrong+1; end if; end if;
  insert into tryout_answers(attempt_id,question_id,answer,is_correct) values(a.id,q.id,ans,case when ans is not null then ans=upper(trim(q.answer_key)) else false end) on conflict(attempt_id,question_id) do update set answer=excluded.answer,is_correct=excluded.is_correct,answered_at=now();
 end loop;
 if total>0 then score:=round(correct::numeric/total*100,2); end if;
 update tryout_attempts set completed_at=now(),total_questions=total,correct_answers=correct,wrong_answers=wrong,blank_answers=blank,score=score,status='completed' where id=a.id;
 return jsonb_build_object('correct_answers',correct,'wrong_answers',wrong,'blank_answers',blank,'score',score);
end; $$;

create or replace function public.start_drill_attempt(p_target_id uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare t record; a uuid; payload jsonb; n int;
begin
 select dt.*,dp.duration_minutes,dp.id program_id,dp.class_id,dp.package_id,dp.subject_id into t from drill_daily_targets dt join drill_programs dp on dp.id=dt.drill_program_id where dt.id=p_target_id;
 if not found then raise exception 'Target drill tidak ditemukan'; end if;
 perform public.assert_my_student(t.student_id);
 if t.completed_questions>=t.target_questions then raise exception 'Target hari ini sudah selesai'; end if;
 n:=greatest(t.target_questions-t.completed_questions,1);
 select jsonb_agg(jsonb_build_object('id',x.id,'question_text',x.question_text,'image_url',x.image_url,'formula',x.formula,'option_data',x.option_data)) into payload from (select dq.* from drill_questions dq where dq.drill_program_id=t.program_id order by random() limit n) x;
 insert into drill_attempts(student_id,drill_program_id,daily_target_id,total_questions,status) values(t.student_id,t.program_id,t.id,coalesce(jsonb_array_length(payload),0),'in_progress') returning id into a;
 return jsonb_build_object('attempt_id',a,'duration_seconds',coalesce(t.duration_minutes,0)*60,'questions',coalesce(payload,'[]'::jsonb));
end; $$;

create or replace function public.submit_drill_attempt(p_attempt_id uuid,p_answers jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare a record; q record; ans text; correct int:=0; total int:=0; wrong int:=0; score numeric:=0;
begin
 select da.*,dt.target_questions,dt.completed_questions into a from drill_attempts da join drill_daily_targets dt on dt.id=da.daily_target_id where da.id=p_attempt_id;
 if not found then raise exception 'Percobaan drill tidak ditemukan'; end if;
 perform public.assert_my_student(a.student_id);
 if a.status='completed' then return jsonb_build_object('correct_answers',a.correct_answers,'wrong_answers',a.wrong_answers,'score',a.score); end if;
 for q in select id,answer_key from drill_questions where id in (select value::uuid from jsonb_object_keys(p_answers) as k(value) where value ~ '^[0-9a-f-]{36}$') loop
  total:=total+1; ans:=nullif(upper(trim(p_answers->>q.id::text)),'');
  if ans=upper(trim(q.answer_key)) then correct:=correct+1; else wrong:=wrong+1; end if;
  insert into drill_answers(attempt_id,question_id,answer,is_correct) values(a.id,q.id,ans,ans=upper(trim(q.answer_key))) on conflict(attempt_id,question_id) do update set answer=excluded.answer,is_correct=excluded.is_correct,answered_at=now();
 end loop;
 if total>0 then score:=round(correct::numeric/total*100,2); end if;
 update drill_attempts set completed_at=now(),total_questions=total,correct_answers=correct,wrong_answers=wrong,score=score,status='completed' where id=a.id;
 update drill_daily_targets set completed_questions=least(target_questions,completed_questions+total),correct_answers=correct_answers+correct,wrong_answers=wrong_answers+wrong,score=case when target_questions>0 then round((least(target_questions,completed_questions+total)::numeric/target_questions)*100,2) else 0 end,status=case when completed_questions+total>=target_questions then 'completed' else 'in_progress' end,updated_at=now() where id=a.daily_target_id;
 return jsonb_build_object('correct_answers',correct,'wrong_answers',wrong,'score',score);
end; $$;

grant execute on function public.start_quiz_attempt(uuid,uuid) to authenticated;
grant execute on function public.submit_quiz_attempt(uuid,jsonb) to authenticated;
grant execute on function public.start_tryout_attempt(uuid,uuid) to authenticated;
grant execute on function public.submit_tryout_attempt(uuid,jsonb) to authenticated;
grant execute on function public.start_drill_attempt(uuid) to authenticated;
grant execute on function public.submit_drill_attempt(uuid,jsonb) to authenticated;
grant execute on function public.generate_drill_targets(date) to authenticated;

-- Guru boleh membuat dan mengelola evaluasi serta jadwal pembelajaran.
drop policy if exists quizzes_teacher_write on public.quizzes;
create policy quizzes_teacher_write on public.quizzes for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
drop policy if exists tryouts_teacher_write on public.tryouts;
create policy tryouts_teacher_write on public.tryouts for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());
drop policy if exists meetings_teacher_write on public.meetings;
create policy meetings_teacher_write on public.meetings for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());

-- ============================================================
-- TRIPLE-F EDUCATION - JADWAL PAKET & PRESENSI BERBASIS SESI
-- Jalankan bagian ini juga jika database sudah pernah dibuat.
-- ============================================================
create table if not exists public.package_schedules(
 id uuid primary key default gen_random_uuid(),
 package_id uuid not null references public.packages(id) on delete cascade,
 class_id uuid not null references public.classes(id),
 subject_id uuid not null references public.subjects(id),
 teacher_id uuid not null references public.teachers(id),
 weekday int not null check(weekday between 0 and 6),
 start_time time not null,
 end_time time not null,
 room text,
 status text not null default 'active',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists idx_package_schedules_package on public.package_schedules(package_id);
create index if not exists idx_package_schedules_teacher on public.package_schedules(teacher_id);
create index if not exists idx_package_schedules_weekday on public.package_schedules(weekday);

alter table public.attendance add column if not exists schedule_id uuid references public.package_schedules(id) on delete cascade;
create index if not exists idx_attendance_schedule_date on public.attendance(schedule_id,attendance_date);
create unique index if not exists uq_attendance_schedule_student_date on public.attendance(schedule_id,student_id,attendance_date) where schedule_id is not null;

alter table public.quizzes add column if not exists schedule_id uuid references public.package_schedules(id) on delete set null;
create index if not exists idx_quizzes_schedule on public.quizzes(schedule_id);

alter table public.package_schedules enable row level security;
drop policy if exists package_schedules_admin_all on public.package_schedules;
create policy package_schedules_admin_all on public.package_schedules for all using(public.is_admin()) with check(public.is_admin());
drop policy if exists package_schedules_teacher_read on public.package_schedules;
create policy package_schedules_teacher_read on public.package_schedules for select using(public.is_teacher() and teacher_id=public.my_teacher_id());
drop policy if exists package_schedules_student_read on public.package_schedules;
create policy package_schedules_student_read on public.package_schedules for select using(exists(select 1 from public.student_packages sp where sp.student_id=public.my_student_id() and sp.package_id=package_schedules.package_id and sp.status='active' and (sp.start_date is null or sp.start_date<=current_date) and (sp.end_date is null or sp.end_date>=current_date)));

-- Guru hanya boleh mengisi presensi pada jadwal yang menjadi tanggung jawabnya.
drop policy if exists attendance_teacher_write on public.attendance;
create policy attendance_teacher_write on public.attendance for all using(
 public.is_admin() or (
  public.is_teacher() and (
   (meeting_id is not null and exists(select 1 from public.meetings m where m.id=meeting_id and m.teacher_id=public.my_teacher_id()))
   or
   (schedule_id is not null and exists(select 1 from public.package_schedules ps where ps.id=schedule_id and ps.teacher_id=public.my_teacher_id()))
  )
 )
) with check(
 public.is_admin() or (
  public.is_teacher() and (
   (meeting_id is not null and exists(select 1 from public.meetings m where m.id=meeting_id and m.teacher_id=public.my_teacher_id()))
   or
   (schedule_id is not null and exists(select 1 from public.package_schedules ps where ps.id=schedule_id and ps.teacher_id=public.my_teacher_id()))
  )
 )
);

-- Kuis dapat dikaitkan langsung dengan jadwal paket sehingga guru membuat evaluasi sesuai sesi.
drop policy if exists quizzes_teacher_write on public.quizzes;
create policy quizzes_teacher_write on public.quizzes for all using(public.is_teacher() or public.is_admin()) with check(public.is_teacher() or public.is_admin());

-- Jadwal paket dikelola Admin. Guru hanya membaca jadwalnya dan mengisi presensi/kuis.
drop policy if exists package_schedules_teacher_write on public.package_schedules;

-- Kuis siswa dibatasi ke kelas + paket aktif siswa (jika kuis terhubung ke paket).
create or replace function public.start_quiz_attempt(p_set_id uuid,p_student_id uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare q record; attempt uuid; used int; payload jsonb; dur int; ttl int;
begin
 perform public.assert_my_student(p_student_id);
 select duration_minutes,attempt_limit,package_id,class_id into dur,ttl,q.package_id,q.class_id from public.quizzes where id=p_set_id and status='published';
 if dur is null then raise exception 'Kuis tidak tersedia'; end if;
 if q.class_id is not null and not exists(select 1 from public.students s where s.id=p_student_id and s.class_id=q.class_id) then raise exception 'Kuis ini bukan untuk kelas Anda'; end if;
 if q.package_id is not null and not exists(select 1 from public.student_packages sp where sp.student_id=p_student_id and sp.package_id=q.package_id and sp.status='active' and (sp.start_date is null or sp.start_date<=current_date) and (sp.end_date is null or sp.end_date>=current_date)) then raise exception 'Kuis ini bukan untuk paket aktif Anda'; end if;
 select count(*) into used from public.quiz_attempts where quiz_id=p_set_id and student_id=p_student_id;
 if used >= coalesce(ttl,1) then raise exception 'Batas percobaan sudah habis'; end if;
 insert into public.quiz_attempts(quiz_id,student_id,total_questions,status) values(p_set_id,p_student_id,0,'in_progress') returning id into attempt;
 select jsonb_agg(jsonb_build_object('id',x.id,'question_text',x.question_text,'image_url',x.image_url,'formula',x.formula,'options',x.options)) into payload
 from (select qq.*,coalesce((select jsonb_agg(jsonb_build_object('option_key',qo.option_key,'option_text',qo.option_text,'image_url',qo.image_url) order by qo.option_key) from public.quiz_options qo where qo.question_id=qq.id),'[]'::jsonb) options from public.quiz_questions qq where qq.quiz_id=p_set_id order by random()) x;
 update public.quiz_attempts set total_questions=coalesce(jsonb_array_length(payload),0) where id=attempt;
 return jsonb_build_object('attempt_id',attempt,'title',(select title from public.quizzes where id=p_set_id),'duration_minutes',dur,'duration_seconds',dur*60,'questions',coalesce(payload,'[]'::jsonb));
end; $$;
grant execute on function public.start_quiz_attempt(uuid,uuid) to authenticated;
