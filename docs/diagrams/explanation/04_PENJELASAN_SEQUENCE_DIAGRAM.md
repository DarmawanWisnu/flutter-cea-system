# Penjelasan Sequence Diagram

## Deskripsi Umum

Sequence Diagram untuk aplikasi **Fountaine Hydroponic Monitoring** menggambarkan interaksi antar objek (aktor, komponen UI, service, dan sistem eksternal) dalam urutan waktu untuk menyelesaikan suatu skenario use case. Diagram ini menunjukkan pesan yang dikirim antar objek beserta urutan pemanggilannya.

---

## Daftar Sequence Diagram

| No | Nama Diagram | File | Deskripsi |
|----|--------------|------|-----------|
| 1 | Sequence Diagram Login | `sequence_login.puml` | Urutan interaksi untuk proses login |
| 2 | Sequence Diagram Register | `sequence_register.puml` | Urutan interaksi untuk proses registrasi |
| 3 | Sequence Diagram Add Kit | `sequence_addkit.puml` | Urutan interaksi untuk menambah kit |
| 4 | Sequence Diagram History | `sequence_history.puml` | Urutan interaksi untuk melihat history |
| 5 | Sequence Diagram Monitor | `sequence_monitor.puml` | Urutan interaksi untuk monitoring real-time |
| 6 | Sequence Diagram Notification | `sequence_notification.puml` | Urutan interaksi untuk mengelola notifikasi |

---

## Partisipan (Participants)

| Partisipan | Keterangan |
|------------|------------|
| **User** | Aktor pengguna aplikasi |
| **Screen / Form** | Komponen UI Flutter (StatefulWidget/Screen) |
| **Provider / VM** | State management layer (Riverpod Provider / ViewModel) |
| **Service** | Layer service untuk komunikasi dengan eksternal sistem |
| **Backend REST API** | Server Python FastAPI untuk data persistence |
| **Firebase Auth** | Layanan autentikasi Google Firebase |
| **MQTT Broker** | HiveMQ Cloud untuk komunikasi real-time |

---

## Notasi yang Digunakan

| Notasi | Nama | Arti |
|--------|------|------|
| `→` | Synchronous Message | Pesan sinkron menunggu respons |
| `-->` | Return Message | Pesan balasan/respons |
| `activate` | Activation Bar | Objek sedang aktif memproses |
| `loop` | Loop Fragment | Pengulangan aksi |
| `alt` | Alternative Fragment | Percabangan kondisional |
| `opt` | Optional Fragment | Eksekusi opsional |

---

## 1. Sequence Diagram Login

Gambar di atas menampilkan urutan untuk melakukan *login* yang dapat dilakukan oleh User. Dimulai ketika aktor membuka aplikasi maka akan mengarah pada form *login*. Aktor mengisi *email* dan *password*, sistem meneruskan data yang diinputkan untuk dicek ke Firebase Auth. Jika data tidak valid maka akan menampilkan pesan *error* kepada aktor, dan jika data berhasil divalidasi maka akan mengarahkan aktor pada menu *home* aplikasi.

### Partisipan
- User → Login Screen → AuthService → Firebase Auth

### Alur Interaksi

```
User                    Login Screen         AuthService         Firebase Auth
  │                           │                    │                    │
  │ Membuka aplikasi          │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │         Tampilkan form    │                    │                    │
  │<──────────────────────────│                    │                    │
  │                           │                    │                    │
  │ Input email & password    │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │ Klik tombol Login         │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │                           │ signIn(email, pw)  │                    │
  │                           │───────────────────>│                    │
  │                           │                    │                    │
  │                           │                    │signInWithEmail()   │
  │                           │                    │───────────────────>│
  │                           │                    │                    │
  │                           │                    │ UserCredential      │
  │                           │                    │<───────────────────│
  │                           │                    │                    │
  │                           │ User object        │                    │
  │                           │<───────────────────│                    │
  │                           │                    │                    │
  │  Navigate to Home Screen  │                    │                    │
  │<──────────────────────────│                    │                    │
```

