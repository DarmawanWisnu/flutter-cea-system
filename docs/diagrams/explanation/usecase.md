# Penjelasan Use Case Diagram

## Deskripsi Umum

Use Case Diagram untuk aplikasi **Fountaine Hydroponic Monitoring** menggambarkan interaksi antara aktor (User) dengan sistem. Diagram ini menunjukkan berbagai fungsionalitas yang dapat diakses oleh pengguna dalam aplikasi monitoring hidroponik.

---

## Aktor dalam Sistem

| Aktor | Deskripsi |
|-------|-----------|
| **User** | Pengguna aplikasi yang telah terautentikasi melalui Firebase Auth. User dapat mengakses semua fitur aplikasi setelah login. |

---

## Daftar Use Case

### Kategori: Authentication (Auth)

| ID | Use Case | Deskripsi |
|----|----------|-----------|
| UC_Login | Login | User melakukan autentikasi dengan email dan password untuk mengakses aplikasi |
| UC_Register | Register | User mendaftarkan akun baru dengan email dan password |
| UC_Logout | Logout | User keluar dari sesi aplikasi dan menghapus kredensial tersimpan |

---

### Kategori: Features (Fitur Utama)

| ID | Use Case | Deskripsi |
|----|----------|-----------|
| UC_Sensor | Lihat Data Sensor | User melihat data sensor terkini (pH, PPM, Temperature, dll) pada dashboard |
| UC_Monitor | Monitor Real-Time | User memonitor kondisi hidroponik secara real-time melalui koneksi MQTT |
| UC_AddKit | Tambah Kit Baru | User menambahkan perangkat IoT hidroponik baru ke dalam sistem |
| UC_Control | Kendali Pompa | User mengontrol aktuator (pompa pH, nutrisi, refill) secara manual |
| UC_Notify | Lihat Notifikasi | User melihat dan mengelola notifikasi sistem tentang kondisi sensor |
| UC_History | Lihat History | User melihat riwayat data sensor untuk periode tertentu |
| UC_Settings | Settings | User mengatur konfigurasi aplikasi (URL backend, preferensi) |
| UC_Profile | Profile | User melihat dan mengelola profil akun (email, password reset) |

---

## Relasi Include

Semua use case dalam kategori **Features** memiliki relasi `<<include>>` dengan use case **Login**. Artinya:

> **User harus login terlebih dahulu sebelum dapat mengakses fitur apapun dalam aplikasi.**

