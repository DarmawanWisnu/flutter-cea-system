# Penjelasan Sequence Diagram

## 1. Sequence Diagram Login

Gambar di atas menampilkan urutan untuk melakukan *login* yang dapat dilakukan oleh User. Dimulai ketika aktor membuka aplikasi maka akan mengarah pada form *login*. Aktor mengisi *email* dan *password*, sistem meneruskan data yang diinputkan untuk dicek ke Firebase Auth. Jika data tidak valid maka akan menampilkan pesan *error* kepada aktor, dan jika data berhasil divalidasi maka akan mengarahkan aktor pada menu *home* aplikasi.

---

## 2. Sequence Diagram Register

Gambar di atas menampilkan urutan untuk melakukan registrasi akun baru. Dimulai ketika aktor membuka halaman *register* dan mengisi form email beserta password. Sistem meneruskan data ke Firebase Auth untuk membuat akun baru. Jika registrasi berhasil, sistem akan mengirim email verifikasi dan mengarahkan aktor ke halaman verifikasi. Jika gagal, sistem menampilkan pesan *error*.

---

## 3. Sequence Diagram Tambah Kit

Gambar di atas menampilkan urutan untuk menambahkan kit hidroponik baru. Dimulai ketika aktor membuka halaman tambah kit dan mengisi ID serta nama kit. Sistem melakukan validasi data dan mengirimkan request ke Backend REST API untuk menyimpan data. Jika berhasil, sistem menampilkan notifikasi sukses dan mengarahkan ke halaman *home*. Jika gagal, sistem menampilkan pesan *error*.

---

## 4. Sequence Diagram History

Gambar di atas menampilkan urutan untuk melihat riwayat data sensor. Dimulai ketika aktor membuka halaman *history*, sistem mengambil data dari Backend REST API berdasarkan kit yang dipilih. Data sensor ditampilkan dalam bentuk *list* yang mencakup pH, PPM, Temperature, dan parameter lainnya. Aktor dapat memilih filter waktu atau tanggal tertentu untuk menampilkan data spesifik.

---

## 5. Sequence Diagram Monitor

Gambar di atas menampilkan urutan untuk melakukan monitoring sensor secara *real-time*. Dimulai ketika aktor membuka halaman monitor, sistem menginisialisasi koneksi MQTT dan *subscribe* ke topic telemetry. Data sensor diterima secara *real-time* dan ditampilkan pada dashboard. Aktor dapat memilih mode Auto atau Manual, serta dapat menekan tombol kontrol untuk mengaktifkan aktuator saat mode Manual.

---

## 6. Sequence Diagram Notification

Gambar di atas menampilkan urutan untuk melihat dan mengelola notifikasi. Proses pembuatan notifikasi berjalan di *background* saat data sensor menyimpang dari *threshold*. Ketika aktor membuka halaman notifikasi, sistem mengambil daftar notifikasi dari Backend REST API. Aktor dapat memilih filter berdasarkan level dan menandai notifikasi sebagai sudah dibaca.
