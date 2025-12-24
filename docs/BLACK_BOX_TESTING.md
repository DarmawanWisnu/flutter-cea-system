# Black Box Testing - Aplikasi Fountaine (Monitoring Hidroponik)

## Tabel Pengujian Fungsionalitas Aplikasi

| No. | Deskripsi | Pengujian | Output yang Diharapkan | Output | Kesimpulan |
|-----|-----------|-----------|------------------------|--------|------------|
| 1. | Login | Mengisi email dan password sesuai dengan yang terdaftar di database | Berhasil login dan menampilkan Home Screen | Berhasil login dan menampilkan Home Screen | *Passed* |
| 2. | Register | Mengisi form registrasi dengan email baru, password, dan konfirmasi password | Email verifikasi terkirim dan akun berhasil dibuat | Email verifikasi terkirim dan akun berhasil dibuat | *Passed* |
| 3. | Forgot Password | Mengisi email yang terdaftar pada form forgot password | Email reset password terkirim ke email yang didaftarkan | Email reset password terkirim ke email yang didaftarkan | *Passed* |
| 4. | Pilih Kit Hidroponik | Memilih kit dari dropdown "Your Kit" pada Monitor Screen | Menampilkan data sensor real-time dari kit yang dipilih | Menampilkan data sensor real-time dari kit yang dipilih | *Passed* |
| 5. | Lihat Data Sensor Real-time | Membuka Monitor Screen setelah memilih kit | Menampilkan gauge pH, TDS, Humidity, Air Temp dengan data terkini | Menampilkan gauge pH, TDS, Humidity, Air Temp dengan data terkini | *Passed* |
| 6. | Switch Mode AUTO | Tap tombol "AUTO" pada Mode section | Mode berubah ke AUTO, tombol kontrol manual hilang, sistem kontrol otomatis aktif | Mode berubah ke AUTO, tombol kontrol manual hilang, sistem kontrol otomatis aktif | *Passed* |
| 7. | Switch Mode MANUAL | Tap tombol "MANUAL" pada Mode section | Mode berubah ke MANUAL, menampilkan tombol kontrol (PH UP, PH DOWN, NUTRIENT, REFILL) | Mode berubah ke MANUAL, menampilkan tombol kontrol (PH UP, PH DOWN, NUTRIENT, REFILL) | *Passed* |
| 8. | Kontrol PH UP (Manual) | Tap tombol "PH UP" saat mode MANUAL aktif | Sistem mengirim command ke actuator pH up via MQTT, menampilkan durasi aktif | Sistem mengirim command ke actuator pH up via MQTT, menampilkan durasi aktif | *Passed* |
| 9. | Kontrol NUTRIENT (Manual) | Tap tombol "NUTRIENT" saat mode MANUAL aktif | Sistem mengirim command ke actuator nutrient via MQTT, menampilkan durasi aktif | Sistem mengirim command ke actuator nutrient via MQTT, menampilkan durasi aktif | *Passed* |
| 10. | Lihat History | Tap menu "History" pada bottom navigation | Menampilkan grafik history sensor (pH, PPM, Temperature, Humidity) dengan data historis | Menampilkan grafik history sensor dengan data historis | *Passed* |
| 11. | Lihat Notifikasi | Tap menu "Notification" pada bottom navigation | Menampilkan list notifikasi sistem (info, warning, urgent) | Menampilkan list notifikasi sistem dengan badge severity | *Passed* |
| 12. | Filter Notifikasi (Warning) | Tap chip "Warning" pada Notification Screen | Menampilkan hanya notifikasi dengan severity Warning | Menampilkan hanya notifikasi dengan severity Warning | *Passed* |
| 13. | Tambah Kit Baru | Tap tombol "+" pada Home Screen, mengisi Kit ID dan Kit Name, lalu tap "Add Kit" | Kit baru tersimpan di database dan muncul di dropdown selection | Kit baru tersimpan di database dan muncul di dropdown selection | *Passed* |
| 14. | Lihat Profile | Tap menu "Profile" dari Settings atau bottom navigation | Menampilkan informasi user (User ID, Email, Kit Name, Kit ID, Status ACTIVE) | Menampilkan informasi user dengan data yang sesuai | *Passed* |
| 15. | Logout | Tap tombol "Logout" pada Settings Screen | Muncul dialog konfirmasi logout, setelah confirm kembali ke Login Screen | Muncul dialog konfirmasi, berhasil logout dan redirect ke Login Screen | *Passed* |

---

## Rangkuman Hasil Pengujian

**Total Test Cases**: 15  
**Passed**: 15 (100%)  
**Failed**: 0 (0%)  

**Kategori Pengujian**:
- **Autentikasi**: 3 test cases (Login, Register, Forgot Password)
- **Monitoring & Kontrol Hidroponik**: 6 test cases (Pilih kit, Lihat sensor, Mode AUTO/MANUAL, Kontrol actuator)
- **History & Visualisasi Data**: 1 test case (Grafik history)
- **Sistem Notifikasi**: 2 test cases (Lihat notifikasi, Filter)
- **Manajemen Kit & User**: 2 test cases (Tambah kit, Profile)
- **Logout**: 1 test case

---

## Kesimpulan

Berdasarkan hasil pengujian Black Box Testing terhadap **15 fungsionalitas utama** aplikasi Fountaine (Monitoring Hidroponik), **semua fitur berfungsi sesuai dengan yang diharapkan** dengan tingkat keberhasilan **100%**. 

Aplikasi berhasil memenuhi requirements fungsional yang meliputi:
1. ✅ Sistem autentikasi dengan Firebase Auth (login, register, forgot password, logout)
2. ✅ Real-time monitoring sensor melalui MQTT (pH, TDS, Temperature, Humidity)
3. ✅ Kontrol manual dan otomatis actuator hidroponik
4. ✅ Visualisasi data historis dengan grafik interaktif
5. ✅ Sistem notifikasi berbasis severity (info, warning, urgent)
6. ✅ Manajemen kit hidroponik dan profil user

Pengujian ini dilakukan dari perspektif end-user tanpa melihat implementasi internal kode (**Black Box approach**), memvalidasi bahwa aplikasi memberikan **user experience yang baik** dan **fungsionalitas yang reliable** untuk sistem monitoring hidroponik.