```
┌─────────────────────────────────────────────────────────────────┐
│                    RELASI INCLUDE                               │
├─────────────────────────────────────────────────────────────────┤
│  Lihat Data Sensor  ──────────────┐                             │
│  Monitor Real-Time  ──────────────┤                             │
│  Tambah Kit Baru    ──────────────┤                             │
│  Kendali Pompa      ──────────────┼───>> include >>─── LOGIN    │
│  Lihat Notifikasi   ──────────────┤                             │
│  Lihat History      ──────────────┤                             │
│  Settings           ──────────────┤                             │
│  Profile            ──────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Penjelasan Detail Setiap Use Case

### 1. Login (UC_Login)

Gambar di atas menampilkan use case untuk melakukan *login* yang dapat dilakukan oleh User. Proses dimulai ketika aktor membuka aplikasi dan mengisi form *login* dengan email dan password. Sistem memvalidasi kredensial melalui Firebase Auth dan mengarahkan aktor ke halaman utama jika berhasil.

**Aktor**: User

**Deskripsi**: Use case ini memungkinkan user untuk masuk ke dalam sistem menggunakan kredensial yang telah terdaftar.

**Pre-condition**:
- User sudah memiliki akun terdaftar
- Aplikasi terkoneksi ke internet

**Main Flow**:
1. User membuka aplikasi
2. Sistem menampilkan form login (email + password)
3. User memasukkan kredensial
4. Sistem memvalidasi format input
5. Sistem mengirim request ke Firebase Auth
6. Firebase memverifikasi kredensial
7. Sistem mengarahkan user ke Home Screen

**Post-condition**: User berhasil login dan dapat mengakses fitur aplikasi

---

### 2. Register (UC_Register)

Gambar di atas menampilkan use case untuk mendaftarkan akun baru. Aktor mengisi form registrasi dengan email, password, dan konfirmasi password. Sistem membuat akun baru di Firebase Auth dan mengirimkan email verifikasi untuk mengaktifkan akun.

**Aktor**: User

**Deskripsi**: Use case ini memungkinkan user baru untuk mendaftarkan akun ke dalam sistem.

**Pre-condition**:
- Email belum terdaftar di sistem
- Aplikasi terkoneksi ke internet

**Main Flow**:
1. User memilih opsi "Daftar"
2. Sistem menampilkan form registrasi
3. User mengisi email, password, dan konfirmasi password
4. Sistem memvalidasi format dan kecocokan password
5. Sistem mengirim request ke Firebase Auth untuk membuat akun
6. Firebase mengirim email verifikasi
7. Sistem mengarahkan user ke halaman verifikasi email

**Post-condition**: Akun baru terbuat dan email verifikasi terkirim

---

### 3. Lihat Data Sensor (UC_Sensor)

Gambar di atas menampilkan use case untuk melihat data sensor hidroponik. Aktor dapat melihat parameter lingkungan terkini seperti pH, PPM, Temperature, Humidity, Water Level, dan Water Temperature dari kit yang dipilih.

**Aktor**: User (harus login)

**Deskripsi**: User dapat melihat data sensor terkini dari kit hidroponik yang dipilih.

**Data yang Ditampilkan**:
- pH (Keasaman)
- PPM (Part Per Million - Kepekatan Nutrisi)
- Temperature (Suhu Udara)
- Humidity (Kelembaban Udara)
- Water Temperature (Suhu Air)
- Water Level (0-3)

---

### 4. Monitor Real-Time (UC_Monitor)

Gambar di atas menampilkan use case untuk memonitor kondisi hidroponik secara *real-time*. Aktor dapat melihat data sensor yang diperbarui setiap 30 detik melalui koneksi MQTT, memilih mode Auto/Manual, dan mengontrol aktuator saat mode Manual aktif.

**Aktor**: User (harus login)

**Deskripsi**: User dapat memonitor kondisi hidroponik secara real-time dengan data yang diperbarui setiap 30 detik melalui protokol MQTT.

**Fitur**:
- Tampilan dashboard sensor real-time
- Status koneksi kit (Online/Offline)
- Switch mode Auto/Manual
- Tombol kontrol manual (jika mode Manual aktif)

---

### 5. Tambah Kit Baru (UC_AddKit)

Gambar di atas menampilkan use case untuk menambahkan perangkat IoT hidroponik baru. Aktor mengisi Kit ID dan Nama Kit, sistem memvalidasi data dan menyimpan ke Backend REST API.

**Aktor**: User (harus login)

**Deskripsi**: User dapat menambahkan perangkat IoT hidroponik baru ke dalam akun mereka.

**Input**:
- Kit ID (harus unik)
- Nama Kit

**Validasi**:
- Kit ID tidak kosong
- Kit ID belum terdaftar di sistem
- Nama Kit tidak kosong

---

### 6. Kendali Pompa (UC_Control)

Gambar di atas menampilkan use case untuk mengontrol aktuator secara manual. Saat mode Manual diaktifkan, aktor dapat menekan tombol pH Up, pH Down, Nutrient Add, atau Refill untuk mengaktifkan pompa terkait.

**Aktor**: User (harus login)

**Deskripsi**: User dapat mengontrol aktuator secara manual ketika mode Manual diaktifkan.

**Aktuator yang Dapat Dikontrol**:
| Aktuator | Fungsi |
|----------|--------|
| pH Up | Menambah larutan basa untuk menaikkan pH |
| pH Down | Menambah larutan asam untuk menurunkan pH |
| Nutrient Add | Menambah larutan nutrisi untuk menaikkan PPM |
| Refill | Mengisi air ke tangki reservoir |

---

### 7. Lihat Notifikasi (UC_Notify)

Gambar di atas menampilkan use case untuk melihat dan mengelola notifikasi sistem. Aktor dapat melihat daftar notifikasi yang dikelompokkan berdasarkan level urgensi, memfilter notifikasi, dan menandai sebagai sudah dibaca.

**Aktor**: User (harus login)

**Deskripsi**: User dapat melihat dan mengelola notifikasi yang dihasilkan sistem.

**Fitur**:
- Filter berdasarkan level (All, Warning, Urgent)
- Tandai notifikasi sebagai sudah dibaca
- Hapus notifikasi individual atau semua
- Navigate ke History dari notifikasi

---

### 8. Lihat History (UC_History)

Gambar di atas menampilkan use case untuk melihat riwayat data sensor. Aktor dapat memilih filter waktu (1 jam, 6 jam, Semua) atau tanggal spesifik untuk melihat data sensor pada periode tertentu.

**Aktor**: User (harus login)

**Deskripsi**: User dapat melihat riwayat data sensor untuk periode tertentu.

**Filter yang Tersedia**:
- 1 Jam terakhir
- 6 Jam terakhir
- Semua data
- Tanggal spesifik

---

## Diagram Alur Akses

```
                    ┌─────────┐
                    │  USER   │
                    └────┬────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌────────┐      ┌────────┐      ┌────────┐
    │ Login  │      │Register│      │ Logout │
    └────┬───┘      └────────┘      └────────┘
         │
         │ << include >>
         │
         ▼
    ┌────────────────────────────────────┐
    │         PROTECTED FEATURES         │
    ├────────────────────────────────────┤
    │ • Lihat Data Sensor                │
    │ • Monitor Real-Time                │
    │ • Tambah Kit Baru                  │
    │ • Kendali Pompa                    │
    │ • Lihat Notifikasi                 │
    │ • Lihat History                    │
    │ • Settings                         │
    │ • Profile                          │
    └────────────────────────────────────┘
```

---

## Catatan Desain

1. **Single Actor**: Sistem menggunakan satu aktor (User) karena tidak ada pembedaan role (admin, guest, dll).
2. **Authentication Barrier**: Semua fitur utama dilindungi oleh autentikasi Firebase.
3. **Simplicity**: Use case diagram dibuat sederhana tanpa extend relationship untuk memperjelas fokus utama sistem.
