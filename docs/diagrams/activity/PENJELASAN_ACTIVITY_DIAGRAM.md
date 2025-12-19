# Penjelasan Activity Diagram

## 1. Activity Diagram Login

Gambar di atas menampilkan aktivitas yang dilakukan oleh semua aktor untuk *login*. Dimulai dengan aktor mengakses halaman *login*, kemudian sistem menampilkan form *login*. Aktor mengisi email dan password lalu menekan tombol Login. Sistem melakukan validasi format input terlebih dahulu. Jika format valid, sistem mengirimkan request ke Firebase Auth untuk memverifikasi kredensial. Apabila kredensial valid dan email sudah diverifikasi, maka sistem akan menampilkan halaman utama aplikasi (Home Screen). Namun jika email belum diverifikasi, aktor akan diarahkan ke halaman verifikasi email. Jika kredensial tidak valid, sistem akan menampilkan pesan error dan aktor kembali ke halaman *login*.

---

## 2. Activity Diagram Register

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk mendaftarkan akun baru. Proses dimulai dengan aktor mengakses halaman *register*, kemudian sistem menampilkan form registrasi. Aktor mengisi email, password, dan konfirmasi password, lalu menekan tombol Register. Sistem melakukan validasi format input dan mencocokkan password dengan konfirmasi password. Jika semua valid, sistem mengirimkan request ke Firebase Auth untuk membuat akun baru. Apabila registrasi berhasil, sistem akan mengirimkan email verifikasi dan menampilkan halaman verifikasi email. Jika registrasi gagal (misalnya email sudah terdaftar atau password terlalu lemah), sistem akan menampilkan pesan error dan aktor kembali ke form *register*.

---

## 3. Activity Diagram Add Kit

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk menambahkan kit hidroponik baru. Proses dimulai dengan aktor mengakses halaman Add Kit, kemudian sistem menampilkan form input data kit. Aktor mengisi ID kit dan nama kit, lalu menekan tombol Simpan. Sistem melakukan validasi data input untuk memastikan ID dan nama tidak kosong. Jika data valid, sistem mengirimkan request ke Backend REST API untuk menyimpan data kit baru. Apabila penyimpanan berhasil, sistem menampilkan notifikasi "Kit berhasil ditambahkan" dan mengarahkan aktor ke halaman Home Screen. Jika penyimpanan gagal (misalnya ID kit sudah terdaftar atau terjadi *network error*), sistem akan menampilkan pesan error dan aktor kembali ke form Add Kit.

---

## 4. Activity Diagram History

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk melihat riwayat data sensor. Proses dimulai dengan aktor mengakses halaman History. Sistem mengambil kitId dari *shared state*, menampilkan *loading indicator*, dan melakukan request data history ke Backend REST API. Jika data tersedia, sistem menampilkan *list* data sensor yang mencakup pH, PPM, Temperature, dan Water Level. Jika tidak ada data, sistem menampilkan pesan "Tidak ada data". Aktor dapat memilih filter waktu (1 jam, 6 jam, atau Semua) dan sistem akan melakukan filter data secara lokal. Aktor juga dapat memilih tanggal tertentu, di mana sistem akan melakukan request data untuk tanggal terpilih ke Backend API dan menampilkan hasilnya.

---

## 5. Activity Diagram Monitor

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk memonitor data sensor secara *real-time*. Proses dimulai dengan aktor mengakses halaman Monitor Screen. Sistem melakukan inisialisasi koneksi MQTT, *subscribe* ke topic telemetry dan status, serta memuat status mode otomatis dari Backend API. Sistem menampilkan nilai sensor *real-time* yang mencakup pH, PPM, Temperature, Humidity, Water Level, dan Water Temp, beserta status mode kontrol (Auto/Manual). Aktor dapat memilih mode kontrol dan sistem menyimpan preferensi ke Backend API. Jika mode Manual dipilih, sistem menampilkan tombol kontrol manual (pH Up, pH Down, Nutrient A, Nutrient B, Refill). Ketika aktor menekan tombol kontrol, sistem akan mempublikasikan perintah ke MQTT Broker. Jika mode Auto dipilih, Backend menjalankan kontrol otomatis berdasarkan *threshold* parameter dan mengirimkan hasil via MQTT.

---

## 6. Activity Diagram Notification

Gambar di atas menampilkan aktivitas yang dilakukan oleh aktor untuk melihat notifikasi. Proses dimulai dengan aktor mengakses halaman Notification. Sistem melakukan request daftar notifikasi dari Backend REST API. Jika ada notifikasi, sistem menampilkan daftar notifikasi di UI yang dikelompokkan berdasarkan level (Info, Warning, Urgent). Jika tidak ada notifikasi, sistem menampilkan pesan "Tidak ada notifikasi". Aktor dapat memilih filter (All, Warning, Urgent) dan sistem akan melakukan filter notifikasi berdasarkan level. Jika aktor menekan salah satu notifikasi, sistem menampilkan detail notifikasi dan menandai notifikasi tersebut sebagai telah dibaca melalui request ke Backend API. Aktor juga dapat menekan "Lihat di History" jika notifikasi terkait waktu tertentu, dan sistem akan mengarahkan ke halaman History dengan parameter *targetTime*.
