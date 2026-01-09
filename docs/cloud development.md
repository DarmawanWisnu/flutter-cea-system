# 🚀 Panduan Deployment ke Cloud (Gratis)

Panduan detail untuk deploy CEA Hydroponic System ke cloud gratis (Render + Supabase + HiveMQ).

**Estimasi waktu: 1-2 Hari**

---

## 📊 Analisis Penggunaan Free Tier

### Apakah Free Tier Cukup?

| Service | Free Tier Limit | Penggunaan Sistemmu | Status |
|---------|----------------|---------------------|--------|
| **Supabase (DB)** | 500 MB database | 9 tabel, ~1-5MB data | ✅ **SANGAT CUKUP** |
| **Render (API)** | 750 jam/bulan | 1 service = maks 720 jam | ✅ **CUKUP** |
| **HiveMQ (MQTT)** | 100 connections | 1-10 device + 1-10 user | ✅ **CUKUP** |

### Detail Penggunaan

#### Database (Supabase)
```
9 Tabel:
├── kits                 (~100 rows max untuk skripsi)
├── user_kits            (~100 rows)
├── telemetry            (~10,000 rows/minggu, bisa auto-cleanup)
├── actuator_event       (~5,000 rows/minggu)
├── actuator_cooldown    (~10 rows per device)
├── ml_prediction_log    (~5,000 rows/minggu)
├── device_mode          (~50 rows)
├── user_preference      (~50 rows)
└── notifications        (~1,000 rows/minggu)

Estimasi: 50-100 MB untuk 1 bulan (500 MB = LEBIH DARI CUKUP)
```

#### API Endpoints (Render)
```
25 Endpoints:
├── /health (1)
├── /kits/* (6)
├── /telemetry/* (3)
├── /device/* (3)
├── /user/* (2)
├── /notifications/* (5)
├── /actuator/* (4)
└── /ml/predict (1)
```

#### MQTT Topics
```
2 Topic patterns:
├── kit/{deviceId}/telemetry (Subscribe)
└── kit/{deviceId}/control (Publish)

Connections untuk skripsi: ~5-10 (WELL UNDER 100 limit)
```

---

## 🛠️ Langkah-langkah Deployment

### FASE 1: Setup Cloud Services (30-60 menit)

#### 1.1 Setup Supabase (PostgreSQL)

**Step 1:** Buka https://supabase.com dan klik "Start your project"

**Step 2:** Sign up dengan GitHub (gratis, tidak butuh kartu kredit)

**Step 3:** Klik "New Project" dan isi:
- Organization: (pilih yang sudah ada atau buat baru)
- Name: `cea-hydroponic`
- Database Password: (CATAT PASSWORD INI!)
- Region: **Southeast Asia (Singapore)** ← pilih yang terdekat
- Klik "Create new project"

**Step 4:** Tunggu ~2 menit untuk provisioning

**Step 5:** Setelah selesai, pergi ke **Settings** → **Database** → Scroll ke "Connection string"
- Salin connection string format: `postgresql://postgres:[PASSWORD]@db.xxx.supabase.co:5432/postgres`
- Atau catat:
  ```
  Host: db.xxx.supabase.co
  Port: 5432
  Database: postgres
  User: postgres
  Password: (yang kamu set tadi)
  ```

---

#### 1.2 Setup HiveMQ Cloud (MQTT Broker)

**Step 1:** Buka https://www.hivemq.com/cloud/ dan klik "Try out for free"

**Step 2:** Sign up (gratis, tidak butuh kartu kredit)

**Step 3:** Setelah login, kamu akan lihat dashboard dengan cluster gratis

**Step 4:** Klik cluster → pergi ke tab "Overview", catat:
```
Cluster URL: xxx.hivemq.cloud
Port: 8883 (TLS)
```

**Step 5:** Pergi ke tab "Access Management" → "Create Credentials"
- Username: `cea-user`
- Password: (buat password, CATAT!)
- Klik "Add"

---

#### 1.3 Deploy Backend ke Render