### Skenario Alternatif
- **Kredensial tidak valid**: Firebase Auth mengembalikan error, Login Screen menampilkan pesan error
- **Email belum terverifikasi**: Navigate ke halaman verifikasi email

---

## 2. Sequence Diagram Register

Gambar di atas menampilkan urutan untuk melakukan registrasi akun baru. Dimulai ketika aktor membuka halaman *register* dan mengisi form email beserta password. Sistem meneruskan data ke Firebase Auth untuk membuat akun baru. Jika registrasi berhasil, sistem akan mengirim email verifikasi dan mengarahkan aktor ke halaman verifikasi. Jika gagal, sistem menampilkan pesan *error*.

### Partisipan
- User → Register Screen → AuthService → Firebase Auth

### Alur Interaksi

```
User                   Register Screen       AuthService         Firebase Auth
  │                           │                    │                    │
  │ Buka halaman register     │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │ Input email, password,    │                    │                    │
  │ confirm password          │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │ Klik tombol Register      │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │                           │ Validasi format    │                    │
  │                           │ (password match)   │                    │
  │                           │                    │                    │
  │                           │ register(email,pw) │                    │
  │                           │───────────────────>│                    │
  │                           │                    │                    │
  │                           │                    │createUserWithEmail()
  │                           │                    │───────────────────>│
  │                           │                    │                    │
  │                           │                    │ UserCredential      │
  │                           │                    │<───────────────────│
  │                           │                    │                    │
  │                           │                    │sendEmailVerification()
  │                           │                    │───────────────────>│
  │                           │                    │                    │
  │                           │ Success            │                    │
  │                           │<───────────────────│                    │
  │                           │                    │                    │
  │  Navigate to Verification │                    │                    │
  │<──────────────────────────│                    │                    │
```

---

## 3. Sequence Diagram Tambah Kit

Gambar di atas menampilkan urutan untuk menambahkan kit hidroponik baru. Dimulai ketika aktor membuka halaman tambah kit dan mengisi ID serta nama kit. Sistem melakukan validasi data dan mengirimkan request ke Backend REST API untuk menyimpan data. Jika berhasil, sistem menampilkan notifikasi sukses dan mengarahkan ke halaman *home*. Jika gagal, sistem menampilkan pesan *error*.

### Partisipan
- User → Add Kit Screen → ApiKitsService → Backend REST API

### Alur Interaksi

```
User                   Add Kit Screen      ApiKitsService     Backend REST API
  │                           │                    │                    │
  │ Buka halaman Add Kit      │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │ Tampilkan form            │                    │                    │
  │<──────────────────────────│                    │                    │
  │                           │                    │                    │
  │ Input Kit ID & Nama       │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │ Klik Simpan               │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │                           │ Validasi input     │                    │
  │                           │ (not empty)        │                    │
  │                           │                    │                    │
  │                           │ addKit(id, name,   │                    │
  │                           │        userId)     │                    │
  │                           │───────────────────>│                    │
  │                           │                    │                    │
  │                           │                    │ POST /kits         │
  │                           │                    │ {id, name, userId} │
  │                           │                    │───────────────────>│
  │                           │                    │                    │
  │                           │                    │ 201 Created        │
  │                           │                    │<───────────────────│
  │                           │                    │                    │
  │                           │ Success            │                    │
  │                           │<───────────────────│                    │
  │                           │                    │                    │
  │  Tampilkan notifikasi     │                    │                    │
  │  "Kit berhasil ditambahkan"                    │                    │
  │<──────────────────────────│                    │                    │
  │                           │                    │                    │
  │  Navigate to Home Screen  │                    │                    │
  │<──────────────────────────│                    │                    │
```

---

## 4. Sequence Diagram History

Gambar di atas menampilkan urutan untuk melihat riwayat data sensor. Dimulai ketika aktor membuka halaman *history*, sistem mengambil data dari Backend REST API berdasarkan kit yang dipilih. Data sensor ditampilkan dalam bentuk *list* yang mencakup pH, PPM, Temperature, dan parameter lainnya. Aktor dapat memilih filter waktu atau tanggal tertentu untuk menampilkan data spesifik.

