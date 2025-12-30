# Penjelasan Class Diagram (Arsitektur Sistem)

## Deskripsi Umum

Class Diagram untuk aplikasi **Fountaine Hydroponic Monitoring** menggambarkan struktur arsitektur aplikasi Flutter dengan pendekatan **Clean Architecture**. Diagram ini menunjukkan kelas-kelas utama, atribut, method, dan hubungan antar kelas yang dikelompokkan dalam layer-layer arsitektur.

---

## Arsitektur Layer

Aplikasi menggunakan 4 layer utama yang terpisah berdasarkan tanggung jawab:

```
┌────────────────────────────────────────────────────────────────────────┐
│                           UI LAYER                                     │
│         (Screens/Pages - berinteraksi langsung dengan user)            │
├────────────────────────────────────────────────────────────────────────┤
│                         PROVIDER LAYER                                 │
│           (State Management - Riverpod Providers/ViewModels)           │
├────────────────────────────────────────────────────────────────────────┤
│                         SERVICE LAYER                                  │
│      (Business Logic - komunikasi dengan sistem eksternal)             │
├────────────────────────────────────────────────────────────────────────┤
│                          MODEL LAYER                                   │
│             (Data Classes - representasi entitas data)                 │
├────────────────────────────────────────────────────────────────────────┤
│                          CORE LAYER                                    │
│         (Constants & Utilities - konfigurasi dan helper)               │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 1. UI Layer

Gambar di atas menampilkan layer UI yang berisi semua komponen visual aplikasi Flutter. Layer ini bertanggung jawab untuk menampilkan antarmuka pengguna dan menerima input dari aktor. Setiap screen merupakan StatefulWidget yang terhubung dengan Provider Layer untuk state management.

### Deskripsi
Layer ini berisi semua komponen visual aplikasi Flutter (Screens/Pages). Setiap screen bertanggung jawab untuk menampilkan UI dan menerima input dari user.

### Daftar Kelas

| Kelas | Fungsi |
|-------|--------|
| `AuthGate` | Widget wrapper untuk mengecek status autentikasi user |
| `SplashScreen` | Halaman splash/loading saat aplikasi pertama kali dibuka |
| `HomeScreen` | Halaman utama dengan dashboard dan pilihan kit |
| `MonitorScreen` | Halaman monitoring sensor real-time dengan kontrol aktuator |
| `HistoryScreen` | Halaman riwayat data sensor dengan filter waktu |
| `NotificationScreen` | Halaman daftar dan detail notifikasi |
| `AddKitScreen` | Halaman form untuk menambahkan kit baru |
| `SettingsScreen` | Halaman pengaturan aplikasi (URL backend, dll) |
| `ProfileScreen` | Halaman profil user dan opsi logout |

### Relasi
- UI Layer **bergantung** pada Provider Layer untuk state management
- UI Layer **bergantung** pada Service Layer untuk operasi langsung tertentu

---

## 2. Provider Layer (State Management)

Gambar di atas menampilkan layer Provider yang mengelola state aplikasi menggunakan Riverpod. Layer ini berfungsi sebagai jembatan antara UI dan Service layer, menyediakan reactive updates dan menyimpan state aplikasi secara terpusat.

### Deskripsi
Layer ini mengelola state aplikasi menggunakan Riverpod. Providers berfungsi sebagai jembatan antara UI dan Service layer, menyimpan state dan menyediakan reactive updates.

### Daftar Kelas

#### MqttVM (MQTT ViewModel)
```dart
class MqttVM {
  - _svc : MqttService          // Referensi ke MqttService
  - _autoModeDevices : Set<String>  // Set device dalam mode auto
  
  + telemetryMap : Map<String, Telemetry>  // Data telemetry per device
  + statusMap : Map<String, DeviceStatus>  // Status online per device
  
  + init()                      // Inisialisasi koneksi MQTT
  + publishActuator()           // Publish perintah ke aktuator
  + enableAutoMode()            // Aktifkan mode auto untuk device
  + disableAutoMode()           // Nonaktifkan mode auto
  + isAutoMode()                // Cek status mode device
  + loadAutoModeFromBackend()   // Load state dari Backend API
}
```

**Tanggung Jawab**: Mengelola koneksi MQTT, menyimpan data telemetry real-time, dan mengontrol mode Auto/Manual.

---

#### NotificationListNotifier
```dart
class NotificationListNotifier {
  - _ref : Ref                  // Riverpod ref untuk dependency injection
  