**Step 1:** Buka https://render.com dan klik "Get Started for Free"

**Step 2:** Sign up dengan GitHub

**Step 3:** SEBELUM DEPLOY, kamu perlu buat file `requirements.txt` di `services/api/`:
```txt
fastapi==0.109.0
uvicorn[standard]==0.27.0
psycopg2-binary==2.9.9
python-dotenv==1.0.0
pydantic==2.5.3
requests==2.31.0
httpx==0.26.0
scikit-learn==1.4.0
joblib==1.3.2
numpy==1.26.3
```

**Step 4:** Push perubahan ke GitHub

**Step 5:** Di Render dashboard, klik "New" → "Web Service"

**Step 6:** Connect GitHub repository → pilih `flutter-cea-system`

**Step 7:** Configure service:
```
Name: cea-api
Root Directory: services/api
Runtime: Python 3
Build Command: pip install -r requirements.txt
Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
Instance Type: Free
```

**Step 8:** Scroll ke "Environment Variables" dan tambahkan:
```
DATABASE_URL = postgresql://postgres:[PASSWORD]@db.xxx.supabase.co:5432/postgres
MQTT_BROKER = xxx.hivemq.cloud
MQTT_PORT = 8883
MQTT_USERNAME = cea-user
MQTT_PASSWORD = (password HiveMQ)
API_BASE_URL = https://cea-api.onrender.com
ML_PREDICT_URL = https://cea-api.onrender.com/ml/predict
```

**Step 9:** Klik "Create Web Service" dan tunggu deploy (~5-10 menit)

**Step 10:** Setelah selesai, test dengan buka: `https://cea-api.onrender.com/health`
- Harus return: `{"status": "ok", "message": "Server is running"}`

---

### FASE 2: Update Kode Backend (15-30 menit)

#### 2.1 Buat requirements.txt

Buat file baru: `services/api/requirements.txt`

```txt
fastapi==0.109.0
uvicorn[standard]==0.27.0
psycopg2-binary==2.9.9
python-dotenv==1.0.0
pydantic==2.5.3
requests==2.31.0
httpx==0.26.0
scikit-learn==1.4.0
joblib==1.3.2
numpy==1.26.3
```

---

#### 2.2 Update database.py untuk Support DATABASE_URL

Edit `services/api/database.py`, tambahkan di bawah `load_dotenv()`:

```python
# === ORIGINAL (LOCAL EMULATOR) ===
# DB_HOST = os.getenv("DB_HOST", "localhost")
# DB_NAME = os.getenv("DB_NAME", "fountaine")
# DB_USER = os.getenv("DB_USER", "postgres")
# DB_PASSWORD = os.getenv("DB_PASSWORD", "")
# DB_PORT = int(os.getenv("DB_PORT", "5432"))

# === PRODUCTION (CLOUD DEPLOYMENT) ===
# Support both individual variables and DATABASE_URL
DATABASE_URL = os.getenv("DATABASE_URL")
if DATABASE_URL:
    import urllib.parse
    result = urllib.parse.urlparse(DATABASE_URL)
    DB_HOST = result.hostname
    DB_NAME = result.path[1:]  # Remove leading slash
    DB_USER = result.username
    DB_PASSWORD = urllib.parse.unquote(result.password) if result.password else ""
    DB_PORT = result.port or 5432
else:
    # Fallback to individual env vars (for local development)
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_NAME = os.getenv("DB_NAME", "fountaine")
    DB_USER = os.getenv("DB_USER", "postgres")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "")
    DB_PORT = int(os.getenv("DB_PORT", "5432"))
```

---

### FASE 3: Update Flutter App (15-30 menit)

#### 3.1 Buat .env untuk Production

Buat file baru: `apps/mobile/.env`

