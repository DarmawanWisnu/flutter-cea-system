# Perancangan Database (Entity Relationship Diagram)

## Logical Database Design

Pada tahap ini penulis melakukan perancangan terhadap database untuk aplikasi Fountaine Hydroponic Monitoring secara *logical*. *Logical database design* merupakan proses membangun model data yang digunakan dalam database berdasarkan model data tertentu, tetapi tanpa bergantung pada desain DBMS tertentu dan pertimbangan fisik lainnya (Begg, 2005). Proses ini berfokus pada struktur logis data, termasuk entitas, atribut, dan hubungan antar data, untuk memastikan bahwa data dapat digambarkan sebelum diterapkan dalam sistem manajemen basis data (DBMS) tertentu.

---

## Penjelasan Diagram

Diagram database (`database_diagram.puml`) menggambarkan **9 (sembilan) entitas** pada perancangan database untuk aplikasi Fountaine Hydroponic Monitoring:

### Daftar Entitas

| No | Entitas | Keterangan |
|----|---------|------------|
| 1 | `kits` | Registry global kit hidroponik |
| 2 | `telemetry` | Data sensor yang dikirim dari perangkat IoT |
| 3 | `actuator_event` | Riwayat aktivasi aktuator (pompa pH, nutrisi, refill) |
| 4 | `actuator_cooldown` | Tracking waktu cooldown per aksi aktuator |
| 5 | `device_mode` | Mode kontrol (Auto/Manual) per user per device |
| 6 | `user_preference` | Preferensi user (kit yang sedang dipilih) |
| 7 | `notifications` | Notifikasi sistem untuk user |
| 8 | `ml_prediction_log` | Log prediksi dari model Machine Learning |
| 9 | `user_kits` | Relasi many-to-many antara user dan kit |

### Notasi Diagram

| Simbol | Arti |
|--------|------|
| `<<PK>>` | **Primary Key** - Identifier unik untuk setiap record, tidak boleh duplikat |
| `<<FK>>` | **Foreign Key** - Referensi ke tabel lain, menciptakan relasi |
| `<<UNIQUE>>` | **Constraint Unique** - Nilai kolom tidak boleh duplikat dalam tabel |
| `\|\|--o{` | **One-to-Many** - Satu record di tabel kiri berhubungan dengan banyak record di tabel kanan |
| `\|\|--o\|` | **One-to-One** - Satu record di tabel kiri berhubungan dengan maksimal satu record di tabel kanan |

### Hubungan Antar Entitas

```
kits (1) ──────< telemetry (*)         : Satu kit memiliki banyak data telemetry
kits (1) ──────< actuator_event (*)    : Satu kit memiliki banyak event aktuator
kits (1) ──────< actuator_cooldown (*) : Satu kit memiliki banyak record cooldown
kits (1) ──────< device_mode (*)       : Satu kit bisa diakses oleh banyak user
kits (1) ──────o user_preference (1)   : Satu kit bisa dipilih oleh satu user
kits (1) ──────< notifications (*)     : Satu kit memiliki banyak notifikasi
kits (1) ──────< ml_prediction_log (*) : Satu kit memiliki banyak log prediksi
kits (1) ──────< user_kits (*)         : Satu kit bisa dimiliki banyak user
```

Pada masing-masing entitas memiliki *primary key* dan atribut. *Primary key* digunakan untuk merujuk pada tabel yang lainnya atau untuk dijadikan sebagai *foreign key* pada tabel lainnya agar tabel lain dapat mengakses data yang dibutuhkan pada entitas awal atau saling berelasi.

---

## Deskripsi Entitas

### 1. Tabel `kits`

**Fungsi**: Tabel registry utama untuk semua kit hidroponik dalam sistem. Setiap IoT device harus terdaftar di tabel ini sebelum dapat mengirim data.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | TEXT | Primary Key - ID unik kit (format: alphanumeric) |
| name | TEXT | Nama kit yang diberikan oleh user |
| createdAt | TIMESTAMPTZ | Waktu pendaftaran kit ke sistem |

**Relasi**: Tabel ini menjadi *parent table* untuk hampir semua tabel lain melalui kolom `deviceId` atau `kitId`.

---

### 2. Tabel `telemetry`

**Fungsi**: Menyimpan data sensor yang dikirim secara berkala (setiap 30 detik) dari ESP32 melalui MQTT. Data ini mencakup semua parameter lingkungan hidroponik.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| rowId | TEXT | Primary Key - ID unik berbasis UUID |
| deviceId | TEXT | Foreign Key ke tabel `kits` |
| ingestTime | BIGINT | Unix timestamp (epoch seconds) saat data diterima |
| payloadJson | JSONB | Data JSON mentah dari sensor |
| ppm | FLOAT | Nilai kepekatan nutrisi (Part Per Million), range: 0-3000 |
| ph | FLOAT | Nilai keasaman larutan, range: 0-14 |
| tempC | FLOAT | Suhu udara dalam Celsius |
| humidity | FLOAT | Kelembaban udara dalam persen (0-100) |
| waterTemp | FLOAT | Suhu air nutrisi dalam Celsius |
| waterLevel | FLOAT | Level ketinggian air (0=Kosong, 1=Low, 2=Medium, 3=Full) |
| payloadHash | TEXT | Hash SHA-256 untuk deduplikasi data |