### Partisipan
- User → History Screen → ApiService → Backend REST API

### Alur Interaksi

```
User                   History Screen        ApiService       Backend REST API
  │                           │                    │                    │
  │ Buka halaman History      │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │                           │ getHistory(kitId,  │                    │
  │                           │            days)   │                    │
  │                           │───────────────────>│                    │
  │                           │                    │                    │
  │                           │                    │GET /telemetry/     │
  │                           │                    │history?deviceId=   │
  │                           │                    │───────────────────>│
  │                           │                    │                    │
  │                           │                    │ List<Telemetry>    │
  │                           │                    │<───────────────────│
  │                           │                    │                    │
  │                           │ List<Telemetry>    │                    │
  │                           │<───────────────────│                    │
  │                           │                    │                    │
  │  Tampilkan data history   │                    │                    │
  │<──────────────────────────│                    │                    │
  │                           │                    │                    │
  │                           │                    │                    │
  │ Pilih filter waktu        │                    │                    │
  │ (1 jam / 6 jam / semua)   │                    │                    │
  │──────────────────────────>│                    │                    │
  │                           │                    │                    │
  │                           │ Filter data lokal  │                    │
  │                           │                    │                    │
  │  Tampilkan hasil filter   │                    │                    │
  │<──────────────────────────│                    │                    │
```

---

## 5. Sequence Diagram Monitor

Gambar di atas menampilkan urutan untuk melakukan monitoring sensor secara *real-time*. Dimulai ketika aktor membuka halaman monitor, sistem menginisialisasi koneksi MQTT dan *subscribe* ke topic telemetry. Data sensor diterima secara *real-time* dan ditampilkan pada dashboard. Aktor dapat memilih mode Auto atau Manual, serta dapat menekan tombol kontrol untuk mengaktifkan aktuator saat mode Manual.

### Partisipan
- User → Monitor Screen → MqttVM → MqttService → MQTT Broker
- User → Monitor Screen → ApiService → Backend REST API

### Alur Interaksi (Lebih Kompleks)

```
User              Monitor Screen      MqttVM        MQTT Broker    Backend API
  │                    │                │                │              │
  │ Buka Monitor       │                │                │              │
  │───────────────────>│                │                │              │
  │                    │                │                │              │
  │                    │ init()         │                │              │
  │                    │───────────────>│                │              │
  │                    │                │                │              │
  │                    │                │ connect()      │              │
  │                    │                │───────────────>│              │
  │                    │                │                │              │
  │                    │                │ Connected      │              │
  │                    │                │<───────────────│              │
  │                    │                │                │              │
  │                    │                │ subscribe()    │              │
  │                    │                │ "kit/+/telemetry"             │
  │                    │                │ "kit/+/status" │              │
  │                    │                │───────────────>│              │
  │                    │                │                │              │
  │                    │                │                │              │
  │                    │ loadAutoMode() │                │              │
  │                    │───────────────>│                │              │
  │                    │                │                │              │
  │                    │                │ GET /device/mode              │
  │                    │                │─────────────────────────────>│
  │                    │                │                │              │
  │                    │                │ {autoMode: bool}             │
  │                    │                │<─────────────────────────────│
  │                    │                │                │              │
  │                    │ Auto mode state│                │              │
  │                    │<───────────────│                │              │
  │                    │                │                │              │
  │                    │                │                │              │
  ═══════════════════════════ LOOP: Real-time data ═══════════════════════
  │                    │                │                │              │
  │                    │                │ Telemetry data │              │
  │                    │                │<───────────────│              │
  │                    │                │                │              │
  │                    │ notifyListeners()              │              │
  │                    │<───────────────│                │              │
  │                    │                │                │              │
  │  Update UI sensor  │                │                │              │
  │<───────────────────│                │                │              │
  │                    │                │                │              │
  ═══════════════════════════════════════════════════════════════════════
  │                    │                │                │              │
  │ Toggle Auto/Manual │                │                │              │
  │───────────────────>│                │                │              │
  │                    │                │                │              │
  │                    │ setAutoMode()  │                │              │
  │                    │───────────────>│                │              │
  │                    │                │                │              │
  │                    │                │ POST /device/mode             │
  │                    │                │─────────────────────────────>│
  │                    │                │                │              │
  │                    │                │ Success        │              │
  │                    │                │<─────────────────────────────│
  │                    │                │                │              │
  ═══════════════════════════ ALT: Manual Mode ═══════════════════════════
  │                    │                │                │              │
  │ Tekan tombol kontrol               │                │              │
  │ (pH Up/Down, etc.) │                │                │              │
  │───────────────────>│                │                │              │
  │                    │                │                │              │
  │                    │                │ POST /actuator/event         │
  │                    │─────────────────────────────────────────────>│
  │                    │                │                │              │
  │                    │                │ Response (durations)         │
  │                    │<─────────────────────────────────────────────│
  │                    │                │                │              │
  │                    │ publishActuator()              │              │
  │                    │───────────────>│                │              │
  │                    │                │                │              │
  │                    │                │ Publish to     │              │
  │                    │                │ "kit/{id}/control"           │
  │                    │                │───────────────>│              │
  │                    │                │                │              │
  ═══════════════════════════════════════════════════════════════════════
```

