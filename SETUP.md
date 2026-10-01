# TRIPLE-F EDUCATION LMS — SETUP FINAL

Versi ini ditujukan untuk **GitHub Pages + Supabase + Google Drive**. Setelah setup awal selesai, aktivitas harian dilakukan dari website: membuat akun, data siswa/guru, paket siswa, **jadwal paket**, pertemuan, materi, kuis, bank soal, drill, presensi, tagihan, dan laporan. Admin tetap dapat mengelola Tryout jika modul simulasi digunakan.

## 1. Struktur

- Frontend: GitHub Pages
- Database + Authentication: Supabase
- Pembuatan akun Admin/Guru/Siswa dari web: Supabase Edge Function `manage-user`
- File materi/laporan: Google Drive melalui Apps Script
- Kunci jawaban: tidak diberikan melalui query biasa ke siswa; pengerjaan memakai RPC Supabase.

## 2. Upload ke GitHub

Buat repository baru, misalnya `triple-f-education-lms`.
Upload **seluruh isi folder ini**, bukan folder induknya saja.

GitHub Pages:
1. Settings → Pages
2. Deploy from branch
3. Branch `main`
4. Folder `/root`
5. Save

## 3. Supabase

Buat project Supabase.

Buka SQL Editor lalu jalankan **seluruh `supabase_schema.sql` dari atas sampai bawah**.
Jalankan satu kali pada database baru.

Aktifkan Authentication → Email/Password.

### Admin pertama

Untuk pertama kali, buat satu user Admin dari Supabase Authentication → Users → Add user.
Setelah user dibuat, jalankan:

```sql
update public.profiles
set role='admin'
where email='EMAIL_ADMIN_ANDA';
```

Setelah Admin pertama bisa login, akun berikutnya dibuat dari menu **Akun** di website.

## 4. Supabase Edge Function — agar akun bisa dibuat dari web

Folder function ada di:

`supabase/functions/manage-user/index.ts`

Install Supabase CLI jika belum ada, lalu login dan link project:

```bash
supabase login
supabase link --project-ref PROJECT_REF_ANDA
```

Deploy:

```bash
supabase functions deploy manage-user
```

Function memakai `SUPABASE_SERVICE_ROLE_KEY` di server Supabase. **Jangan pernah memasukkan service role key ke GitHub atau `config.js`.**

Supabase biasanya menyediakan `SUPABASE_URL` dan service role secret untuk Edge Functions. Jika perlu mengatur manual:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="SERVICE_ROLE_KEY_ANDA"
```

URL function setelah deploy:

`https://PROJECT_REF_ANDA.supabase.co/functions/v1/manage-user`

Masukkan URL tersebut ke:

`js/config.js`

pada:

```js
ACCOUNT_API_URL:'https://PROJECT_REF_ANDA.supabase.co/functions/v1/manage-user'
```

## 5. Isi config.js

Buka `js/config.js`:

```js
export const CONFIG={
 APP_NAME:'TRIPLE-F EDUCATION LMS',
 SUPABASE_URL:'https://PROJECT_REF_ANDA.supabase.co',
 SUPABASE_ANON_KEY:'ANON_KEY_ANDA',
 DRIVE_API_URL:'URL_APPS_SCRIPT',
 ACCOUNT_API_URL:'https://PROJECT_REF_ANDA.supabase.co/functions/v1/manage-user',
 SCHOOL_NAME:'TRIPLE-F EDUCATION',
 WHATSAPP_COUNTRY:'62'
};
```

Yang boleh ada di GitHub adalah **Supabase URL + anon/publishable key**. Jangan masukkan service-role key.

## 6. Google Drive

Buka Google Apps Script dan salin isi:

`google-apps-script/Code.gs`

Deploy → New deployment → Web app.

Pengaturan:
- Execute as: Me
- Who has access: Anyone

Buat folder utama Google Drive. Ambil Folder ID dan simpan di Script Properties dengan nama:

`DRIVE_ROOT_FOLDER_ID`

Subfolder yang digunakan:
- `01_MATERI`
- `02_SOAL`
- `03_BUKTI_PEMBAYARAN`
- `06_LAPORAN`

Salin URL Web App ke `DRIVE_API_URL`.

> Catatan privasi: versi Apps Script saat ini membuat file Drive dapat dibuka oleh siapa pun yang memiliki link. Untuk data siswa yang sangat sensitif, gunakan Storage privat + mekanisme signed URL sebagai tahap keamanan berikutnya.

## 7. Urutan pengisian data dari website

Setelah Admin login, gunakan urutan berikut:

1. **Akun** — buat akun siswa/guru/admin.
2. **Kelas** — misalnya X, XI, XII.
3. **Mata Pelajaran** — Matematika, Bahasa Indonesia, dll.
4. **Paket** — paket belajar dan harga.
5. **Paket Siswa** — hubungkan siswa ke paket dan periode aktif.
6. **Pertemuan** — jadwal belajar.
7. **Materi** — teks atau upload file ke Google Drive.
8. **Kuis** — buat kuis → buka Bank Soal → masukkan pertanyaan dan pilihan.
9. **Tryout (Admin)** — buat tryout → Bank Soal. Guru tidak memiliki menu untuk membuat Tryout.
10. **Drill Harian** — buat program → Bank Soal Drill.
11. **Absensi** — pilih pertemuan → isi status siswa.
12. **Tagihan** — masukkan tagihan siswa.
13. **Laporan** — pilih siswa → lihat hasil → PDF / WhatsApp.