**Deduplikasi**: Kolom `payloadHash` dengan constraint UNIQUE mencegah penyimpanan data identik berulang.

---

### 3. Tabel `actuator_event`

**Fungsi**: Menyimpan log setiap aktivasi aktuator, baik dari mode Manual (trigger user) maupun mode Auto (trigger sistem berdasarkan threshold atau ML).

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key - Auto-increment |
| deviceId | TEXT | Foreign Key ke tabel `kits` |
| ingestTime | BIGINT | Unix timestamp saat event terjadi |
| phUp | INT | Durasi aktivasi pompa pH Up dalam detik |
| phDown | INT | Durasi aktivasi pompa pH Down dalam detik |
| nutrientAdd | INT | Durasi aktivasi pompa nutrisi dalam detik |
| valueS | FLOAT | Nilai prediksi durasi dari model ML (jika ada) |
| refill | INT | Durasi aktivasi pompa refill air dalam detik |
| manual | INT | Flag mode manual (1 = Manual, 0 = Auto) |
| auto | INT | Flag mode otomatis (1 = Auto, 0 = Manual) |

**Catatan**: Kolom `manual` dan `auto` bersifat mutually exclusive (hanya salah satu yang bernilai 1).

---

### 4. Tabel `actuator_cooldown`

**Fungsi**: Mengimplementasikan mekanisme *cooldown* untuk mencegah aktivasi aktuator berlebihan dalam waktu singkat. Setiap jenis aksi memiliki record tersendiri.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| deviceId | TEXT | Foreign Key ke tabel `kits` |
| actionType | TEXT | Jenis aksi: `phUp`, `phDown`, `nutrient`, atau `refill` |
| lastTime | BIGINT | Unix timestamp aktivasi terakhir |
| lastValue | FLOAT | Nilai parameter saat aktivasi terakhir (untuk evaluasi) |

**Cooldown Period**: Default 60 detik per action type per device.

---

### 5. Tabel `ml_prediction_log`

**Fungsi**: Menyimpan log prediksi dari model *Machine Learning* untuk keperluan audit dan evaluasi performa model.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| deviceId | TEXT | Foreign Key ke tabel `kits` |
| predictTime | BIGINT | Unix timestamp saat prediksi dilakukan |
| payloadJson | JSONB | Data input sensor yang digunakan untuk prediksi |
| predictJson | JSONB | Hasil prediksi model (durasi aktuator yang disarankan) |

---

### 6. Tabel `device_mode`

**Fungsi**: Menyimpan preferensi mode kontrol per kombinasi user-device. Memungkinkan user yang berbeda memiliki setting mode berbeda untuk kit yang sama.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| userId | TEXT | ID user dari Firebase Auth |
| deviceId | TEXT | Foreign Key ke tabel `kits` |
| autoMode | BOOLEAN | TRUE = Mode Auto, FALSE = Mode Manual |
| updatedAt | TIMESTAMPTZ | Waktu perubahan terakhir |

**Unique Constraint**: Kombinasi `(userId, deviceId)` bersifat unik.

---

### 7. Tabel `user_preference`

**Fungsi**: Menyimpan preferensi user, utamanya kit yang sedang dipilih/aktif untuk ditampilkan di dashboard.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| userId | TEXT | ID user (UNIQUE - satu user satu preference) |
| selectedKitId | TEXT | Foreign Key ke tabel `kits` |
| updatedAt | TIMESTAMPTZ | Waktu perubahan terakhir |

---

### 8. Tabel `notifications`

**Fungsi**: Menyimpan notifikasi yang dihasilkan sistem ketika kondisi sensor menyimpang dari threshold atau saat aktuator diaktifkan.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| userId | TEXT | ID user tujuan notifikasi |
| deviceId | TEXT | Foreign Key ke tabel `kits` |
| level | TEXT | Tingkat urgensi: `info`, `warning`, atau `urgent` |
| title | TEXT | Judul notifikasi |
| message | TEXT | Isi pesan detail |
| isRead | BOOLEAN | Status sudah dibaca (TRUE/FALSE) |
| createdAt | TIMESTAMPTZ | Waktu pembuatan notifikasi |

---

### 9. Tabel `user_kits`

**Fungsi**: Menyimpan relasi *many-to-many* antara user dan kit. Memungkinkan satu user memiliki banyak kit, dan satu kit dapat diakses oleh banyak user.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| userId | TEXT | Primary Key (composite) - ID user dari Firebase Auth |
| kitId | TEXT | Primary Key (composite) + Foreign Key ke tabel `kits` |
| addedAt | TIMESTAMPTZ | Waktu penambahan kit ke user |

---

## Relasi Antar Tabel