### Poin Kunci
- Menggunakan 2 protokol: REST API untuk data persistence, MQTT untuk real-time
- Loop fragment menunjukkan streaming data telemetry yang terus-menerus
- Alt fragment menunjukkan skenario khusus mode Manual

---

## 6. Sequence Diagram Notification

Gambar di atas menampilkan urutan untuk melihat dan mengelola notifikasi. Proses pembuatan notifikasi berjalan di *background* saat data sensor menyimpang dari *threshold*. Ketika aktor membuka halaman notifikasi, sistem mengambil daftar notifikasi dari Backend REST API. Aktor dapat memilih filter berdasarkan level dan menandai notifikasi sebagai sudah dibaca.

### Partisipan
- User → Notification Screen → NotificationListNotifier → ApiService → Backend REST API

### Alur Interaksi

```
User              Notification Screen    Notifier      ApiService    Backend API
  │                    │                    │              │              │
  │ Buka Notification  │                    │              │              │
  │───────────────────>│                    │              │              │
  │                    │                    │              │              │
  │                    │ fetchNotifications()             │              │
  │                    │───────────────────>│              │              │
  │                    │                    │              │              │
  │                    │                    │getNotifications()          │
  │                    │                    │─────────────>│              │
  │                    │                    │              │              │
  │                    │                    │              │GET /notifications
  │                    │                    │              │─────────────>│
  │                    │                    │              │              │
  │                    │                    │              │ List<Notif>  │
  │                    │                    │              │<─────────────│
  │                    │                    │              │              │
  │                    │                    │ List<Notif>  │              │
  │                    │                    │<─────────────│              │
  │                    │                    │              │              │
  │                    │ State updated      │              │              │
  │                    │<───────────────────│              │              │
  │                    │                    │              │              │
  │  Tampilkan list    │                    │              │              │
  │<───────────────────│                    │              │              │
  │                    │                    │              │              │
  │ Tekan notifikasi   │                    │              │              │
  │───────────────────>│                    │              │              │
  │                    │                    │              │              │
  │                    │ markRead(id)       │              │              │
  │                    │───────────────────>│              │              │
  │                    │                    │              │              │
  │                    │                    │              │PUT /notifications
  │                    │                    │              │/{id}/read    │
  │                    │                    │              │─────────────>│
  │                    │                    │              │              │
  │  Tampilkan detail  │                    │              │              │
  │<───────────────────│                    │              │              │
```

---

## Ringkasan Pola Interaksi

| Sequence Diagram | Pola Utama | Partner Eksternal |
|------------------|------------|-------------------|
| Login | Request-Response | Firebase Auth |
| Register | Request-Response + Email | Firebase Auth |
| Add Kit | Request-Response | Backend REST API |
| History | Request-Response + Filter | Backend REST API |
| Monitor | Publish-Subscribe + Request | MQTT Broker + Backend |
| Notification | Request-Response + Update | Backend REST API |