## 8. Membuat akun dari web

Admin → **Akun → + Buat Akun**.

### Siswa

Isi:
- Nama
- Email login
- Password awal minimal 8 karakter
- Peran Siswa
- HP
- Kelas
- Sekolah
- Orang tua
- HP orang tua

Sistem otomatis membuat:
- Authentication user
- Profile
- Data siswa

### Guru

Isi:
- Nama
- Email
- Password
- Peran Guru
- HP
- Spesialisasi

Sistem otomatis membuat Authentication user + Profile + Data Guru.

### Admin

Pilih peran Admin. Tidak perlu membuat data siswa/guru.

## 9. Bank soal

### Kuis

Admin/Guru → Kuis → buat kuis → Bank Soal → + Soal.

Isi:
- Pertanyaan
- Rumus LaTeX jika ada
- URL gambar jika ada
- Penjelasan
- Kunci A/B/C/D/E
- Bobot
- Pilihan jawaban

### Tryout

Alurnya sama dengan Kuis.

### Drill

Admin/Guru → Drill Harian → buat program → Bank Soal → + Soal.

Pilihan Drill disimpan sebagai JSON, contoh:

```json
[
 {"key":"A","text":"x = 2"},
 {"key":"B","text":"x = 3"},
 {"key":"C","text":"x = 4"},
 {"key":"D","text":"x = 5"}
]
```

## 10. Drill Harian

Program Drill memiliki:
- paket
- kelas
- mata pelajaran
- topik
- tanggal mulai
- tanggal selesai
- total target soal
- hari efektif
- durasi

Sistem membagi target ke hari efektif. Hari Minggu tidak digunakan jika tidak dicentang. Hari libur dapat dikelola melalui tabel `drill_holidays` atau dikembangkan menjadi menu kalender admin.

Target siswa dibuat dari `student_packages` aktif.

## 11. Pengerjaan siswa

Siswa login lalu:

- **Belajar** → materi
- **Kuis** → kuis published
- **Tryout** → tryout published
- **Drill Harian** → target hari ini
- **Nilai** → laporan hasil
- **Tagihan** → tagihan

Timer berjalan di browser dan penilaian final dilakukan oleh fungsi database Supabase.

## 12. Publikasi Kuis/Tryout

Setelah bank soal selesai, ubah status menjadi:

`published`

Siswa hanya melihat yang berstatus `published`.

## 13. Keamanan kunci jawaban

Jangan memberikan akses publik langsung ke kolom `answer_key` kepada siswa.
Schema final mengganti policy soal sehingga siswa mendapatkan soal melalui RPC:

- `start_quiz_attempt`
- `submit_quiz_attempt`
- `start_tryout_attempt`
- `submit_tryout_attempt`
- `start_drill_attempt`
- `submit_drill_attempt`

Kunci jawaban hanya dipakai di server/database saat penilaian.

## 13A. Jadwal Paket, Kelas Siswa dan Presensi

Setelah master data tersedia, buat jadwal dari menu **Admin → Jadwal Paket**. Setiap jadwal berisi:

- Paket belajar
- Kelas
- Mata pelajaran
- Guru
- Hari
- Jam mulai dan selesai
- Ruangan/link

Siswa yang mempunyai `student_packages` aktif akan otomatis melihat jadwal paketnya pada **Dashboard Siswa → Jadwal Saya**. Nama sekolah dan kelas siswa juga tampil di dashboard.

Guru melihat jadwal yang ditugaskan pada **Jadwal Mengajar**. Pada **Presensi**, guru hanya melihat sesi yang menjadi tanggung jawabnya. Saat presensi dibuka, sistem mengambil siswa aktif yang terdaftar pada paket + kelas tersebut.

Untuk guru, evaluasi dibuat melalui **Kuis** dan kuis harus dikaitkan dengan jadwal sesi. Menu Tryout tidak ditampilkan pada dashboard Guru.

Jika database sudah pernah dibuat sebelum modul jadwal ditambahkan, jalankan bagian paling bawah `supabase_schema.sql` yang berjudul **JADWAL PAKET & PRESENSI BERBASIS SESI**.

## 14. Tes setelah instalasi

### Admin
- Login
- Buat kelas
- Buat mapel
- Buat paket
- Buat akun siswa
- Buat akun guru

### Siswa
- Login
- Pastikan profil siswa muncul
- Hubungkan ke paket
- Pastikan Drill muncul
- Kerjakan Kuis
- Kerjakan Tryout

### Guru
- Login
- Pastikan siswa terlihat
- Buat pertemuan
- Isi absensi
- Buat materi
- Buat kuis dan drill sesuai jadwal/program

### Laporan
- Pastikan nilai masuk
- Pastikan PDF dapat dibuat
- Pastikan tombol WhatsApp menghasilkan chat link

## 15. Hal yang tidak boleh dilakukan

- Jangan menaruh `service_role` key di GitHub.
- Jangan mengedit database setiap hari untuk membuat siswa/guru.
- Jangan memberikan `answer_key` kepada frontend siswa.
- Jangan menghapus tabel produksi hanya untuk mencoba fitur.

## 16. Hasil akhir yang diharapkan

Setelah setup awal selesai, pekerjaan rutin dapat dilakukan dari web:

**Tambah akun → tambah data → buat paket → masukkan siswa ke paket → buat materi → buat soal → publish → siswa mengerjakan → sistem menilai → admin/guru melihat monitoring → laporan PDF/WhatsApp.**

