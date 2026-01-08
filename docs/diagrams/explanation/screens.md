# Deskripsi Tampilan Aplikasi Fountaine Mobile

Dokumen ini menjelaskan setiap halaman (*screen*) yang terdapat dalam aplikasi mobile **Fountaine** - sistem *monitoring* hidroponik berbasis Flutter.

---

## 1. Halaman *Splash*

**Gambar 5.1 Halaman *Splash***

Pada gambar 5.1 menggambarkan *prototype* halaman *splash* aplikasi Fountaine Mobile. Pada halaman *splash* terdapat logo aplikasi berupa ikon daun, nama aplikasi "Fountaine", teks "*Loading...*", dan ilustrasi karakter di bagian bawah layar. Halaman *splash* menggunakan animasi *fade-in* dengan durasi 3 detik sebelum pengguna diarahkan ke halaman *login*. *Background* halaman menggunakan warna hijau yang merepresentasikan tema hidroponik dan pertanian.

---

## 2. Halaman *Login*

**Gambar 5.2 Halaman *Login***

Pada gambar 5.2 menggambarkan *prototype* halaman *login* aplikasi Fountaine Mobile. Pada halaman *login* terdapat *input box* untuk *username* dan *password*, tombol *login*, tombol *sign in with Google*, *link* untuk *recovery password*, dan *link* untuk registrasi akun baru. Halaman *login* dilengkapi dengan validasi format *email* dan fitur *toggle visibility* untuk menampilkan atau menyembunyikan *password*. Halaman *login* dapat diakses ketika pengguna pertama kali membuka aplikasi atau ketika belum terautentikasi.

---

## 3. Halaman *Register*

**Gambar 5.3 Halaman *Register***

Pada gambar 5.3 menggambarkan *prototype* halaman *register* aplikasi Fountaine Mobile. Pada halaman *register* terdapat *input box* untuk nama lengkap, *email*, dan *password*, serta tombol "*Sign Up*" untuk melakukan pendaftaran. Halaman *register* dilengkapi dengan validasi untuk setiap *field input* dan *loading indicator* saat proses pendaftaran berlangsung. Halaman *register* dapat diakses ketika pengguna menekan *link* "*Sign Up For Free*" pada halaman *login*.

---

## 4. Halaman *Forgot Password*

**Gambar 5.4 Halaman *Forgot Password***

Pada gambar 5.4 menggambarkan *prototype* halaman *forgot password* aplikasi Fountaine Mobile. Pada halaman *forgot password* terdapat *input box* untuk memasukkan alamat *email* dan tombol "*Send Reset Link*" untuk mengirim *link* reset *password*. Sistem akan mengirimkan *email* berisi *link* untuk mengatur ulang *password* ke alamat *email* yang didaftarkan. Halaman *forgot password* dapat diakses ketika pengguna menekan *link* "*Recovery Password*" pada halaman *login*.

---

## 5. Halaman *Verify Email*

**Gambar 5.5 Halaman *Verify Email***

Pada gambar 5.5 menggambarkan *prototype* halaman *verify email* aplikasi Fountaine Mobile. Pada halaman *verify email* terdapat instruksi verifikasi, tombol "*Resend Email*" untuk mengirim ulang *email* verifikasi, tombol "*Refresh*" untuk mengecek status verifikasi, dan tombol "*Open Mail App*" untuk membuka aplikasi *email*. Terdapat juga opsi untuk menyalin alamat *email* dan *logout*. Halaman *verify email* dapat diakses setelah pengguna berhasil melakukan registrasi dan email belum diverifikasi.

---

## 6. Halaman *Home*

**Gambar 5.6 Halaman *Home***

Pada gambar 5.6 menggambarkan *prototype* halaman *home* aplikasi Fountaine Mobile. Pada halaman *home* terdapat *header* dengan informasi cuaca dan lokasi, *card* cuaca yang menampilkan suhu dan nama lokasi, serta *grid* menu untuk mengakses fitur *Monitoring*, *Notification*, *Add Kit*, dan *Setting*. Terdapat juga *navigation bar* di bagian bawah dengan tombol QR *code* di tengah untuk menambahkan kit baru. Halaman *home* dapat diakses ketika pengguna sudah melakukan *login* dan *email* sudah terverifikasi.

---

## 7. Halaman *Monitor*

**Gambar 5.7 Halaman *Monitor***