  + fetchNotifications()        // Ambil daftar notifikasi dari API
  + markRead()                  // Tandai satu notifikasi sebagai dibaca
  + markAllRead()               // Tandai semua notifikasi sebagai dibaca
  + delete()                    // Hapus satu notifikasi
  + clearAll()                  // Hapus semua notifikasi user
}
```

**Tanggung Jawab**: Mengelola state daftar notifikasi, termasuk operasi CRUD.

---

#### MonitorTelemetryProvider
```dart
class MonitorTelemetryProvider {
  + data : Telemetry            // Data sensor terkini
  + lastUpdated : DateTime      // Timestamp update terakhir
}
```

**Tanggung Jawab**: Menyimpan snapshot data telemetry untuk Monitor Screen.

---

#### ApiProvider
```dart
class ApiProvider {
  + kits : List<Kit>            // Daftar kit user
  
  + fetchKits()                 // Ambil daftar kit dari API
  + addKit()                    // Tambahkan kit baru
  + deleteKit()                 // Hapus kit dari akun user
}
```

**Tanggung Jawab**: Mengelola state daftar kit hidroponik user.

---

#### AuthProvider
```dart
class AuthProvider {
  + user : User?                // Firebase User object (nullable)
  + isLoading : bool            // Status loading autentikasi
}
```

**Tanggung Jawab**: Mengelola state autentikasi user dari Firebase.

---

#### UrlSettingsProvider
```dart
class UrlSettingsProvider {
  + baseUrl : String            // URL Backend API
  
  + updateBaseUrl()             // Update URL endpoint
}
```

**Tanggung Jawab**: Mengelola konfigurasi URL backend yang dapat diubah user.

---

## 3. Service Layer

Gambar di atas menampilkan layer Service yang berisi logic untuk berkomunikasi dengan sistem eksternal. Layer ini bersifat stateless dan menangani operasi seperti autentikasi Firebase, komunikasi MQTT, dan REST API calls.

### Deskripsi
Layer ini berisi logic untuk berkomunikasi dengan sistem eksternal (Firebase, Backend API, MQTT Broker). Services bersifat stateless dan hanya melakukan operasi.

### Daftar Kelas

#### AuthService
```dart
class AuthService {
  - _auth : FirebaseAuth        // Instance Firebase Auth
  
  + signInWithEmailPassword()   // Login dengan email & password
  + registerWithEmailPassword() // Registrasi akun baru
  + signOut()                   // Logout dari sesi
  + sendEmailVerification()     // Kirim email verifikasi
  + sendPasswordReset()         // Kirim email reset password
  + reloadUser()                // Refresh data user dari Firebase
}
```

**Komunikasi**: Firebase Authentication

---

#### MqttService
```dart
class MqttService {
  - _client : MqttServerClient  // Client MQTT dari package mqtt_client
  
  + connectionState$ : Stream   // Stream status koneksi
  + telemetry$ : Stream         // Stream data telemetry
  + status$ : Stream            // Stream status device
  
  + connect()                   // Koneksi ke MQTT Broker
  + publishControl()            // Publish perintah kontrol
  + disconnect()                // Putuskan koneksi
}
```

**Komunikasi**: HiveMQ Cloud MQTT Broker
**Topics**:
- `kit/+/telemetry` - Data sensor
- `kit/+/status` - Status device
- `kit/{id}/control` - Perintah aktuator

---

#### ApiService
```dart
class ApiService {
  - baseUrl : String            // URL Backend REST API
  
  + getLatestTelemetry()        // GET /telemetry/latest
  + getTelemetryHistory()       // GET /telemetry/history
  + getLatestActuatorEvent()    // GET /actuator/latest
  + setDeviceMode()             // POST /device/mode
  + getDeviceMode()             // GET /device/mode
  + getNotifications()          // GET /notifications
  + markNotificationRead()      // PUT /notifications/{id}/read
  + deleteNotification()        // DELETE /notifications/{id}
}
```

**Komunikasi**: Python FastAPI Backend

---

#### ApiKitsService
```dart
class ApiKitsService {
  + getKits()                   // GET /kits?userId=
  + addKit()                    // POST /kits
  + deleteKit()                 // DELETE /kits/{id}?userId=
}
```

**Komunikasi**: Python FastAPI Backend (endpoint kits)

---

## 4. Model Layer

Gambar di atas menampilkan layer Model yang berisi data class (Plain Old Dart Objects) merepresentasikan entitas dalam sistem. Model bersifat immutable dengan method `fromJson()`, `toJson()`, dan `copyWith()` untuk serialization.

### Deskripsi
Layer ini berisi data class (Plain Old Dart Objects) yang merepresentasikan entitas dalam sistem. Model bersifat immutable dan memiliki method untuk serialization.

### Daftar Kelas

#### Telemetry
```dart
class Telemetry {
  + id : int?                   // ID record (nullable)
  + ingestTime : int?           // Timestamp Unix
  + ppm : double                // Part Per Million (nutrisi)
  + ph : double                 // Keasaman (0-14)
  + tempC : double              // Suhu udara °C
  + humidity : double           // Kelembaban %
  + waterTemp : double          // Suhu air °C
  + waterLevel : double         // Level air (0-3)
  
