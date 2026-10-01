# GO LIVE CHECKLIST — TRIPLE-F EDUCATION LMS

## GitHub
- [ ] Semua file sudah di repository
- [ ] GitHub Pages aktif
- [ ] `js/config.js` sudah diisi
- [ ] Tidak ada service-role key di repository

## Supabase
- [ ] `supabase_schema.sql` sudah dijalankan lengkap
- [ ] Email/password Auth aktif
- [ ] Admin pertama sudah dibuat
- [ ] Role Admin sudah benar
- [ ] Edge Function `manage-user` sudah deploy
- [ ] `ACCOUNT_API_URL` sudah diisi
- [ ] RPC pengerjaan sudah ada

## Google Drive
- [ ] Apps Script deploy sebagai Web App
- [ ] `DRIVE_ROOT_FOLDER_ID` sudah dibuat
- [ ] URL Apps Script sudah di config
- [ ] Upload materi sudah dites
- [ ] PDF laporan sudah dites

## Data
- [ ] Kelas
- [ ] Mata pelajaran
- [ ] Paket
- [ ] Akun guru
- [ ] Akun siswa
- [ ] Paket siswa
- [ ] Pertemuan
- [ ] Materi
- [ ] Soal Kuis
- [ ] Soal Tryout
- [ ] Soal Drill

## Pengujian
- [ ] Admin login
- [ ] Guru login
- [ ] Siswa login
- [ ] Siswa melihat materi
- [ ] Siswa mengerjakan kuis
- [ ] Nilai kuis tersimpan
- [ ] Siswa mengerjakan tryout
- [ ] Nilai tryout tersimpan
- [ ] Drill harian muncul
- [ ] Nilai drill tersimpan
- [ ] Absensi tersimpan
- [ ] Laporan tampil
- [ ] PDF laporan berhasil
- [ ] WhatsApp link berhasil

## Keamanan
- [ ] Service role hanya di Supabase Edge Function
- [ ] Tidak ada service role di JS frontend
- [ ] Siswa tidak bisa membaca `answer_key` lewat query biasa
- [ ] Admin/Guru memakai akun masing-masing
