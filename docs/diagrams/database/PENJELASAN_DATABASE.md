# Perancangan Database

## Logical Database Design

Pada tahap ini penulis melakukan perancangan terhadap database untuk aplikasi Fountaine Hydroponic Monitoring secara *logical*. *Logical database design* merupakan proses membangun model data yang digunakan dalam database berdasarkan model data tertentu, tetapi tanpa bergantung pada desain DBMS tertentu dan pertimbangan fisik lainnya (Begg, 2005). Proses ini berfokus pada struktur logis data, termasuk entitas, atribut, dan hubungan antar data, untuk memastikan bahwa data dapat digambarkan sebelum diterapkan dalam sistem manajemen basis data (DBMS) tertentu.

---

## Penjelasan Diagram

Pada gambar di atas, dihasilkan **8 (delapan) entitas** pada perancangan database untuk aplikasi Fountaine Hydroponic Monitoring. Entitas tersebut meliputi **kits**, **telemetry**, **actuator_event**, **actuator_cooldown**, **ml_prediction_log**, **device_mode**, **user_preference**, dan **notifications**.

Pada masing-masing entitas memiliki *primary key* dan atribut. *Primary key* digunakan untuk merujuk pada tabel yang lainnya atau untuk dijadikan sebagai *foreign key* pada tabel lainnya agar tabel lain dapat mengakses data yang dibutuhkan pada entitas awal atau saling berelasi.

---

## Deskripsi Entitas

### 1. Tabel `kits`
Tabel ini menyimpan data kit hidroponik yang terdaftar dalam sistem. Setiap kit memiliki ID unik yang menjadi referensi utama untuk seluruh data telemetry dan aktuator.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | TEXT | Primary Key, ID unik kit |
| name | TEXT | Nama kit hidroponik |
| createdAt | TIMESTAMPTZ | Waktu pendaftaran kit |

---

### 2. Tabel `telemetry`
Tabel ini menyimpan data sensor yang dikirim secara berkala dari perangkat IoT. Data mencakup parameter lingkungan hidroponik seperti pH, PPM, suhu, kelembaban, dan level air.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| rowId | TEXT | Primary Key, ID unik record |
| deviceId | TEXT | Foreign Key ke tabel kits |
| ingestTime | BIGINT | Timestamp penerimaan data (Unix epoch) |
| payloadJson | JSONB | Data JSON mentah dari sensor |
| ppm | FLOAT | Nilai kepekatan nutrisi (Part Per Million) |
| ph | FLOAT | Nilai keasaman larutan |
| tempC | FLOAT | Suhu udara dalam Celsius |
| humidity | FLOAT | Kelembaban udara dalam persen |
| waterTemp | FLOAT | Suhu air dalam Celsius |
| waterLevel | FLOAT | Level ketinggian air (0-3) |
| payloadHash | TEXT | Hash unik untuk deduplikasi data |

---

### 3. Tabel `actuator_event`
Tabel ini menyimpan riwayat aktivasi aktuator, baik secara manual maupun otomatis. Data ini digunakan untuk monitoring dan analisis performa sistem kontrol.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key, auto-increment |
| deviceId | TEXT | Foreign Key ke tabel kits |
| ingestTime | BIGINT | Timestamp kejadian |
| phUp | INT | Durasi aktivasi pompa pH Up (detik) |
| phDown | INT | Durasi aktivasi pompa pH Down (detik) |
| nutrientAdd | INT | Durasi aktivasi pompa nutrisi (detik) |
| valueS | FLOAT | Nilai prediksi durasi dari ML |
| manual | INT | Flag mode manual (1/0) |
| auto | INT | Flag mode otomatis (1/0) |
| refill | INT | Durasi aktivasi refill air (detik) |

---

### 4. Tabel `actuator_cooldown`
Tabel ini menyimpan informasi *cooldown* aktuator untuk mencegah aktivasi berlebihan dalam waktu singkat.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| deviceId | TEXT | Foreign Key ke tabel kits |
| actionType | TEXT | Jenis aksi (phUp, phDown, nutrient, refill) |
| lastTime | BIGINT | Waktu aktivasi terakhir |
| lastValue | FLOAT | Nilai terakhir saat aktivasi |

---

### 5. Tabel `ml_prediction_log`
Tabel ini menyimpan log prediksi dari model *Machine Learning* untuk keperluan audit dan evaluasi performa model.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| deviceId | TEXT | Foreign Key ke tabel kits |
| predictTime | BIGINT | Waktu prediksi dilakukan |
| payloadJson | JSONB | Data input untuk prediksi |
| predictJson | JSONB | Hasil prediksi dari model ML |

---

### 6. Tabel `device_mode`
Tabel ini menyimpan preferensi mode kontrol (Auto/Manual) per pengguna per perangkat.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| userId | TEXT | ID pengguna dari Firebase Auth |
| deviceId | TEXT | Foreign Key ke tabel kits |
| autoMode | BOOLEAN | True = Auto, False = Manual |
| updatedAt | TIMESTAMPTZ | Waktu perubahan terakhir |

---

