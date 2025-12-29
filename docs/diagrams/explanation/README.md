# Dokumentasi Penjelasan Diagram - Fountaine Hydroponic Monitoring

## Daftar Isi

Folder ini berisi penjelasan detail untuk setiap jenis diagram UML yang digunakan dalam perancangan sistem **Fountaine Hydroponic Monitoring**.

---

## Daftar Dokumen

| No | Nama File | Jenis Diagram | Keterangan |
|----|-----------|---------------|------------|
| 1 | [01_PENJELASAN_DATABASE_DIAGRAM.md](./01_PENJELASAN_DATABASE_DIAGRAM.md) | Entity Relationship Diagram (ERD) | Logical database design dengan 9 tabel + API endpoints |
| 2 | [02_PENJELASAN_USECASE_DIAGRAM.md](./02_PENJELASAN_USECASE_DIAGRAM.md) | Use Case Diagram | 11 use case dengan relasi include |
| 3 | [03_PENJELASAN_ACTIVITY_DIAGRAM.md](./03_PENJELASAN_ACTIVITY_DIAGRAM.md) | Activity Diagram | 6 diagram workflow dengan swimlane |
| 4 | [04_PENJELASAN_SEQUENCE_DIAGRAM.md](./04_PENJELASAN_SEQUENCE_DIAGRAM.md) | Sequence Diagram | 6 diagram interaksi antar objek |
| 5 | [05_PENJELASAN_CLASS_DIAGRAM.md](./05_PENJELASAN_CLASS_DIAGRAM.md) | Class Diagram | Arsitektur 5 layer dengan relasi kelas |

---

## Ringkasan Diagram

### 1. Database Diagram (ERD)
Menggambarkan struktur database dengan **9 entitas** utama:
- `kits`, `telemetry`, `actuator_event`, `actuator_cooldown`
- `device_mode`, `user_preference`, `notifications`
- `ml_prediction_log`, `user_kits`

**Bonus**: Termasuk tabel **26 endpoint REST API** yang tersedia di backend.

### 2. Use Case Diagram
Menggambarkan **11 use case** yang dapat diakses oleh aktor User:
- **Auth**: Login, Register, Logout
- **Features**: Lihat Sensor, Monitor, Add Kit, Kendali Pompa, Notifikasi, History, Settings, Profile

### 3. Activity Diagram
Menggambarkan **6 workflow** utama:
1. Login - Proses autentikasi user
2. Register - Proses registrasi akun baru
3. Add Kit - Proses menambah perangkat IoT
4. History - Proses melihat riwayat sensor
5. Monitor - Proses monitoring real-time
6. Notification - Proses mengelola notifikasi

### 4. Sequence Diagram
Menggambarkan **6 interaksi** urutan pesan antar objek:
1. Login - User → AuthService → Firebase Auth
2. Register - User → AuthService → Firebase Auth
3. Add Kit - User → ApiKitsService → Backend
4. History - User → ApiService → Backend
5. Monitor - User → MqttVM → MQTT Broker
6. Notification - User → NotificationListNotifier → Backend

### 5. Class Diagram
Menggambarkan arsitektur **5 layer**:
- **UI Layer**: 9 screen/page classes
- **Provider Layer**: 6 state management classes
- **Service Layer**: 4 service classes
- **Model Layer**: 6 data classes
- **Core Layer**: 3 constant classes

---

## Catatan

Dokumentasi ini menggabungkan dan menyempurnakan konten dari file `docs/PENJELASAN_DATABASE.md` yang sebelumnya terpisah. File tersebut kini sudah terintegrasi ke dalam folder ini sebagai bagian dari `01_PENJELASAN_DATABASE_DIAGRAM.md`.

---

## Lokasi File Diagram (.puml)

File diagram PlantUML asli tersimpan di:

```
docs/diagrams/
├── activity/
│   ├── activity_login.puml
│   ├── activity_register.puml
│   ├── activity_addkit.puml
│   ├── activity_history.puml
│   ├── activity_monitor.puml
│   └── activity_notification.puml
├── class/
│   └── class_architecture.puml
├── database/
│   └── database_diagram.puml
├── sequence/
│   ├── sequence_login.puml
│   ├── sequence_register.puml
│   ├── sequence_addkit.puml
│   ├── sequence_history.puml
│   ├── sequence_monitor.puml
│   └── sequence_notification.puml
└── usecase/
    ├── usecase.puml
    └── usecase_detailed.puml
```

---

## Cara Render Diagram

Untuk mengconvert file `.puml` menjadi gambar, gunakan salah satu metode:

1. **VS Code Extension**: PlantUML extension
2. **Online**: [PlantUML Server](https://www.plantuml.com/plantuml)
3. **CLI**: `java -jar plantuml.jar diagram.puml`
