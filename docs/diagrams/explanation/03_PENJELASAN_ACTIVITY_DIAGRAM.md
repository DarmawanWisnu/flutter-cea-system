# Penjelasan Activity Diagram

## Deskripsi Umum

Activity Diagram untuk aplikasi **Fountaine Hydroponic Monitoring** menggambarkan alur aktivitas (workflow) yang dilakukan oleh aktor dan sistem dalam menyelesaikan suatu use case. Diagram ini menggunakan notasi *swimlane* untuk membedakan aktivitas User dan Sistem.

---

## Daftar Activity Diagram

| No | Nama Diagram | File | Deskripsi |
|----|--------------|------|-----------|
| 1 | Activity Diagram Login | `activity_login.puml` | Alur aktivitas untuk login pengguna |
| 2 | Activity Diagram Register | `activity_register.puml` | Alur aktivitas untuk registrasi akun baru |
| 3 | Activity Diagram Add Kit | `activity_addkit.puml` | Alur aktivitas untuk menambah kit hidroponik |
| 4 | Activity Diagram History | `activity_history.puml` | Alur aktivitas untuk melihat riwayat sensor |
| 5 | Activity Diagram Monitor | `activity_monitor.puml` | Alur aktivitas untuk monitoring real-time |
| 6 | Activity Diagram Notification | `activity_notification.puml` | Alur aktivitas untuk mengelola notifikasi |

---

## Notasi yang Digunakan

| Simbol | Nama | Fungsi |
|--------|------|--------|
| ⚫ (filled circle) | Initial Node | Titik awal aktivitas |
| ⊙ (circle with dot) | Final Node | Titik akhir aktivitas |
| ▭ (rounded rectangle) | Activity | Satu unit pekerjaan/aksi |
| ◇ (diamond) | Decision Node | Percabangan berdasarkan kondisi |
| ═══ (horizontal bar) | Fork/Join | Aktivitas paralel |
| \|Lane\| | Swimlane | Pemisah domain aktor (User/Sistem) |

---

## 1. Activity Diagram Login

Gambar di atas menampilkan aktivitas yang dilakukan oleh semua aktor untuk *login*. Dimulai dengan aktor mengakses halaman *login*, kemudian sistem menampilkan form *login*. Aktor mengisi email dan password lalu menekan tombol Login. Sistem melakukan validasi format input terlebih dahulu. Jika format valid, sistem mengirimkan request ke Firebase Auth untuk memverifikasi kredensial. Apabila kredensial valid dan email sudah diverifikasi, maka sistem akan menampilkan halaman utama aplikasi (Home Screen). Namun jika email belum diverifikasi, aktor akan diarahkan ke halaman verifikasi email. Jika kredensial tidak valid, sistem akan menampilkan pesan error dan aktor kembali ke halaman *login*.

### Gambaran Umum
Menggambarkan proses autentikasi user menggunakan email dan password melalui Firebase Authentication.