### 7. Tabel `user_preference`
Tabel ini menyimpan preferensi pengguna, termasuk kit yang sedang dipilih/aktif.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| userId | TEXT | ID pengguna (Unique) |
| selectedKitId | TEXT | Foreign Key ke tabel kits |
| updatedAt | TIMESTAMPTZ | Waktu perubahan terakhir |

---

### 8. Tabel `notifications`
Tabel ini menyimpan notifikasi yang dihasilkan sistem berdasarkan kondisi sensor yang menyimpang dari *threshold*.

| Kolom | Tipe Data | Keterangan |
|-------|-----------|------------|
| id | SERIAL | Primary Key |
| userId | TEXT | ID pengguna tujuan notifikasi |
| deviceId | TEXT | Foreign Key ke tabel kits |
| level | TEXT | Tingkat urgensi (info, warning, urgent) |
| title | TEXT | Judul notifikasi |
| message | TEXT | Isi pesan notifikasi |
| isRead | BOOLEAN | Status sudah dibaca atau belum |
| createdAt | TIMESTAMPTZ | Waktu pembuatan notifikasi |

---

## Relasi Antar Tabel

Tabel **kits** menjadi entitas utama yang berelasi dengan seluruh tabel lainnya melalui kolom `deviceId`. Relasi yang terbentuk adalah *one-to-many* di mana satu kit dapat memiliki banyak data telemetry, actuator event, cooldown record, ML prediction log, device mode setting, dan notifications. Relasi *one-to-one* terbentuk antara **user_preference** dan **kits** di mana satu user hanya dapat memiliki satu kit yang dipilih pada satu waktu.

---

## Tabel Endpoint API Aplikasi Fountaine Hydroponic Monitoring

Berikut adalah daftar endpoint REST API yang tersedia pada backend aplikasi **Fountaine Hydroponic Monitoring**:

| No | Endpoint | Method | Body / Parameters |
|----|----------|--------|-------------------|
| 1 | `/health` | GET | - |
| 2 | `/kits` | POST | `id`, `name` |
| 3 | `/kits` | GET | - |
| 4 | `/kits/{kit_id}` | GET | `kit_id` (path) |
| 5 | `/kits/with-latest` | GET | - |
| 6 | `/kits/{kit_id}` | DELETE | `kit_id` (path) |
| 7 | `/telemetry?deviceId=` | POST | `deviceId` (query), `ppm`, `ph`, `tempC`, `humidity`, `waterTemp`, `waterLevel` |
| 8 | `/telemetry/latest?deviceId=` | GET | `deviceId` (query) |
| 9 | `/telemetry/history?deviceId=` | GET | `deviceId`, `days`, `limit` (query) |
| 10 | `/device/mode` | POST | `userId`, `deviceId`, `autoMode` |
| 11 | `/device/mode?userId=&deviceId=` | GET | `userId`, `deviceId` (query) |
| 12 | `/device/auto-enabled` | GET | - |
| 13 | `/user/preference` | POST | `userId`, `selectedKitId` |
| 14 | `/user/preference?userId=` | GET | `userId` (query) |
| 15 | `/notifications` | POST | `userId`, `deviceId`, `level`, `title`, `message` |
| 16 | `/notifications?userId=` | GET | `userId`, `level`, `days`, `limit` (query) |
| 17 | `/notifications/{notification_id}/read` | PUT | `notification_id` (path) |
| 18 | `/notifications/mark-all-read?userId=` | PUT | `userId` (query) |
| 19 | `/notifications/{notification_id}` | DELETE | `notification_id` (path) |
| 20 | `/notifications?userId=` | DELETE | `userId` (query) |
| 21 | `/actuator/event?deviceId=` | POST | `deviceId` (query), `phUp`, `phDown`, `nutrientAdd`, `valueS`, `manual`, `auto`, `refill` |
| 22 | `/actuator/latest?deviceId=` | GET | `deviceId` (query) |
| 23 | `/actuator/history?deviceId=` | GET | `deviceId`, `limit` (query) |
| 24 | `/actuator/all?deviceId=` | GET | `deviceId` (query) |
| 25 | `/ml/predict` | POST | `ppm`, `ph`, `tempC`, `humidity`, `waterTemp`, `waterLevel` |

### Keterangan Endpoint

- **Health Check** (`/health`): Endpoint untuk memeriksa konektivitas server.
- **Kits CRUD**: Endpoint untuk mengelola data kit hidroponik (Create, Read, Update, Delete).
- **Telemetry**: Endpoint untuk menyimpan dan mengambil data sensor secara berkala.
- **Device Mode**: Endpoint untuk mengatur mode kontrol (Auto/Manual) per perangkat.
- **User Preference**: Endpoint untuk menyimpan preferensi pengguna seperti kit yang dipilih.
- **Notifications**: Endpoint untuk mengelola notifikasi sistem.
- **Actuator**: Endpoint untuk mencatat dan mengambil riwayat aktivasi aktuator.
- **ML Predict**: Endpoint untuk mendapatkan prediksi durasi aktuator dari model Machine Learning.