Tabel **kits** menjadi entitas utama yang berelasi dengan seluruh tabel lainnya melalui kolom `deviceId` atau `kitId`. Relasi yang terbentuk adalah *one-to-many* di mana satu kit dapat memiliki banyak data telemetry, actuator event, cooldown record, ML prediction log, device mode setting, notifications, dan user_kits. Tabel **user_kits** memungkinkan relasi *many-to-many* di mana satu user dapat memiliki banyak kit, dan satu kit dapat dimiliki oleh banyak user. Relasi *one-to-one* terbentuk antara **user_preference** dan **kits** di mana satu user hanya dapat memiliki satu kit yang dipilih pada satu waktu.

### Diagram Relasi

```
                    ┌──────────────────────────────────────────┐
                    │                 KITS                     │
                    │              (Parent Table)              │
                    └─────────────────────┬────────────────────┘
                                          │
        ┌─────────────┬─────────────┬─────┴────┬─────────────┬─────────────┐
        │             │             │          │             │             │
        ▼             ▼             ▼          ▼             ▼             ▼
   telemetry    actuator_event  device_mode  notifications  ml_log     user_kits
   (1:many)     (1:many)        (1:many)     (1:many)       (1:many)   (1:many)
        │             │
        ▼             ▼
 actuator_cooldown  user_preference
   (1:many)          (1:one)
```

---

## Kunci Utama Desain

1. **Normalisasi**: Setiap tabel memiliki tanggung jawab spesifik tanpa redundansi data.
2. **Scalability**: Penggunaan SERIAL untuk auto-increment ID memudahkan penambahan data.
3. **Audit Trail**: Tabel `ingestTime` dan `createdAt` memungkinkan tracking temporal.
4. **Deduplikasi**: Hash payload mencegah data duplikat masuk ke database.
5. **Flexibility**: Desain many-to-many (`user_kits`) mendukung sharing kit antar user.

---

## Tabel Endpoint API

Berikut adalah daftar endpoint REST API yang tersedia pada backend aplikasi **Fountaine Hydroponic Monitoring**:

| No | Endpoint | Method | Body / Parameters |
|----|----------|--------|-------------------|
| 1 | `/health` | GET | - |
| 2 | `/kits` | POST | `id`, `name`, `userId` |
| 3 | `/kits?userId=` | GET | `userId` (query) |
| 4 | `/kits/all` | GET | - |
| 5 | `/kits/{kit_id}` | GET | `kit_id` (path) |
| 6 | `/kits/with-latest?userId=` | GET | `userId` (query) |
| 7 | `/kits/{kit_id}?userId=` | DELETE | `kit_id` (path), `userId` (query) |
| 8 | `/telemetry?deviceId=` | POST | `deviceId` (query), `ppm`, `ph`, `tempC`, `humidity`, `waterTemp`, `waterLevel` |
| 9 | `/telemetry/latest?deviceId=` | GET | `deviceId` (query) |
| 10 | `/telemetry/history?deviceId=` | GET | `deviceId`, `days`, `limit` (query) |
| 11 | `/device/mode` | POST | `userId`, `deviceId`, `autoMode` |
| 12 | `/device/mode?userId=&deviceId=` | GET | `userId`, `deviceId` (query) |
| 13 | `/device/auto-enabled` | GET | - |
| 14 | `/user/preference` | POST | `userId`, `selectedKitId` |
| 15 | `/user/preference?userId=` | GET | `userId` (query) |
| 16 | `/notifications` | POST | `userId`, `deviceId`, `level`, `title`, `message` |
| 17 | `/notifications?userId=` | GET | `userId`, `level`, `days`, `limit` (query) |
| 18 | `/notifications/{notification_id}/read` | PUT | `notification_id` (path) |
| 19 | `/notifications/mark-all-read?userId=` | PUT | `userId` (query) |
| 20 | `/notifications/{notification_id}` | DELETE | `notification_id` (path) |
| 21 | `/notifications?userId=` | DELETE | `userId` (query) |
| 22 | `/actuator/event?deviceId=` | POST | `deviceId` (query), `phUp`, `phDown`, `nutrientAdd`, `valueS`, `manual`, `auto`, `refill` |
| 23 | `/actuator/latest?deviceId=` | GET | `deviceId` (query) |
| 24 | `/actuator/history?deviceId=` | GET | `deviceId`, `limit` (query) |
| 25 | `/actuator/all?deviceId=` | GET | `deviceId` (query) |
| 26 | `/ml/predict` | POST | `ppm`, `ph`, `tempC`, `humidity`, `waterTemp`, `waterLevel` |

### Keterangan Endpoint

- **Health Check** (`/health`): Endpoint untuk memeriksa konektivitas server.
- **Kits CRUD**: Endpoint untuk mengelola data kit hidroponik (Create, Read, Update, Delete).
- **Telemetry**: Endpoint untuk menyimpan dan mengambil data sensor secara berkala.
- **Device Mode**: Endpoint untuk mengatur mode kontrol (Auto/Manual) per perangkat.
- **User Preference**: Endpoint untuk menyimpan preferensi pengguna seperti kit yang dipilih.
- **Notifications**: Endpoint untuk mengelola notifikasi sistem.
- **Actuator**: Endpoint untuk mencatat dan mengambil riwayat aktivasi aktuator.
- **ML Predict**: Endpoint untuk mendapatkan prediksi durasi aktuator dari model Machine Learning.