### Alur Aktivitas

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SWIMLANE                            │
├─────────────────────────────────────────────────────────────────┤
│  [Start] → Akses halaman login → Input email & password         │
│           → Klik tombol Login                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       SISTEM SWIMLANE                           │
├─────────────────────────────────────────────────────────────────┤
│  Menampilkan form login → Validasi format input                 │
│           │                                                     │
│           ▼                                                     │
│  [Format valid?]                                                │
│     ├─ Ya → Kirim request ke Firebase Auth                      │
│     │         │                                                 │
│     │         ▼                                                 │
│     │      [Kredensial valid?]                                  │
│     │         ├─ Ya → Navigate ke Home Screen [End]             │
│     │         └─ Tidak → Tampilkan pesan error                  │
│     │                    → Kembali ke halaman login             │
│     │                                                           │
│     └─ Tidak → Tampilkan pesan "Format tidak valid"             │
│                → Kembali ke halaman login                       │
└─────────────────────────────────────────────────────────────────┘
```

### Poin Kunci
- Validasi dilakukan dalam 2 tahap: format lokal, lalu kredensial Firebase
- Error handling mengembalikan user ke form login
- Tidak ada limit percobaan login (tergantung kebijakan Firebase)

---

## 2. Activity Diagram Register

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk mendaftarkan akun baru. Proses dimulai dengan aktor mengakses halaman *register*, kemudian sistem menampilkan form registrasi. Aktor mengisi email, password, dan konfirmasi password, lalu menekan tombol Register. Sistem melakukan validasi format input dan mencocokkan password dengan konfirmasi password. Jika semua valid, sistem mengirimkan request ke Firebase Auth untuk membuat akun baru. Apabila registrasi berhasil, sistem akan mengirimkan email verifikasi dan menampilkan halaman verifikasi email. Jika registrasi gagal (misalnya email sudah terdaftar atau password terlalu lemah), sistem akan menampilkan pesan error dan aktor kembali ke form *register*.

### Gambaran Umum
Menggambarkan proses pendaftaran akun baru dengan validasi email dan verifikasi melalui Firebase.

### Alur Aktivitas

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SWIMLANE                            │
├─────────────────────────────────────────────────────────────────┤
│  [Start] → Akses halaman register                               │
│          → Input email, password, konfirmasi password           │
│          → Klik tombol Register                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       SISTEM SWIMLANE                           │
├─────────────────────────────────────────────────────────────────┤
│  Menampilkan form registrasi                                    │
│          → Validasi format input                                │
│          → Cek kecocokan password dengan konfirmasi             │
│          │                                                      │
│          ▼                                                      │
│  [Valid?]                                                       │
│     ├─ Ya → Create account di Firebase Auth                     │
│     │         │                                                 │
│     │         ▼                                                 │
│     │      [Berhasil?]                                          │
│     │         ├─ Ya → Kirim email verifikasi                    │
│     │         │       → Navigate ke halaman verifikasi [End]    │
│     │         └─ Tidak → Tampilkan pesan error                  │
│     │                    (email sudah terdaftar, password lemah)│
│     │                                                           │
│     └─ Tidak → Tampilkan pesan error format                     │
└─────────────────────────────────────────────────────────────────┘
```

### Poin Kunci
- Password harus cocok dengan konfirmasi
- Firebase memiliki kebijakan password minimum
- Email verifikasi wajib sebelum dapat login

---

## 3. Activity Diagram Add Kit

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk menambahkan kit hidroponik baru. Proses dimulai dengan aktor mengakses halaman Add Kit, kemudian sistem menampilkan form input data kit. Aktor mengisi ID kit dan nama kit, lalu menekan tombol Simpan. Sistem melakukan validasi data input untuk memastikan ID dan nama tidak kosong. Jika data valid, sistem mengirimkan request ke Backend REST API untuk menyimpan data kit baru. Apabila penyimpanan berhasil, sistem menampilkan notifikasi "Kit berhasil ditambahkan" dan mengarahkan aktor ke halaman Home Screen. Jika penyimpanan gagal (misalnya ID kit sudah terdaftar atau terjadi *network error*), sistem akan menampilkan pesan error dan aktor kembali ke form Add Kit.

### Gambaran Umum
Menggambarkan proses penambahan perangkat IoT hidroponik baru ke dalam akun user.