Pada gambar 5.7 menggambarkan *prototype* halaman *monitor* aplikasi Fountaine Mobile. Pada halaman *monitor* terdapat *grid* 3x2 untuk menampilkan 6 parameter sensor yaitu pH, TDS (PPM), *Humidity*, *Air Temp*, *Water Temp*, dan *Water Level*. Setiap *card* sensor dilengkapi dengan *progress bar* berwarna yang menunjukkan tingkat kesesuaian nilai dengan *threshold* optimal. Warna hijau menunjukkan kondisi normal, kuning menunjukkan *warning*, dan merah menunjukkan kondisi *urgent*. Terdapat juga *kit selector* untuk memilih perangkat, *timestamp* terakhir *update*, dan *mode switcher* untuk memilih mode *Auto* atau *Manual*. Halaman *monitor* dapat diakses ketika pengguna menekan menu "*Monitoring*" pada halaman *home*.

---

## 8. Halaman *History*

**Gambar 5.8 Halaman *History***

Pada gambar 5.8 menggambarkan *prototype* halaman *history* aplikasi Fountaine Mobile. Pada halaman *history* terdapat *date picker* untuk memilih tanggal, *filter chips* untuk memilih periode waktu (*All*, *1h*, *6h*), tombol *sort* untuk mengurutkan data dari terbaru atau terlama, dan *list view* yang menampilkan riwayat data sensor. Setiap *entry* menampilkan *timestamp* dan nilai parameter pH, TDS, *Humidity*, dan *Temperature*. Halaman *history* dilengkapi dengan fitur *auto-refresh* setiap 30 detik untuk data hari ini. Halaman *history* dapat diakses ketika pengguna menekan menu "*Notification*" pada halaman *home* atau ikon *tree* pada *navigation bar*.

---

## 9. Halaman *Notification*

**Gambar 5.9 Halaman *Notification***

Pada gambar 5.9 menggambarkan *prototype* halaman *notification* aplikasi Fountaine Mobile. Pada halaman *notification* terdapat *filter chips* untuk memfilter notifikasi berdasarkan level (*All*, *Info*, *Warning*, *Urgent*) dengan *badge count* pada setiap kategori. Setiap *notification card* menampilkan judul, pesan, nama kit, *timestamp*, dan *accent color* sesuai level urgensi. Notifikasi yang belum dibaca ditandai dengan *badge* "*NEW*". Pengguna dapat menghapus notifikasi dengan *swipe to delete* atau menggunakan *popup menu* untuk "*Mark all read*" dan "*Delete all*". Halaman *notification* dapat diakses ketika pengguna menekan *floating action button* pada halaman *history*.

---

## 10. Halaman *Settings*

**Gambar 5.10 Halaman *Settings***

Pada gambar 5.10 menggambarkan *prototype* halaman *settings* aplikasi Fountaine Mobile. Pada halaman *settings* terdapat *account header* yang menampilkan nama dan *email* pengguna, serta beberapa kategori pengaturan. Kategori "*Account Setting*" berisi menu *Profile*, *Change language*, dan *Privacy*. Kategori "*Developer Settings*" berisi tampilan *Server URL*, menu "*Change Server URL*", "*Test Connection*", dan "*Reset to Default*". Kategori "*Legal*" berisi *link* untuk *Terms and Condition*, *Privacy policy*, dan *Help*. Terdapat juga tombol *Logout* dan *version display* di bagian bawah. Halaman *settings* dapat diakses ketika pengguna menekan menu "*Setting*" pada halaman *home*.

---

## 11. Halaman *Profile*

**Gambar 5.11 Halaman *Profile***

Pada gambar 5.11 menggambarkan *prototype* halaman *profile* aplikasi Fountaine Mobile. Pada halaman *profile* terdapat *avatar* pengguna, nama pengguna, alamat *email*, dan daftar kit yang dimiliki dalam bentuk *badge*. Terdapat juga *info tiles* yang menampilkan data profil dengan ikon, tombol "*Edit Profile*" untuk mengedit profil, dan tombol navigasi ke halaman *settings*. Halaman *profile* dapat diakses ketika pengguna menekan tombol "*View*" pada *account header* di halaman *settings* atau menu "*Profile*" pada halaman *settings*.

---

## 12. Halaman *Add Kit*

**Gambar 5.12 Halaman *Add Kit***

Pada gambar 5.12 menggambarkan *prototype* halaman *add kit* aplikasi Fountaine Mobile. Pada halaman *add kit* terdapat *input box* untuk memasukkan nama kit dan ID kit, serta tombol "*Save Kit*" untuk menyimpan data kit baru. Validasi *form* memastikan nama kit wajib diisi dan ID kit minimal 5 karakter. Setelah kit berhasil ditambahkan, sistem akan menampilkan *dialog* sukses dan mengarahkan pengguna ke halaman *home*. Halaman *add kit* dapat diakses ketika pengguna menekan menu "*Add Kit*" pada halaman *home* atau tombol QR *code* pada *navigation bar*.

---

*Dokumentasi ini dibuat untuk referensi pengembangan dan dokumentasi skripsi aplikasi Fountaine Mobile.*
