# 📱 Panduan Setup Aplikasi Flutter-CEA-System

Dokumentasi lengkap untuk menjalankan aplikasi di **HP Fisik** atau **Emulator Android**.

---

# 📌 BAGIAN 1: Setup untuk HP FISIK

> Gunakan bagian ini jika kamu mau install aplikasi di HP Android asli (tanpa USB).

## 🔧 File yang Perlu Dikonfigurasi

### 1. `apps/mobile/.env` - Flutter App
```env
MQTT_HOST=<IP_KOMPUTER>
MQTT_PORT=1883
API_BASE_URL=http://<IP_KOMPUTER>:8000
```
> Ganti `<IP_KOMPUTER>` dengan IP WiFi komputer (cek dengan `ipconfig`)

### 2. `services/mqtt/subscriber.py` - MQTT Subscriber
```python
BROKER = "localhost"  # Tetap localhost karena jalan di komputer yang sama
BACKEND_URL = "http://localhost:8000/telemetry"  # Tetap localhost
```

### 3. `services/mqtt/publisher.py` - MQTT Publisher
```python
BROKER = "localhost"  # Tetap localhost
BACKEND_URL = "http://localhost:8000/kits"  # Tetap localhost
```

### 4. `run_services.py` - Service Runner
```python
"cmd": "uvicorn services.api.main:app --reload --host 0.0.0.0 --port 8000",
#                                              ^^^^^^^^^^^^^^^^
#                                              WAJIB 0.0.0.0 agar bisa diakses dari HP!
```

> **Catatan:** MQTT Publisher/Subscriber pakai `localhost` karena mereka jalan di komputer yang sama dengan Backend. Yang perlu IP adalah Flutter app karena jalan di HP.

---

## 📦 Build & Install APK

```bash
cd apps/mobile
flutter build apk
```

Ambil file: `build/app/outputs/apk/release/Fountaine-1.0.0.apk`

Kirim ke HP via: WhatsApp / Telegram / Google Drive / Bluetooth

---

## ⚠️ Checklist Wajib HP Fisik

| Item | Cara Cek/Fix |
|------|--------------|
| `run_services.py` pakai `--host 0.0.0.0` | Sudah diubah ✅ |
| `.env` pakai IP komputer | Bukan `localhost` atau `10.0.2.2` |
| Mosquitto service jalan | `net start mosquitto` (Admin CMD) |
| Firewall allow port 8000 | Lihat command di bawah |
| Firewall allow port 1883 | Lihat command di bawah |
| HP & Komputer satu WiFi | Pastikan sama jaringan |

**Firewall Commands (Admin CMD):**
```bash
netsh advfirewall firewall add rule name="Backend API" dir=in action=allow protocol=tcp localport=8000
netsh advfirewall firewall add rule name="MQTT Broker" dir=in action=allow protocol=tcp localport=1883
```

---

## 🔍 Test Koneksi dari HP

Buka browser HP: `http://<IP_KOMPUTER>:8000/kits`

Kalau muncul `[]` atau list kits → Koneksi OK! ✅

---

# 📌 BAGIAN 2: Setup untuk EMULATOR

> Gunakan bagian ini jika kamu pakai Android Emulator.

## 🔧 File yang Perlu Dikonfigurasi

### 1. `apps/mobile/.env` - Flutter App
```env
MQTT_HOST=10.0.2.2
MQTT_PORT=1883
API_BASE_URL=http://10.0.2.2:8000
```
> `10.0.2.2` = IP khusus yang merujuk ke `localhost` komputer dari dalam emulator

### 2. `services/mqtt/subscriber.py` - MQTT Subscriber
```python
BROKER = "localhost"  # Tetap localhost
BACKEND_URL = "http://localhost:8000/telemetry"  # Tetap localhost
```

### 3. `services/mqtt/publisher.py` - MQTT Publisher
```python
BROKER = "localhost"  # Tetap localhost
BACKEND_URL = "http://localhost:8000/kits"  # Tetap localhost
```

### 4. `run_services.py` - Service Runner
```python
"cmd": "uvicorn services.api.main:app --reload --host 0.0.0.0 --port 8000",
#                                              ^^^^^^^^^^^^^^^^
#                                              Tetap 0.0.0.0 agar bisa diakses dari emulator
```

---

## 🚀 Jalankan di Emulator

```bash
# Terminal 1: Start services
python run_services.py

# Terminal 2: Run Flutter app
cd apps/mobile
flutter run
```

Hot-reload otomatis aktif! Perubahan code langsung terlihat tanpa rebuild.

---

## ⚠️ Checklist untuk Emulator

| Item | Keterangan |
|------|------------|
| `.env` pakai `10.0.2.2` | Bukan IP komputer |
| Mosquitto service jalan | `net start mosquitto` |
| Emulator sudah start | Cek dengan `flutter devices` |

---

# 📊 Ringkasan Konfigurasi

| File | HP Fisik | Emulator |
|------|----------|----------|
| `.env` MQTT_HOST | `<IP_KOMPUTER>` | `10.0.2.2` |
| `.env` API_BASE_URL | `http://<IP_KOMPUTER>:8000` | `http://10.0.2.2:8000` |
| `subscriber.py` BROKER | `localhost` | `localhost` |
| `subscriber.py` BACKEND_URL | `localhost:8000` | `localhost:8000` |
| `publisher.py` BROKER | `localhost` | `localhost` |
| `publisher.py` BACKEND_URL | `localhost:8000` | `localhost:8000` |
| `run_services.py` host | `0.0.0.0` | `0.0.0.0` |

---

# 🚀 Quick Start

```bash
cd c:\WisnuDarmawan\Coding\Project\flutter-cea-system

# Jalankan semua services
python run_services.py
```

Ini membuka 3 CMD window:
- ✅ Backend (FastAPI) di port 8000
- ✅ MQTT Subscriber
- ✅ MQTT Publisher

---

# 🔄 Kapan NGROK Dibutuhkan?

| Kondisi | Butuh NGROK? |
|---------|--------------|
| HP & Komputer satu WiFi | ❌ Tidak perlu |
| HP pakai data seluler | ✅ Perlu |
| Akses dari luar rumah/kampus | ✅ Perlu |

---

# 🔍 Cara Cek IP Komputer

```bash
ipconfig | findstr "IPv4"
```

---

# ❓ Troubleshooting

| Problem | Solusi |
|---------|--------|
| App tidak bisa connect | Cek IP di `.env` |
| Connection refused | Allow port 8000 & 1883 di Firewall |
| Monitor screen loading terus | Pastikan MQTT broker jalan + cek MQTT_HOST |
| APK tidak bisa install | Enable "Unknown sources" di HP |
| `run_services.py` error port | Tutup CMD lain yang pakai port 8000 |

---

> 💡 **Tips:** Untuk development, gunakan **Emulator** + `flutter run`. Build APK hanya untuk final testing.