```env
# === PRODUCTION CONFIG ===
API_BASE_URL=https://cea-api.onrender.com
MQTT_HOST=xxx.hivemq.cloud
MQTT_PORT=8883
MQTT_USERNAME=cea-user
MQTT_PASSWORD=your_hivemq_password

# === LOCAL EMULATOR CONFIG (uncomment untuk testing lokal) ===
# API_BASE_URL=http://10.0.2.2:8000
# MQTT_HOST=10.0.2.2
# MQTT_PORT=1883
# MQTT_USERNAME=
# MQTT_PASSWORD=
```

---

#### 3.2 Update constants.dart untuk TLS Support

Edit `apps/mobile/lib/core/constants.dart`:

```dart
class MqttConst {
  static String get host => dotenv.env['MQTT_HOST'] ?? '10.0.2.2';
  static int get port => int.tryParse(dotenv.env['MQTT_PORT'] ?? '1883') ?? 1883;
  static String get username => dotenv.env['MQTT_USERNAME'] ?? '';
  static String get password => dotenv.env['MQTT_PASSWORD'] ?? '';
  static String get clientPrefix => dotenv.env['MQTT_CLIENT_PREFIX'] ?? 'hydro-app-';
  
  // === ORIGINAL (LOCAL) ===
  // static const bool tls = false;
  
  // === PRODUCTION (CLOUD) - Enable TLS for HiveMQ ===
  static bool get tls => port == 8883;  // Auto-detect TLS based on port
  
  static String tControl(String kitId) => "kit/$kitId/control";
}
```

---

#### 3.3 Tambahkan .env ke assets

Edit `apps/mobile/pubspec.yaml`, pastikan ada:

```yaml
flutter:
  assets:
    - .env
```

---

### FASE 4: Build & Distribute APK (15-30 menit)

#### 4.1 Build Release APK

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build apk --release
```

Output APK: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`

---

#### 4.2 Upload ke GitHub Releases

**Step 1:** Di GitHub, pergi ke repository → "Releases" → "Create a new release"

**Step 2:** Isi:
- Tag: `v1.0.0`
- Title: `CEA Hydroponic v1.0.0`
- Description:
  ```
  ## Download
  Download APK dan install di Android.
  
  ## Cara Install
  1. Download file APK
  2. Buka file APK
  3. Izinkan install dari unknown sources
  4. Install dan buka app
  ```

**Step 3:** Drag & drop file `app-release.apk` ke area "Attach binaries"

**Step 4:** Klik "Publish release"

---

#### 4.3 Generate QR Code

**Step 1:** Salin link APK dari GitHub Release:
```
https://github.com/[username]/[repo]/releases/download/v1.0.0/app-release.apk
```

**Step 2:** Buka https://qr-code-generator.com atau https://goqr.me

**Step 3:** Paste link → Generate → Download QR code

**Step 4:** Masukkan QR code ke presentasi/laporan skripsi

---

## ✅ Checklist Verification

Setelah deploy, test berikut:

- [ ] `https://cea-api.onrender.com/health` → return `{"status": "ok"}`
- [ ] `https://cea-api.onrender.com/kits/all` → return `[]` atau list kits
- [ ] Download APK via QR code → berhasil install
- [ ] Buka app → bisa connect ke backend (tidak error)
- [ ] Test add kit → data masuk ke Supabase
- [ ] Test monitor → real-time telemetry via MQTT

---

## ⚠️ Catatan Penting

### Cold Start (Render Free Tier)
- Service akan **sleep setelah 15 menit tidak aktif**
- Request pertama setelah sleep butuh **30-60 detik**
- Ini normal untuk free tier

### Database Expiry (Supabase Free Tier)
- Database akan **pause setelah 7 hari tidak aktif**
- Bisa di-resume manual dari dashboard
- Data tidak hilang

### Switching Antara Local dan Production
- Comment/uncomment config di `.env`
- Rebuild APK untuk production

---

## 📞 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| App tidak bisa connect | Cek URL di `.env` sudah benar |
| MQTT tidak connect | Pastikan port 8883 dan TLS enabled |
| Database error | Cek DATABASE_URL di Render env vars |
| Cold start lambat | Normal untuk free tier, tunggu 30-60 detik |
