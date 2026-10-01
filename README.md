# TRIPLE-F EDUCATION LMS

LMS bimbingan belajar berbasis GitHub Pages + Supabase + Google Drive.

## Modul

- Dashboard Admin/Guru/Siswa
- Authentication
- Pembuatan akun Admin/Guru/Siswa dari web
- Data siswa dan guru
- Kelas, mata pelajaran, paket
- Paket siswa + periode aktif
- Pertemuan
- Materi + upload Google Drive
- Absensi Hadir/Izin/Sakit/Alpa
- Kuis + bank soal + pilihan jawaban
- Tryout + bank soal + timer
- Drill soal harian + target hari efektif
- Penilaian server-side
- Tagihan
- Laporan hasil belajar
- PDF laporan
- WhatsApp laporan
- Monitoring aktivitas
- Responsive Android/iPhone/tablet/laptop/desktop

## Stack

Frontend statis: HTML/CSS/JavaScript ES modules.

Backend: Supabase Auth + PostgreSQL + RLS + RPC security-definer.

File: Google Drive melalui Google Apps Script.

## Setup

Ikuti `SETUP.md` dari atas sampai bawah.

## Security

Jangan pernah commit `service_role` key.

Siswa tidak membaca `answer_key` secara langsung. Pengerjaan dan penilaian memakai RPC Supabase.

## Struktur

```text
triple-f-education-lms/
├── index.html
├── login.html
├── dashboard.html
├── js/
├── css/
├── assets/
├── supabase_schema.sql
├── supabase/functions/manage-user/index.ts
└── google-apps-script/Code.gs
```


## Perubahan versi dashboard
- Tampilan dashboard mengikuti model LMS modern dengan kartu statistik, aktivitas, quick action dan layout responsif.
- Siswa menampilkan **nama sekolah, kelas, paket aktif dan jadwal hariannya**.
- Ditambahkan modul **Jadwal Paket**: paket + kelas + mapel + guru + hari + jam + ruangan/link.
- Guru melihat **Jadwal Mengajar** dan menu **Presensi** hanya berdasarkan jadwal guru.
- Presensi siswa diambil dari siswa aktif pada **paket dan kelas** yang sesuai jadwal.
- Guru **tidak lagi memiliki menu Tryout untuk membuat/mengelola Tryout**; guru membuat **Kuis yang wajib terhubung dengan jadwal sesi**.
- Admin tetap dapat mengelola Tryout bila fitur simulasi tetap digunakan.