  + fromJson()                  // Factory dari JSON
  + toJson()                    // Serialize ke JSON
  + copyWith()                  // Clone dengan modifikasi
}
```

---

#### DeviceStatus
```dart
class DeviceStatus {
  + online : bool               // Status online/offline
  + lastSeen : DateTime         // Waktu terakhir terlihat
}
```

---

#### Kit
```dart
class Kit {
  + id : String                 // Unique identifier kit
  + name : String               // Nama kit
  + createdAt : DateTime        // Tanggal pendaftaran
}
```

---

#### NotificationItem
```dart
class NotificationItem {
  + id : String                 // ID notifikasi
  + kitId : String              // Kit terkait
  + level : String              // Level: info, warning, urgent
  + message : String            // Isi pesan
  + timestamp : DateTime        // Waktu pembuatan
  + isRead : bool               // Status dibaca
}
```

---

#### HistoryRouteArgs & NotificationRouteArgs
```dart
class HistoryRouteArgs {
  + targetTime : DateTime?      // Waktu target navigasi
  + kitName : String?           // Nama kit
  + kitId : String?             // ID kit
  + reason : String?            // Alasan navigasi
}

class NotificationRouteArgs {
  + initialFilter : String?     // Filter awal (all/warning/urgent)
}
```

**Fungsi**: Passing data antar halaman melalui navigation arguments.

---

## 5. Core Layer

Gambar di atas menampilkan layer Core yang berisi konstanta dan utilities yang digunakan di seluruh aplikasi. Layer ini mencakup konfigurasi MQTT, threshold parameter hidroponik, dan helper functions.

### Deskripsi
Layer ini berisi konstanta dan utilities yang digunakan di seluruh aplikasi.

### Daftar Kelas

#### AppConst
```dart
class AppConst {
  + defaultKitId : String       // Kit ID default
  
  + formatDateTime()            // Format timestamp ke string
}
```

---

#### MqttConst
```dart
class MqttConst {
  + host : String               // MQTT Broker host
  + port : int                  // MQTT Port (8883 TLS)
  + username : String           // MQTT credential
  + password : String           // MQTT credential
  
  + tTelemetry()                // Topic builder: kit/{id}/telemetry
  + tStatus()                   // Topic builder: kit/{id}/status
  + tControl()                  // Topic builder: kit/{id}/control
}
```

---

#### ThresholdConst
```dart
class ThresholdConst {
  + ppmMin : double             // PPM minimum (800)
  + ppmMax : double             // PPM maximum (1200)
  + phMin : double              // pH minimum (5.5)
  + phMax : double              // pH maximum (6.5)
  + tempMin : double            // Suhu minimum (20°C)
  + tempMax : double            // Suhu maximum (30°C)
  + wlMin : double              // Water level minimum (1)
  + wlMax : double              // Water level maximum (3)
}
```

---

## Diagram Relasi Antar Kelas

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              UI LAYER                                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │AuthGate  │ │HomeScreen│ │MonitorScr│ │HistorySc │ │NotifyScrn│      │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘      │
│       │            │            │            │            │             │
└───────┼────────────┼────────────┼────────────┼────────────┼─────────────┘
        │            │            │            │            │
        ▼            ▼            ▼            ▼            ▼
┌───────┴────────────┴────────────┴────────────┴────────────┴─────────────┐
│                           PROVIDER LAYER                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │AuthProv  │ │ApiProv   │ │ MqttVM   │ │MonitorPrv│ │NotifList │      │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘      │
│       │            │            │            │            │             │
└───────┼────────────┼────────────┼────────────┼────────────┼─────────────┘
        │            │            │            │            │
        ▼            ▼            ▼            ▼            ▼
┌───────┴────────────┴────────────┴────────────┴────────────┴─────────────┐
│                           SERVICE LAYER                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                                │
│  │AuthSvc   │ │ApiService│ │MqttService                                │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘                                │
│       │            │            │                                       │
└───────┼────────────┼────────────┼───────────────────────────────────────┘
        │            │            │
        ▼            ▼            ▼
┌───────┴────────────┴────────────┴───────────────────────────────────────┐
│                         EXTERNAL SYSTEMS                                │
│  ┌──────────────┐  ┌──────────────────┐  ┌────────────────┐            │
│  │ Firebase Auth│  │Backend REST API  │  │MQTT Broker     │            │
│  └──────────────┘  └──────────────────┘  └────────────────┘            │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Prinsip Desain

1. **Separation of Concerns**: Setiap layer memiliki tanggung jawab spesifik
2. **Dependency Inversion**: Layer atas bergantung pada abstraksi layer bawah
3. **Single Responsibility**: Setiap class memiliki satu alasan untuk berubah
4. **Immutability**: Model class bersifat immutable dengan `copyWith()` pattern
5. **Reactive Programming**: Menggunakan Stream untuk data real-time