### Alur Aktivitas

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SWIMLANE                            │
├─────────────────────────────────────────────────────────────────┤
│  [Start] → Akses halaman Add Kit                                │
│          → Input Kit ID dan Nama Kit                            │
│          → Klik tombol Simpan                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       SISTEM SWIMLANE                           │
├─────────────────────────────────────────────────────────────────┤
│  Menampilkan form input data kit                                │
│          → Validasi data (ID & nama tidak kosong)               │
│          │                                                      │
│          ▼                                                      │
│  [Data valid?]                                                  │
│     ├─ Ya → POST /kits ke Backend REST API                      │
│     │         │                                                 │
│     │         ▼                                                 │
│     │      [Berhasil?]                                          │
│     │         ├─ Ya → Tampilkan notifikasi sukses               │
│     │         │       → Navigate ke Home Screen [End]           │
│     │         └─ Tidak → Tampilkan pesan error                  │
│     │                    (Kit ID sudah ada, network error)      │
│     │                                                           │
│     └─ Tidak → Tampilkan pesan "Data tidak lengkap"             │
└─────────────────────────────────────────────────────────────────┘
```

### Poin Kunci
- Kit ID bersifat unik secara global
- Sistem melakukan validasi duplikasi di backend
- Setelah sukses, daftar kit otomatis terupdate

---

## 4. Activity Diagram History

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk melihat riwayat data sensor. Proses dimulai dengan aktor mengakses halaman History. Sistem mengambil kitId dari *shared state*, menampilkan *loading indicator*, dan melakukan request data history ke Backend REST API. Jika data tersedia, sistem menampilkan *list* data sensor yang mencakup pH, PPM, Temperature, dan Water Level. Jika tidak ada data, sistem menampilkan pesan "Tidak ada data". Aktor dapat memilih filter waktu (1 jam, 6 jam, atau Semua) dan sistem akan melakukan filter data secara lokal. Aktor juga dapat memilih tanggal tertentu, di mana sistem akan melakukan request data untuk tanggal terpilih ke Backend API dan menampilkan hasilnya.

### Gambaran Umum
Menggambarkan proses melihat riwayat data sensor dengan berbagai opsi filter.

### Alur Aktivitas

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SWIMLANE                            │
├─────────────────────────────────────────────────────────────────┤
│  [Start] → Akses halaman History                                │
│          → (Optional) Pilih filter waktu                        │
│          → (Optional) Pilih tanggal spesifik                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       SISTEM SWIMLANE                           │
├─────────────────────────────────────────────────────────────────┤
│  Ambil kitId dari shared state                                  │
│          → Tampilkan loading indicator                          │
│          → GET /telemetry/history dari Backend API              │
│          │                                                      │
│          ▼                                                      │
│  [Data tersedia?]                                               │
│     ├─ Ya → Tampilkan list data sensor                          │
│     │       (pH, PPM, Temperature, Water Level)                 │
│     │                                                           │
│     └─ Tidak → Tampilkan pesan "Tidak ada data"                 │
│                                                                 │
│  [User pilih filter waktu?]                                     │
│     └─ Ya → Filter data secara lokal                            │
│             (1 jam, 6 jam, Semua)                               │
│                                                                 │
│  [User pilih tanggal?]                                          │
│     └─ Ya → GET /telemetry/history dengan parameter tanggal     │
│             → Tampilkan hasil [End]                             │
└─────────────────────────────────────────────────────────────────┘
```

### Poin Kunci
- Filter waktu dilakukan secara lokal (client-side)
- Filter tanggal memerlukan request baru ke backend
- Data ditampilkan dalam format list dengan timestamp

---

## 5. Activity Diagram Monitor

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk memonitor data sensor secara *real-time*. Proses dimulai dengan aktor mengakses halaman Monitor Screen. Sistem melakukan inisialisasi koneksi MQTT, *subscribe* ke topic telemetry dan status, serta memuat status mode otomatis dari Backend API. Sistem menampilkan nilai sensor *real-time* yang mencakup pH, PPM, Temperature, Humidity, Water Level, dan Water Temp, beserta status mode kontrol (Auto/Manual). Aktor dapat memilih mode kontrol dan sistem menyimpan preferensi ke Backend API. Jika mode Manual dipilih, sistem menampilkan tombol kontrol manual (pH Up, pH Down, Nutrient A, Nutrient B, Refill). Ketika aktor menekan tombol kontrol, sistem akan mempublikasikan perintah ke MQTT Broker. Jika mode Auto dipilih, Backend menjalankan kontrol otomatis berdasarkan *threshold* parameter dan mengirimkan hasil via MQTT.

### Gambaran Umum
Menggambarkan proses monitoring sensor real-time dengan fitur kontrol mode Auto/Manual.

