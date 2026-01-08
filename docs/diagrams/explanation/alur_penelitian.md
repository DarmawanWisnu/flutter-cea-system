# Penjelasan Diagram Alur Penelitian

## Deskripsi Umum

Diagram **Alur Penelitian** menggambarkan tahapan metodologi penelitian yang digunakan dalam pengembangan sistem **Fountaine Hydroponic Monitoring**. Diagram ini menggunakan format Activity Diagram dengan partisi (partition) untuk mengelompokkan aktivitas-aktivitas berdasarkan fase penelitian.

---

## Ringkasan Diagram

| Fase | Aktivitas | Output |
|------|-----------|--------|
| Awal | Perumusan Masalah, Kajian Pustaka | Rumusan masalah, Tinjauan literatur |
| Kebutuhan Sistem | Deskripsi Software, Analisis Kebutuhan | SRS, User Requirements |
| Perancangan | UML, Database, UI Design | Diagram sistem, ERD, Prototipe UI |
| Implementasi | Koding Mobile & Backend | Aplikasi Flutter, API FastAPI |
| Pengujian | Unit, Blackbox, UAT | Test reports, Bug fixes |
| Pemeliharaan | Maintenance, Deploy APK | Release version |
| Akhir | System Usability Scale (SUS) | Skor SUS, Evaluasi akhir |

---

## Notasi yang Digunakan

| Simbol | Nama | Fungsi |
|--------|------|--------|
| ⚫ (filled circle) | Start Node | Titik awal alur penelitian |
| ⊙ (circle with dot) | Stop Node | Titik akhir alur penelitian |
| ▭ (rounded rectangle) | Activity | Satu unit aktivitas/pekerjaan |
| ═══ (horizontal bar) | Fork/Join | Aktivitas paralel dalam satu fase |
| ⌷ (partition box) | Partition | Pengelompokan aktivitas berdasarkan fase |

---

## Tahapan Alur Penelitian

### 1. Tahap Awal

Penelitian dimulai dengan dua aktivitas fundamental yang dilakukan secara sekuensial:

```
[Start] → Perumusan Masalah → Kajian Pustaka
```

**Perumusan Masalah:**
- Mengidentifikasi permasalahan utama dalam sistem hidroponik konvensional
- Menentukan kebutuhan sistem monitoring dan kontrol otomatis
- Mendefinisikan ruang lingkup penelitian

**Kajian Pustaka:**
- Mempelajari literatur terkait hidroponik dan IoT
- Menganalisis penelitian terdahulu
- Mengidentifikasi teknologi yang akan digunakan

---

### 2. Fase Kebutuhan Sistem

Pada fase ini, dua aktivitas dilakukan secara **paralel** (fork):

```
┌─────────────────────────────────────────────────────────┐
│                   KEBUTUHAN SISTEM                      │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐  ┌──────────────────────────┐ │
│  │ Menentukan Deskripsi │  │ Analisis Kebutuhan       │ │
│  │ Software, Fitur,     │  │ Pengguna dan Sistem      │ │
│  │ Modul                │  │                          │ │
│  └──────────────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Aktivitas Paralel:**
1. **Menentukan Deskripsi Software, Fitur, Modul**
   - Mendefinisikan spesifikasi teknis aplikasi
   - Menentukan fitur-fitur yang akan dikembangkan
   - Merancang modul-modul sistem

2. **Analisis Kebutuhan Pengguna dan Sistem**
   - Mengidentifikasi kebutuhan fungsional dan non-fungsional
   - Menentukan aktor dan use case
   - Menyusun user requirements

---

### 3. Fase Perancangan

Fase perancangan melibatkan tiga aktivitas yang dilakukan secara **paralel**:

```
┌─────────────────────────────────────────────────────────────────────┐
│                          PERANCANGAN                                │
├─────────────────────────────────────────────────────────────────────┤
│  ┌───────────────────┐  ┌───────────────────┐  ┌──────────────────┐ │
│  │ Perancangan       │  │ Perancangan       │  │ Perancangan      │ │
│  │ Sistem            │  │ Database          │  │ Desain UI        │ │
│  │ (UML Diagram)     │  │ (PostgreSQL)      │  │ (Figma)          │ │
│  └───────────────────┘  └───────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

