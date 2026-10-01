-- CONTOH DATA MASTER. Jalankan setelah schema dan sesuaikan nama.
insert into classes(name,level,description) values ('X SMA','X','Kelas 10'),('XI SMA','XI','Kelas 11'),('XII SMA','XII','Kelas 12') on conflict do nothing;
insert into subjects(name) values ('Matematika'),('Bahasa Indonesia'),('Bahasa Inggris'),('Fisika'),('Kimia'),('Biologi') on conflict do nothing;
insert into packages(name,description,price,duration_month,status) values ('Paket TKA SMA','Persiapan TKA SMA',0,6,'active'),('Paket UTBK','Persiapan UTBK',0,6,'active') on conflict do nothing;