### Alur Aktivitas

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SWIMLANE                            │
├─────────────────────────────────────────────────────────────────┤
│  [Start] → Akses halaman Monitor Screen                         │
│          → Lihat data sensor pada dashboard                     │
│          → Pilih mode kontrol (Auto/Manual)                     │
│          → (Jika Manual) Tekan tombol kontrol aktuator          │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       SISTEM SWIMLANE                           │
├─────────────────────────────────────────────────────────────────┤
│  Inisialisasi koneksi MQTT                                      │
│          → Subscribe ke topic "kit/+/telemetry"                 │
│          → Subscribe ke topic "kit/+/status"                    │
│          → GET /device/mode dari Backend (load auto mode)       │
│          → Tampilkan nilai sensor real-time                     │
│          → Tampilkan status mode (Auto/Manual)                  │
│                                                                 │
│  [User ubah mode?]                                              │
│     └─ Ya → POST /device/mode ke Backend API                    │
│             → Simpan preferensi mode                            │
│                                                                 │
│  [Mode Manual?]                                                 │
│     ├─ Ya → Tampilkan tombol kontrol manual                     │
│     │       (pH Up, pH Down, Nutrient, Refill)                  │
│     │                                                           │
│     │       [User tekan tombol?]                                │
│     │          └─ Ya → POST /actuator/event ke Backend          │
│     │                  → Publish perintah ke MQTT Broker        │
│     │                  → Update tampilan status                 │
│     │                                                           │
│     └─ Tidak (Auto) → Backend jalankan kontrol otomatis         │
│                       → Berdasarkan threshold tiap 30 detik     │
│                       → Notifikasi dibuat otomatis              │
│                                                                 │
│  [Loop] → Memperbarui status sensor dari MQTT stream [End]      │
└─────────────────────────────────────────────────────────────────┘
```

### Poin Kunci
- Koneksi MQTT untuk data real-time
- Mode Auto: kontrol otomatis oleh backend berdasarkan threshold
- Mode Manual: kontrol melalui tombol UI
- Data sensor diperbarui setiap 30 detik

---

## 6. Activity Diagram Notification

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk melihat notifikasi. Proses dimulai dengan aktor mengakses halaman Notification. Sistem melakukan request daftar notifikasi dari Backend REST API. Jika ada notifikasi, sistem menampilkan daftar notifikasi di UI yang dikelompokkan berdasarkan level (Info, Warning, Urgent). Jika tidak ada notifikasi, sistem menampilkan pesan "Tidak ada notifikasi". Aktor dapat memilih filter (All, Warning, Urgent) dan sistem akan melakukan filter notifikasi berdasarkan level. Jika aktor menekan salah satu notifikasi, sistem menampilkan detail notifikasi dan menandai notifikasi tersebut sebagai telah dibaca melalui request ke Backend API. Aktor juga dapat menekan "Lihat di History" jika notifikasi terkait waktu tertentu, dan sistem akan mengarahkan ke halaman History dengan parameter *targetTime*.

### Gambaran Umum
Menggambarkan proses melihat dan mengelola notifikasi sistem.

### Alur Aktivitas

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SWIMLANE                            │
├─────────────────────────────────────────────────────────────────┤
│  [Start] → Akses halaman Notification                           │
│          → (Optional) Pilih filter level                        │
│          → (Optional) Tekan notifikasi untuk detail             │
│          → (Optional) Tekan "Lihat di History"                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       SISTEM SWIMLANE                           │
├─────────────────────────────────────────────────────────────────┤
│  GET /notifications dari Backend REST API                       │
│          │                                                      │
│          ▼                                                      │
│  [Ada notifikasi?]                                              │
│     ├─ Ya → Tampilkan daftar notifikasi                         │
│     │       → Kelompokkan berdasarkan level                     │
│     │       (Info, Warning, Urgent)                             │
│     │                                                           │
│     └─ Tidak → Tampilkan "Tidak ada notifikasi"                 │
│                                                                 │
│  [User pilih filter?]                                           │
│     └─ Ya → Filter notifikasi berdasarkan level                 │
│                                                                 │
│  [User tekan notifikasi?]                                       │
│     └─ Ya → Tampilkan detail notifikasi                         │
│             → PUT /notifications/{id}/read (tandai dibaca)      │
│                                                                 │
│  [User tekan "Lihat di History"?]                               │
│     └─ Ya → Navigate ke History dengan targetTime [End]         │
└─────────────────────────────────────────────────────────────────┘
```

### Poin Kunci
- Notifikasi dikelompokkan berdasarkan level urgensi
- Filter level: All, Warning, Urgent
- Tekan notifikasi otomatis menandai sebagai dibaca
- Navigasi ke History dengan parameter waktu

---

## Ringkasan Swimlane

| Activity Diagram | User Actions | Sistem Actions |
|------------------|--------------|----------------|
| Login | Input kredensial | Validasi format, Firebase Auth |
| Register | Input data registrasi | Validasi, Create account, Send email |
| Add Kit | Input Kit ID & nama | Validasi, POST ke Backend |
| History | Pilih filter | GET data, Filter lokal/API |
| Monitor | Toggle mode, Kontrol manual | MQTT sub/pub, POST actuator |
| Notification | Pilih filter, Lihat detail | GET notifikasi, PUT mark read |