**Aktivitas Paralel:**
1. **Perancangan Sistem (UML Diagram)**
   - Use Case Diagram
   - Activity Diagram
   - Sequence Diagram
   - Class Diagram

2. **Perancangan Database**
   - Logical Design (ERD)
   - Physical Design (PostgreSQL schema)

3. **Perancangan Desain UI**
   - Prototyping menggunakan Figma
   - Mockup tampilan aplikasi mobile

---

### 4. Fase Implementasi Sistem

Implementasi dilakukan dengan dua tim/aktivitas secara **paralel**:

```
┌─────────────────────────────────────────────────────────┐
│                  IMPLEMENTASI SISTEM                    │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐  ┌──────────────────────────┐ │
│  │ Koding Aplikasi      │  │ Membuat Backend          │ │
│  │ Mobile               │  │ (Python + FastAPI)       │ │
│  │ (Bahasa Dart)        │  │                          │ │
│  └──────────────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Aktivitas Paralel:**
1. **Koding Aplikasi Mobile**
   - Framework: Flutter
   - Bahasa Pemrograman: Dart
   - Platform: Android

2. **Membuat Backend**
   - Bahasa Pemrograman: Python
   - Framework: FastAPI
   - Database: PostgreSQL
   - Messaging: MQTT

---

### 5. Fase Pengujian

Pengujian dilakukan dengan tiga metode secara **paralel**:

```
┌─────────────────────────────────────────────────────────────────────┐
│                           PENGUJIAN                                 │
├─────────────────────────────────────────────────────────────────────┤
│  ┌───────────────────┐  ┌───────────────────┐  ┌──────────────────┐ │
│  │ Unit Testing      │  │ Blackbox Testing  │  │ User Acceptance  │ │
│  │                   │  │                   │  │ Testing (UAT)    │ │
│  └───────────────────┘  └───────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

**Aktivitas Paralel:**
1. **Unit Testing**
   - Pengujian individual terhadap fungsi/method
   - Memastikan setiap unit kode berfungsi dengan benar

2. **Blackbox Testing**
   - Pengujian fungsional tanpa melihat internal code
   - Fokus pada input dan output sistem

3. **User Acceptance Testing (UAT)**
   - Pengujian oleh pengguna akhir
   - Validasi apakah sistem memenuhi requirements

---

### 6. Fase Pemeliharaan

Fase akhir pengembangan dengan dua aktivitas **paralel**:

```
┌─────────────────────────────────────────────────────────┐
│                     PEMELIHARAAN                        │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐  ┌──────────────────────────┐ │
│  │ Maintenance          │  │ Deploy ke dalam          │ │
│  │ Aplikasi             │  │ bentuk APK               │ │
│  └──────────────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Aktivitas Paralel:**
1. **Maintenance Aplikasi**
   - Bug fixing
   - Performance optimization
   - Security updates

2. **Deploy ke dalam bentuk APK**
   - Build release version
   - Signing APK
   - Distribusi ke pengguna

---

### 7. Tahap Akhir - Evaluasi

```
[Pemeliharaan] → System Usability Scale (SUS) → [Stop]
```

**System Usability Scale (SUS):**
- Metode evaluasi usability standar industri
- Menggunakan kuesioner 10 pertanyaan
- Menghasilkan skor 0-100 untuk tingkat usability
- Menentukan apakah sistem layak digunakan

---

## Alur Visual Keseluruhan

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ALUR PENELITIAN                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [●] Start                                                          │
│   │                                                                 │
│   ▼                                                                 │
│  Perumusan Masalah                                                  │
│   │                                                                 │
│   ▼                                                                 │
│  Kajian Pustaka                                                     │
│   │                                                                 │
│   ▼                                                                 │
│  ╔════════════════════════════════════════════════════════════════╗ │
│  ║ KEBUTUHAN SISTEM                                               ║ │
│  ║  ══╤═══════════════════════╤══                                 ║ │
│  ║    │                       │                                   ║ │
│  ║  Deskripsi SW        Analisis Kebutuhan                        ║ │
│  ║    │                       │                                   ║ │
│  ║  ══╧═══════════════════════╧══                                 ║ │
│  ╚════════════════════════════════════════════════════════════════╝ │
│   │                                                                 │
│   ▼                                                                 │
│  ╔════════════════════════════════════════════════════════════════╗ │
│  ║ PERANCANGAN                                                    ║ │
│  ║  ══╤═══════════════╤═══════════════╤══                         ║ │
│  ║    │               │               │                           ║ │
│  ║  UML Diagram   Database       UI Design                        ║ │
│  ║    │               │               │                           ║ │
│  ║  ══╧═══════════════╧═══════════════╧══                         ║ │
│  ╚════════════════════════════════════════════════════════════════╝ │
│   │                                                                 │
│   ▼                                                                 │
│  ╔════════════════════════════════════════════════════════════════╗ │
│  ║ IMPLEMENTASI SISTEM                                            ║ │
│  ║  ══╤═══════════════════════╤══                                 ║ │
│  ║    │                       │                                   ║ │
│  ║  Mobile (Dart)      Backend (Python)                           ║ │
│  ║    │                       │                                   ║ │
│  ║  ══╧═══════════════════════╧══                                 ║ │
│  ╚════════════════════════════════════════════════════════════════╝ │
│   │                                                                 │
│   ▼                                                                 │
│  ╔════════════════════════════════════════════════════════════════╗ │
│  ║ PENGUJIAN                                                      ║ │
│  ║  ══╤═══════════════╤═══════════════╤══                         ║ │
│  ║    │               │               │                           ║ │
│  ║  Unit Test    Blackbox Test      UAT                           ║ │
│  ║    │               │               │                           ║ │
│  ║  ══╧═══════════════╧═══════════════╧══                         ║ │
│  ╚════════════════════════════════════════════════════════════════╝ │
│   │                                                                 │
│   ▼                                                                 │
│  ╔════════════════════════════════════════════════════════════════╗ │
│  ║ PEMELIHARAAN                                                   ║ │
│  ║  ══╤═══════════════════════╤══                                 ║ │
│  ║    │                       │                                   ║ │
│  ║  Maintenance          Deploy APK                               ║ │
│  ║    │                       │                                   ║ │
│  ║  ══╧═══════════════════════╧══                                 ║ │
│  ╚════════════════════════════════════════════════════════════════╝ │
│   │                                                                 │
│   ▼                                                                 │
│  System Usability Scale (SUS)                                       │
│   │                                                                 │
│   ▼                                                                 │
│  [◉] Stop                                                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Poin-Poin Kunci

1. **Metodologi Sekuensial dengan Paralelisme**
   - Alur utama mengikuti tahapan sekuensial dari awal hingga akhir
   - Dalam setiap fase, aktivitas dapat dilakukan secara paralel untuk efisiensi

2. **Fase Perancangan Komprehensif**
   - Mencakup tiga aspek: sistem, database, dan UI
   - Menggunakan tools standar industri (UML, PostgreSQL, Figma)

3. **Implementasi Full-Stack**
   - Frontend: Flutter (Dart)
   - Backend: FastAPI (Python)
   - Keduanya dikembangkan secara paralel

4. **Pengujian Multi-Level**
   - Unit Testing untuk komponen individual
   - Blackbox Testing untuk fungsionalitas sistem
   - UAT untuk validasi kebutuhan pengguna

5. **Evaluasi dengan Standar SUS**
   - Menggunakan metode evaluasi usability yang terstandar
   - Memberikan metrik terukur untuk keberhasilan sistem

---

## Referensi File

| File | Lokasi |
|------|--------|
| Diagram Source | `docs/diagrams/activity/alur_penelitian.puml` |
| Diagram PNG | `docs/diagrams/images/png/alur_penelitian.png` |
| Diagram SVG | `docs/diagrams/images/svg/alur_penelitian.svg` |
