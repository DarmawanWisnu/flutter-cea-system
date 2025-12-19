

## PERANCANGAN APLIKASI MONITORING HIDROPONIK BERBASIS
## MOBILE DENGAN FRAMEWORK FLUTTER

## Skripsi




## Oleh
## Wisnu Darmawan
## NIM : 11210910000109



## PROGRAM STUDI TEKNIK INFORMATIKA
## FAKULTAS SAINS DAN TEKNOLOGI
## UNIVERSITAS ISLAM NEGERI SYARIF HIDAYATULLAH
## JAKARTA
## 2025 M /  1446 H

## PERANCANGAN APLIKASI MONITORING HIDROPONIK BERBASIS
## MOBILE DENGAN FRAMEWORK FLUTTER

## Skripsi

Diajukan sebagai salah satu syarat untuk memperoleh gelar Sarjana Komputer
(S.Kom)



## Oleh
## Wisnu Darmawan
## NIM : 11210910000109


## PROGRAM STUDI TEKNIK INFORMATIKA
## FAKULTAS SAINS DAN TEKNOLOGI
## UNIVERSITAS ISLAM NEGERI SYARIF HIDAYATULLAH
## JAKARTA
## 2025 M /  1446 H

## LEMBAR PERSETUJUAN


## LEMBAR PENGESAHAN


## PERNYATAAN PERSETUJUAN PUBLIKASI SKRIPSI

Sebagai sivitas akademik UIN Syarif Hidayatullah Jakarta, saya yang bertanda tangan di bawah
ini:
## Nama  : Wisnu Darmawan
## NIM  : 11210910000109
## Program Studi : Teknik Informatika
Fakultas  : Sains dan Teknologi
## Jenis Karya : Skripsi
Demi pengembangan ilmu pengetahuan, menyetujui untuk memberikan kepada UIN Syarif
Hidayatullah Hak Bebas Royalti Noneksklusif (Non-exclusive Royalty Free Right) atas karya
ilmiah saya yang berjudul :
## “PERANCANGAN APLIKASI MONITORING HIDROPONIK BERBASIS
## MOBILE DENGAN FRAMEWORK FLUTTER”

Beserta perangkat yang ada (jika diperlukan). Dengan Hak Bebas Royalti Noneksklusif ini UIN
Syarif Hidayatullah Jakarta berhak menyimpan, mengalihmedia/formatkan, mengelola dalam
bentuk pangkalan data (database), merawat, dan mempublikasikan tugas akhir saya selama
tetap mencantumkan nama saya sebagai penulis/pencipta dan sebagai pemilik Hak Cipta.
Demikian pernyataan ini saya buat dengan sebenarnya.
## Tangerang, 4 September 2025

## Wisnu Darmawan
## NIM. 11210910000109

## Nama  : Wisnu Darmawan
## Program Studi : Teknik Informatika
## Judul  : Perancangan Aplikasi Monitoring Hidroponik  Berbasis Mobile  Dengan
## Framework Flutter
## ABSTRAK

## Kata Kunci  :
## Jumlah Pustaka :
## Jumlah Halaman :


## Author  : Wisnu Darmawan
## Major  : Informatics Engineering
Title  : Designing a Mobile-Based Hydroponic Monitoring Application Using the
## Flutter Framework
## ABSTRACT

## Keywords  :
Number of Reference :
Number of Pages :


## KATA PENGANTAR

Alhamdullilahirobil'alamin.  Puji  serta  syukur  penulis  ucapkan  atas  kehadirat Allah
Subhanallahu wa Ta'ala yang telah melimpahkan rahmat dan nikmat-Nya sehingga penulis
dapat menyelesaikan Skripsi yang berjudul "Perancangan Aplikasi Monitoring Hidroponik
Berbasis Mobile Dengan Framework Flutter" dengan tepat waktu.
Penulis  juga  ingin  menyampaikan  terima  kasih  kepada  semua  pihak  yang  telah
memberikan bantuan selama pelaksanaan kuliah kerja lapangan hingga penyusunan laporan:
- Allah Subhanallahu wa Ta'ala, yang memberikan segala nikmat, ridho, dan karunia-
Nya kepada penulis.
- Bapak dan  Mama  tersayang,  yang  tidak  pernah  berhenti  mendoakan  dan
memberikan support yang luar biasa kepada penulis dalam setiap langkah.
- Bapak Husni Teja Sukmana, S.T., M.Sc, Ph.D, selaku Dekan Fakultas Sains dan
Teknologi dan Teknologi dan Dosen Pembimbing 1.
- Ibu Dr. Dewi Khairani, M.Sc., selaku Ketua Prodi Teknik Informatika Fakultas
## Sains.
- Ibu Nenny Anggraini, S.Kom, MT, selaku Dosen Pembimbing 2.
- Ketiga kakak penulis, Yonak Widatama, Winna Kusuma Dewi, dan Yulia Indah
Purnama Sari, yang selalu memberikan dukungan, serta semangat bagi penulis.
- Diri saya sendiri yang sudah berjuang dari awal perkuliahan hingga akhir, yang telah
menjadi teman setia dikala susah dan senang, yang tidak menyerah dengan keadaan,
kuat dan menguatkan, selalu bersemangat dan yakin bahwa semua pasti dapat dilalui
atas izin-Nya.
- [Nama] yang memberikan masukan, kerjasama, dan motivasi di dalam proyek ini.
- Keluarga dan teman-teman, yang telah menemani dan memberikan dukungan dalam
perjalanan penulis.
- Dan terima kasih kepada semua pihak yang telah berperan besar selama proses
penulisan skripsi ini, meskipun tidak bisa penulis sebutkan satu persatu. Rasa terima
kasih ini tetap sama besar dan tulusnya dari penulis.
Allah Subhanallahu wa Ta'ala agar segala usaha yang dilakukan dapat menjadi amal
baik, penghapus dosa, memberikan manfaat, serta mendapatkan balasan kebaikan di akhirat
nanti. Aamiin Ya Rabbal'alamin.

Setiap manusia tentunya memiliki celah untuk melakukan kesalahan. Begitupun dalam
penulisan skripsi ini yang masih jauh dari kata sempurna. Oleh karena itu, penulis sangat
terbuka jika ada kritik dan saran yang membangun dari pembaca sebagai bahan pembelajaran
dikemudian hari. Semoga skripsi ini dapat bermanfaat baik bagi penulis, serta para pembaca.

## Tangerang, 8 September 2025

## Wisnu Darmawan
## NIM. 11210910000109

## DAFTAR ISI


## DAFTAR GAMBAR

Gambar 2.1.............................................................................................................................. 24


## DAFTAR TABEL
Table 2.1 Literature Review .................................................................................................. 26
Table 3.2 .................................................................................. Error! Bookmark not defined.



## BAB I

## 1.1 Latar Belakang
Pesatnya  pertumbuhan  jumlah  penduduk  di  Indonesia  telah  mengakibatkan
berkembangnya  berbagai  aktivitas  ekonomi  dan  sosial,  yang  secara  langsung
meningkatkan  permintaan  terhadap  lahan.  Persaingan  dalam  pemanfaatan  lahan,
khususnya  di  wilayah  yang  tengah  berkembang,  telah  menyebabkan  terjadinya
penurunan luas lahan yang tersedia untuk sektor pertanian, seiring dengan peralihan
fungsi lahan untuk kebutuhan industri dan pemukiman (Rozci & Roidah, 2023). Kondisi
ini  menuntut  adanya  pencarian  solusi  alternatif,  Salah  satu  metode  modern  yang
diterapkan  dalam  pertanian  perkotaan  adalah  hidroponik,  yang  merupakan  teknik
bertanam tanpa menggunakan media tanah, yang dapat meningkatkan efisiensi dan
produktivitas dalam sektor pertanian (Exaudi et al., 2023).
Hidroponik merupakan teknik bercocok tanam tanpa menggunakan media tanah,
melainkan memanfaatkan larutan nutrisi yang mengandung unsur-unsur penting bagi
pertumbuhan tanaman. Keuntungan utama hidroponik adalah kemampuannya untuk
diterapkan di lahan yang sempit, efisiensi penggunaan air, pengurangan penggunaan
pestisida  kimia,  dan  produksi  tanaman  yang  lebih  berkualitas.  Oleh  karena  itu,
hidroponik  menjadi  alternatif  yang  menjanjikan  bagi  pertanian  perkotaan yang
berkelanjutan (Wardhana et al., 2020).
Meskipun memiliki banyak keunggulan, sistem hidroponik masih menghadapi
keterbatasan  dalam  proses  pemeliharaan  dan  kontrol  nutrisi.  Kesalahan  dalam
pengelolaan parameter lingkungan seperti suhu, kelembapan, pH air, dan kadar nutrisi
dapat menyebabkan kerusakan tanaman yang signifikan. Misalnya, pada praktik di
Forever Green Hydroponic Farm, terdapat kerusakan pakcoy hingga 32%, jauh di atas
batas toleransi 10% yang ditetapkan. Kerusakan ini dapat disebabkan oleh berbagai
faktor, seperti kesalahan dalam proses pemeliharaan, pemanenan, dan sortasi, serta
kurangnya pengetahuan tenaga kerja dalam menangani tanaman dengan baik (Rajhi,
## 2024).

Dalam praktik hidroponik konvensional, pengawasan terhadap faktor seperti
suhu, kelembapan, pH air, dan kadar nutrisi sering dilakukan secara manual, yang dapat
meningkatkan kemungkinan terjadinya kesalahan manusia. Kesalahan dalam mengatur
dan memonitor parameter-parameter ini dapat menyebabkan stres pada tanaman yang
pada akhirnya mengurangi kualitas dan kuantitas hasil panen. Dengan adanya teknologi
IoT  yang  memungkinkan  pemantauan  secara real-time,  kesalahan  tersebut  dapat
diminimalisir. IoT memungkinkan sensor untuk mengukur dan mengirimkan data secara
otomatis  ke  perangkat  pengguna,  sehingga  memungkinkan  pengelolaan  yang  lebih
efisien dan akurat (Anggraini et al., 2022).
Untuk  mengatasi  masalah  tersebut,  konsep Smart  Urban  Farming
diperkenalkan. Smart  Urban  Farming memanfaatkan  teknologi  seperti Internet  Of
Things (IoT),  otomatisasi,  dan  analisis  data  untuk  meningkatkan  efisiensi  dan
produktivitas sistem hidroponik. Dengan teknologi ini, parameter lingkungan dapat
dipantau dan dikontrol secara real-time melalui sensor yang terhubung ke perangkat
digital.  Keuntungan  dari  sistem  ini  meliputi  pengurangan  kesalahan  manusia,
peningkatan hasil panen, dan pengelolaan yang lebih terorganisir (Kullu et al., 2020).
Pemantauan yang efektif memegang peranan krusial dalam implementasi Smart
Urban Farming untuk memastikan tanaman tumbuh dalam kondisi yang optimal serta
meminimalkan potensi kegagalan hasil panen. Melalui pemantauan yang akurat dan real
time (Moghayedi et al., 2022), petani dapat mengidentifikasi permasalahan sejak tahap
awal, sehingga memungkinkan tindakan pencegahan yang lebih cepat. Oleh karena itu,
pemantauan yang efektif tidak hanya berkontribusi pada peningkatan  produktivitas
tanaman, tetapi juga pada efisiensi penggunaan sumber daya serta pengurangan dampak
negatif terhadap lingkungan pertanian di area perkotaan.
Berbagai penelitian telah dilakukan untuk mengembangkan aplikasi berbasis
IoT  pada  hidroponik.  Penelitian  pertama  yang  berhasil  peneliti  temukan  adalah
penelitian yang dilakukan oleh Yosua Yosephine Tarigan, Insan Taufik, Yulita Molliq
Rangkuti,  dan  Said  Iskandar  AI  Idrus  (2024),  dengan  judul  “Sistem Monitoring
Pertanian Hidroponik Berbasis Web Menggunakan Metode Waterfall (Studi Kasus PT.
Horti  Jaya  Lestari  Dokan)” (Tarigan  et  al.,  2024).  Pada penelitian  tersebut,
menggunakan sensor suhu, pH, dan kadar air nutrisi. Data tersebut ditampilkan melalui
website SIMONHIDRO.

Penelitian  kedua  dilakukan  oleh  Novia  Heriyani  dan  Siti  Ernawati  (2024),
dengan judul “Pemanfaatan Teknologi IoT Berbasis Mobile Dalam Upaya Monitoring
Kualitas Air Pada Tanaman Hidroponik” (Heriyani & Ernawati, 2024). Penelitian ini
bertujuan untuk pemantauan serta pengendalian larutan nutrisi hidroponik dari jarak
jauh tanpa berada di lokasi hidroponik. Dengan cara kerja mendeteksi suhu, tinggi air,
pH, serta nilai TDS pada larutan nutrisi secara realtime melalui Firebase. Pada aplikasi
nilai sensor akan ditampilkan sebagai data yang akan dimonitoring oleh pemilik. Dan
jika tinggi air terdeteksi melebihi tinggi maksimal air maka Arduino akan otomatis
menhidupkan pompa celup untuk membuang air.
Penelitian ketiga dilakukan oleh : Rizki Khusnul Adin (2021), dengan judul
“Rancang Bangun Sistem Monitoring Dan Otomasi Hidroponik Secara Internet  Of
Things (IoT) Menggunakan Arduino Nano” (Adin, 2021). Penelitian ini bertujuan untuk
merancang dan membangun sistem monitoring hidroponik berbasis IoT dan otomasi
dengan menggunakan Arduino Nano. Salah satu fokus utama dari penelitian ini adalah
untuk mengetahui nilai kalibrasi dan keakuratan dari alat uji yang digunakan, yaitu
sensor pH, sensor TDS (Total Dissolved Solids), dan sensor suhu. Selain itu, penelitian
ini juga bertujuan untuk mengevaluasi tampilan data sensor yang dikirim melalui modul
WiFi Node MCU ESP8266 ke aplikasi Blynk, yang dapat diakses secara real-time
melalui perangkat Android.
Berdasarkan  latar  belakang  yang  penulis  sampaikan  sebelumnya,  penulis
mengembangkan sebuah Aplikasi Fountaine: Aplikasi Monitoring Hidroponik Berbasis
Android Dengan Protokol MQTT. Sistem yang mengintegrasikan sensor DHT 22 untuk
suhu dan kelembapan udara, serta sensor TDS dan pH untuk memantau kondisi tanaman
secara real-time, sangat cocok diterapkan pada individu yang memiliki keterbatasan
ruang, seperti di apartemen atau rumah dengan area terbatas. Selain itu, sistem ini
memungkinkan pengelolaan yang efisien dan fleksibel melalui penerapan teknologi
Internet Of Things (IoT), yang memungkinkan pemantauan dan pengaturan secara jarak
jauh. Aplikasi yang penulis kembangkan memiliki berbagai fitur yang  mendukung
manajemen alat dalam sistem pertanian pintar. Pengguna diwajibkan untuk membuat
akun guna memastikan data yang dimasukkan terpisah dengan data pengguna lainnya.
Aplikasi  ini  juga  dilengkapi  dengan  fitur  untuk  menambahkan  alat  baru,  di  mana
pengguna diminta untuk mengisi formulir yang mencakup informasi seperti nama alat,
ID alat, dan tipe alat. Selain itu, pengguna dapat memilih alat yang ingin dipantau serta

menentukan  tanggal  untuk  melihat  data  atau  catatan  terkait.  Terdapat  pula  ikon
notifikasi yang menyampaikan informasi penting atau pembaruan terkait penggunaan
aplikasi.  Dengan  berbagai  fitur  ini,  aplikasi  FOUNTAINE  dirancang  untuk
mempermudah pengelolaan alat dan pemantauan data dalam konteks pertanian pintar.
Aplikasi FOUNTAINE diharapkan dapat memberikan solusi yang dalam memonitor
dan mengelola parameter-parameter penting dalam pertanian hidroponik secara efektif
dan efisien.
## 1.2 Rumusan Masalah
Berdasarkan latar belakang yang telah diuraikan, maka rumusan masalah pada
produk ini adalah
- Bagaimana  mengembangkan  aplikasi  Android  berbasis Flutter yang  dapat
mengintegrasikan teknologi IoT untuk monitoring sistem hidroponik.
- Bagaimana  sistem  dapat  memanfaatkan  protokol MQTT untuk  memastikan
komunikasi  yang  efektif  antara  perangkat  IoT  yang  digunakan  dalam  sistem
hidroponik dan aplikasi mobile yang digunakan untuk monitoring.
## 1.3 Batasan Masalah
Adapun ruang lingkup permasalahan yang akan dibahas dalam produk ini adalah
sebagai berikut:
## 1.3.1 Metode
- Aplikasi ini berfokus pada monitoring sistem hidroponik menggunakan sensor
TDS, sensor pH air, dan sensor dht 22.
- Penggunaan platform mobile berbasis Android untuk aplikasi.
## 1.3.2 Tools
- Alat pengembangan yang digunakan dalam aplikasi ini adalah Android Studio
dan Visual Studio Code.
- Desain awal aplikasi menggunakan Figma.
- Platform pengembangan yang dipilih adalah Android.

## 1.3.3 Output
- Output dari produk ini adalah aplikasi monitoring hidroponik pada platform
android.
## 1.4 Tujuan Penelitian
Tujuan dari produk ini adalah sebagai berikut:
- Merancang dan mengembangkan aplikasi FOUNTAINE yang dapat memantau
parameter lingkungan penting dalam sistem hidroponik, seperti kadar nutrisi,
suhu air, suhu udara, kadar pH larutan, dan ketinggian level air secara real-
time.
- Menguji efektivitas aplikasi dalam memantau kondisi sistem hidroponik secara
real-time.
## 1.5 Manfaat
Berdasarkan latar belakang masalah yang sudah dijelaskan, maka manfaat yang
diperoleh dari produk ini adalah:
## 1.5.1 Bagi Penulis
- Memenuhi salah satu persyaratan akademik dalam rangka penyelesaian studi
Strata 1 (S1) pada Program Studi Teknik Informatika, Fakultas Sains dan
Teknologi, UIN Syarif Hidayatullah Jakarta.
- Mengaplikasikan serta memperluas cakupan keilmuan yang telah diperoleh
selama masa perkuliahan dalam konteks praktis dan penelitian.
- Memperdalam  wawasan  penulis  dalam  perancangan  dan  pengembangan
aplikasi berbasis Android.
## 1.5.2 Bagi Universitas
- Berkontribusi dalam memperkaya khazanah literatur ilmiah di UIN Syarif
Hidayatullah Jakarta, khususnya bagi Fakultas Sains dan Teknologi dalam
bidang pertanian cerdas perkotaan  melalui implementasi berbasis Android.
- Menjadi rujukan akademik bagi mahasiswa lain dalam mengembangkan serta
melanjutkan  penelitian  yang  sejalan  dengan  topik  ini,  guna  meningkatkan
kualitas serta inovasi dalam ranah penelitian serupa.

- Produk ini  memiliki  potensi  untuk  memfasilitasi  terbentuknya  kemitraan
strategis  antara  universitas  dan  sektor  industri  yang  bergerak  di  bidang
pertanian cerdas, yang pada gilirannya akan mendukung implementasi aplikasi
praktis berdasarkan hasil penelitian ini.
## 1.5.3 Bagi Pembaca
- Memberikan  pemahaman  yang  lebih  mendalam  mengenai  implementasi
teknologi dalam konteks pertanian cerdas perkotaan, serta mengidentifikasi
potensi aplikasi praktis yang dapat mendukung transformasi sektor pertanian
menuju keberlanjutan dan modernisasi.
- Menyajikan  informasi  tentang  penerapan  inovasi  teknologi  terkini  dalam
sektor pertanian, yang diharapkan dapat memperbaiki efisiensi operasional
serta keberlanjutan jangka panjang dalam praktik pertanian.
- Menyediakan  peluang  bagi  pembaca  untuk  menggali  lebih  dalam  potensi
pertanian yang berbasis teknologi, yang memiliki kemampuan untuk menjadi
solusi yang efektif dalam mengatasi berbagai tantangan yang dihadapi oleh
sektor pertanian di kawasan urban.
## 1.6 Metodologi Penelitian
## 1.6.1 Metode Pengumpulan Data
- Studi Pustaka dan Literatur
Dalam pengembangan  produk ini,  sebagian  besar  data  pendukung
diperoleh melalui studi pustaka yang mencakup jurnal ilmiah, buku, dan artikel
terkait.
## 2. Observasi
Dalam pengembangan  produk ini, dilakukan  pengamatan  terhadap
aplikasi monitoring hidroponik sejenis.
## 1.6.2 Implementasi
## 1. Pengembangan Aplikasi Monitoring
Aplikasi  FOUNTAINE  dirancang  untuk  memantau  parameter
lingkungan pada sistem hidroponik secara otomatis dan real-time.

## 2. Metode Pengembangan
Metode  pengembangan  yang  penulis  gunakan  dalam  penelitian  ini
adalah System  Development  Life  Cycle (SDLC) model Waterfall. Tahapan
dalam model Waterfall yang digunakan oleh penulis meliputi:
## 1. Analisis Kebutuhan
## 2. Desain
## 3. Penulisan Program
## 4. Pengujian
## 5. Penerapan
## 1.7 Sistematika Penulisan
## BAB I  PENDAHULUAN
Bab ini meliputi sub bab seperti latar belakang penelitian, rumusan masalah, batasan
masalah, tujuan penelitian, manfaat penelitian, dan sistematika penulisan.
## BAB II TINJAUAN PUSTAKA DAN LANDASAN TEORI
Bab ini mencakup teori-teori dasar dan kajian literatur terkait topik penelitian serta
hasil-hasil dari penelitian sebelumnya yang relevan.
## BAB III METODOLOGI PENELITIAN
Bab ini menjelaskan cara mengumpulkan data melalui studi pustaka dan observasi, serta
metode  pengembang system,  termasuk  perancangan,  implementasi,  pengujian,  dan
optimasi.
## BAB IV ANALISIS,  DESAIN,  IMPLEMENTASI,  DAN  PENGUJIAN
## SISTEM
Bab  ini  menyajikan  hasil  dari  analisis,  perancangan,  implementasi  sesuai  dengan
metode yang dilakukan pada system yang dibuat, serta hasil pengujian.
## BAB V  HASIL DAN PEMBAHASAN
Bab ini menyajikan hasil-hasil penelitian yang telah diperoleh dari implementasi system
dan data yang dikumpulkan.
## BAB VI KESIMPULAN DAN SARAN

Bab ini menjelaskan kesimpulan dari penelitian yang telah dilakukan dan saran yang
diusulkan oleh peneliti untuk pengembangan lebih lanjut agar mencapai hasil yang lebih
baik.

## BAB II

## 2.1 Landasan Teori
## 2.1.1 Aplikasi
Aplikasi secara umum dapat dikategorikan ke dalam tiga platform utama,
yaitu desktop, web, dan mobile. Dari ketiga platform tersebut, aplikasi mobile
menonjol sebagai teknologi yang paling dominan, terutama dengan kemajuan
pesat dalam pengembangan smartphone yang semakin canggih (Yusril  et al.,
2021).  Dalam  konteks  transformasi  digital,  fenomena  ini  turut  mendorong
peningkatan  aksesibilitas  penggunaan  perangkat mobile (smartphone)  yang
berperan  signifikan  dalam  mempercepat  laju  pertumbuhan  teknologi  secara
berkelanjutan.  Pertumbuhan  pesat  ini,  seiring dengan  perkembangannya,
memberikan  dorongan  kuat  bagi  produsen smartphone untuk  menciptakan
aplikasi-aplikasi baru pada perangkat mobile guna memenuhi kebutuhan yang
terus berkembang dari pengguna. Setiap pengembangan aplikasi mobile tidak
terlepas dari perhatian terhadap dua aspek utama, yaitu antarmuka pengguna (user
interface) dan pengalaman pengguna (user experience), yang merupakan bagian
integral dari disiplin ilmu interaksi manusia dan komputer. Aplikasi mobile yang
dikembangkan dapat beroperasi pada dua platform utama, yaitu Android dan iOS
(Sufandi et al., 2022).
## 2.1.2 Android
Aplikasi Android merujuk pada perangkat lunak berbasis teknologi yang
dirancang untuk memfasilitasi interaksi pengguna dengan menyediakan beragam
fitur yang dapat diakses secara efisien. Aplikasi ini memungkinkan pengguna
untuk  mengakses  informasi  melalui  elemen  multimedia,  baik  audio  maupun
visual, dengan tujuan menciptakan pengalaman yang relevan dan sesuai dengan
kebutuhan pengguna. Aplikasi Android dirancang untuk meningkatkan kinerja
dan membantu pencapaian tujuan tertentu dengan cara yang intuitif dan mudah
dikelola oleh pengguna (Rahayu et al., 2022).

## 2.1.3 Hidroponik
Hidroponik adalah metode penanaman tanaman yang menggunakan air kaya
nutrisi sebagai pengganti tanah. Teknik ini semakin populer di daerah dengan
keterbatasan  sumber  daya  lahan  atau  air,  karena  hidroponik  memungkinkan
penggunaan air yang jauh lebih efisien dibandingkan pertanian konvensional.
Hidroponik juga memiliki keuntungan dalam mengurangi risiko penyakit yang
sering  terjadi  pada  tanah.  Keuntungan  lainnya  dari  hidroponik  termasuk
kemampuan  untuk  menanam  tanaman  di  ruang  kecil,  menghasilkan  tanaman
berkualitas lebih tinggi, dan mengurangi penggunaan pestisida. Oleh karena itu,
hidroponik memberikan solusi untuk meningkatkan ketahanan pangan, terutama
di daerah perkotaan dengan ruang pertanian terbatas (Syidiq et al., 2022). Dengan
demikian, sistem hidroponik sangat ideal untuk proyek-proyek yang memerlukan
kontrol  kualitas  lingkungan  yang  tepat,  seperti yang dimungkinkan  oleh
penggunaan aplikasi IoT untuk pemantauan tanaman.
## 2.1.4 Flutter
Flutter adalah  framework open-source  yang  digunakan  untuk  membuat
aplikasi lintas platform, yang dikembangkan oleh Google. Flutter memungkinkan
para pengembang untuk membangun aplikasi lintas platform dengan satu set kode
sumber, menggunakan bahasa pemrograman Dart (Tampubolon, 2023). Dengan
fitur "hot reload" dari Flutter, pengembang dapat melihat perubahan kode secara
langsung tanpa menghentikan aplikasi, yang menjadi salah satu fitur yang paling
menarik.  Selain  itu, Flutter menyederhanakan  proses  pembuatan  antarmuka
pengguna (UI) yang responsif dengan berbagai macam widget. Menurut (Aesyi et
al.,  2024),  salah  satu alasan  mengapa Flutter sangat  populer  di  kalangan
pengembang  adalah  karena  kemudahan  dalam  membangun  aplikasi  lintas
platform dengan efisiensi tinggi.
## 2.1.5 Dart
Dart adalah bahasa pilihan untuk mengembangkan aplikasi Flutter. Dart,
yang dikembangkan oleh Google, adalah bahasa pemrograman yang lebih mudah
dipelajari  oleh  pengembang  yang  memiliki  pengalaman  dengan  Java  dan
JavaScript karena kemiripan sintaksisnya. Dengan pustaka standar yang luas dan
dukungan  untuk  pemrograman  berorientasi  objek, Dart mempermudah

pengembangan aplikasi mobile (Tampubolon, 2023). Keuntungan penting dari
Dart adalah kemampuannya untuk dikompilasi menjadi kode native, yang sangat
meningkatkan performa aplikasi. Selain itu, tingkat kompatibilitas yang tinggi
antara Dart dan Flutter memfasilitasi pengembangan aplikasi yang cepat dan kaya
fitur (Alamsyah, 2023).
## 2.1.6 MQTT
MQTT (Message  Queue  Telemetry  Transport)  merupakan  protokol
komunikasi yang dirancang khusus untuk pertukaran data dalam sistem Internet
Of  Things (IoT).  Protokol  ini  memungkinkan  terjadinya  komunikasi  antara
perangkat, seperti perangkat Android dan sensor, dengan cara yang efisien dan
minim sumber daya. Dalam konteks penerapan teknologi ini, MQTT digunakan
untuk mentransmisikan data yang diperoleh dari sensor, baik sensor eksternal
maupun internal—yang terintegrasi dengan perangkat Android sebagai penerbit
(publisher) kepada pengguna yang memerlukan pemantauan perilaku pengguna
jalan melalui dasbor yang berfungsi sebagai penerima (subscriber). Keunggulan
protokol ini terletak pada kemampuannya untuk mendukung transfer data secara
real-time dan asinkron antara perangkat yang saling terhubung. MQTT sangat
ideal untuk aplikasi IoT yang memerlukan komunikasi yang efisien dan dapat
beroperasi pada berbagai jenis saluran komunikasi, baik yang berbasis broadband
maupun narrow-band (D’ortona et al., 2022).
## 2.1.7 Metode Waterfall
Model Waterfall pertama  kali  diperkenalkan  oleh Winston  Royce  pada
sekitar tahun 1970, sehingga sering dianggap sebagai model yang lebih kuno.
Meskipun  demikian,  model  ini  tetap  menjadi  salah  satu  yang  paling  banyak
diterapkan dalam bidang Rekayasa Perangkat Lunak (Software Engineering, SE)
hingga saat ini. Model Waterfall merupakan pendekatan pengembangan perangkat
lunak  yang  sistematis  dan  berurutan.  Dinamakan  "Waterfall"  karena  setiap
tahapan  dalam  proses  pengembangan  hanya  dapat  dimulai  setelah  tahapan
sebelumnya  selesai,  dan  berlangsung  secara  linear tanpa  kemungkinan  untuk
kembali ke tahapan sebelumnya. Dimulai dari tahap perencanaan, hingga akhirnya
pada  tahap  pemeliharaan,  model  ini  menekankan  urutan  yang  harus  dipatuhi
dalam pelaksanaan setiap tahapannya (Wahid, 2020).


## Gambar 2.1

Langkah-langkah dalam metode Waterfall adalah sebagai berikut:
## 1. Analisis Kebutuhan Sistem
Tahap  ini  dimulai  dengan  analisis  kebutuhan  untuk  mengidentifikasi
masalah  dan  tujuan  pengembangan  sistem. Tujuannya  adalah  untuk
meminimalkan potensi masalah yang bisa muncul di kemudian hari. Proses ini
melibatkan pengumpulan data, yang sering disebut analisis kebutuhan, termasuk
mencari dan meninjau literatur terkait. Data yang terkumpul kemudian dianalisis
untuk  memahami  secara  menyeluruh  kebutuhan  spesifik  pengguna  perangkat
lunak.
- Sistem dan Desain Perangkat Lunak
Pada tahap ini, desain sistem dan database dibuat berdasarkan hasil analisis
sebelumnya. Tujuannya adalah untuk membuat proses pengembangan menjadi
lebih mudah dan terfokus pada tujuan. Antarmuka (UI) dirancang agar menarik
dan  mudah  digunakan (user-friendly),  bahkan  bagi  pengguna  yang  awam.
Sementara  itu,  database  dirancang  untuk  menentukan  struktur,  tabel,  dan
kolomnya. Desain ini menjadi panduan yang memberikan gambaran menyeluruh
tentang arsitektur sistem perangkat lunak secara keseluruhan.
- Pembuatan dan Implementasi
Setelah desain selesai, tahap ini berfokus pada implementasi rencana dan
desain  ke  dalam  kode  program.  Proses  ini  melibatkan  pengkodean  untuk
memenuhi kebutuhan yang sudah dianalisis sebelumnya. Selanjutnya, perangkat

lunak  dibagi  menjadi  modul-modul  kecil  yang  akan  digabungkan  di  tahap
berikutnya. Bagian dari implementasi ini juga mencakup pengujian setiap modul
untuk memastikan mereka berfungsi sesuai dengan spesifikasi.
## 4. Pengujian
Di  tahap  ini,  modul-modul  yang  sudah  dikembangkan  diintegrasikan
menjadi satu sistem yang utuh. Pengujian sistem dilakukan secara komprehensif
untuk mengidentifikasi kesalahan atau cacat. Tujuan utama dari tahap ini adalah
untuk memastikan bahwa sistem berjalan dengan benar dan sesuai dengan proses
bisnis yang telah ditetapkan.
- Operasional dan Maintenance
Tahap  terakhir  ini  mencakup  pemeliharaan  sistem  untuk  memperbaiki
kesalahan  yang  mungkin  ditemukan  setelah  implementasi  dan  melakukan
peningkatan berdasarkan kebutuhan pengguna. Pemeliharaan ini juga memastikan
bahwa sistem dapat beroperasi dengan lancar bagi pengguna dan untuk terus
menemukan serta memperbaiki potensi kesalahan pemrograman.
## 2.2 Studi Literatur
Dalam penelitian ini, studi literatur digunakan sebagai metode pengumpulan
data utama. Berikut adalah tabel yang membandingkan penelitian ini dengan studi-studi
literatur sebelumnya yang relevan, yang diambil dari jurnal-jurnal dalam lima tahun
terakhir :

## Table 2.1
## No. Judul Penelitian Peneliti
## Metode
## Pengembangan
## Bahasa
## Pemrograman
## Basis
## Sistem
## IOT
## Fitur
## Notifikasi
## Metode Pengujian
## Sistem Usability
## 1.
Aplikasi IoT Pada
## Sistem Kontrol
dan Monitoring
## Tanaman
## Hidroponik

## (2022)
## Muhammad
## Maftuh Fuad
## Fatori
## - - Android - - - -
## 2.
Aplikasi IoT Pada
## Sistem Kontrol
dan Monitoring
## Tanaman
## Hidroponik

## (2021)
## Dicky Theo
## Syafei, Richa
## Watiasih
## - - Android Blynk - - -
## 3.
## Mobile Untuk
## Monitoring
## Tanaman
## Muhammad
## Fachrie
Research and
## Development
## (R&D)
## - Android
## Thingspeak,
## Firebase

## Black Box
## Testing
## -

## Hidroponik
## Kangkung
## Berbasis
Thingspeak dan
## Firebase

## (2023)
## 4.
## Automatic
## Monitoring
## System For
## Hydroponic
## Farming: Iot-
## Based Design And
## Development

## (2022)
## Huu Cuong
## Nguyen, Bich
## Thuy Vo Thi,
## Quang Hieu
## Ngo
Research and
## Development
## (R&D)
## - Website
ZigBee,
LoRa,
Node-RED
## -
## Black Box
## Testing
## -
## 5.
Design and
Implementation of
## Smart
## Hydroponics
## Farming Using
## S. V. S.
## Ramakrishnam
## Raju, Bhasker
## Dappuri, P.
## Ravi Kiran
## - - Android - -
## Black Box
## Testing
## -

IoT-Based AI
Controller with
## Mobile
## Application
## System

## (2022)
## Varma, Murali
## Yachamaneni,
## D. Marlene
## Grace
## Verghese,
## Manoj Kumar
## Mishra
## 6.
## Intelligent
Monitoring and
## Controlling
System for
## Hydroponics
## Precision
## Agriculture

## (2019)
## Herman, Nico
## Surantha
## - - Android
## MQTT,
## Blynk
## -
## Black Box
## Testing
## -
## 7.
## Monitoring Sistem
## Otomatisasi
## Hidroponik
## Berbasis Mobile
## Tholib
## Hariono,
## Lailatul Fitri
## Fajriyah
## Waterfall
JavaScript,
## PHP
Android MQTT

## Black Box
## Testing
## -


## (2021)
## 8.
## Rancang Bangun
## Aplikasi Mobile
## Berbasis Internet
## Of Things Untuk
## Pemantauan
## Nutrisi Tanaman
## Selada Hidroponik

## (2020)
## M Rizki
## Juanda
Prototype JavaScript Android Firebase

## Black Box
## Testing
## -
## 9.
## Smartcropplanting:
IOT-Based Mobile
Application for
## Hydroponic
## System

## (2023)
## Sung Jun Kyu,
## Chit Su Mon,
## Kasthuri
## Subaramaniam
## - - Android - - - -

## 10.
The application of
IoT-based
hydroponic system
and solar power to
increase
agricultural
production and
horticultural crop
productivity

## (2022)
## Irvan Hermala,
## Agus Ismail,
## Nur Hendrasto
## , Azqia
## Maulida
## Darda, Syukur
## Daulay
Research and
## Development
## (R&D)
## - Android Firebase -
## Black Box
## Testing
## -
## 11.
## Perancangan
## Aplikasi
## Monitoring
## Hidroponik
## Berbasis Mobile
## Dengan
## Framework
## Flutter
## Wisnu
## Darmawan
## Waterfall Dart Android
## MQTT,
## Firebase

## Black Box
## Testing,
## User
## Acceptance
## Testing
## (UAT)
## System
## Usability
## Scale
## (SUS)


Berdasarkan analisis studi literatur lima tahun terakhir (Tabel 2.1), penelitian ini menonjol dalam beberapa aspek. Pertama, basis sistemnya yang
mengintegrasikan MQTT atau Firebase dan fitur notifikasi merupakan pendekatan yang jarang dijumpai. Kedua, metodologi pengujian usability
menggunakan System Usability Scale (SUS) adalah hal baru dalam konteks studi sejenis, karena belum ada literatur yang tercatat menggunakan
metode evaluasi ini. Terakhir, pemilihan bahasa pemrograman Dart juga menjadi pembeda signifikan, mengingat tidak ada penelitian lain dalam
tabel yang menggunakan bahasa tersebut.

## BAB III

## 3.1 Metode Pengumpulan Data
Pengumpulan data dilakukan melalui studi literatur untuk memperkuat desain
dan arsitektur aplikasi. Proses ini melibatkan peninjauan sumber-sumber ilmiah dan
referensi relevan yang berhubungan, baik secara langsung maupun tidak langsung,
dengan aplikasi yang sedang dikembangkan.
## 3.1.1 Studi Literatur
Metode  ini  berfokus  pada  eksplorasi  dan  pengumpulan  referensi  yang
kredibel, seperti jurnal, buku, paper, dan situs web terpercaya. Informasi yang
didapat kemudian diolah untuk menyusun latar belakang, landasan teori, serta
panduan untuk tahapan implementasi dan pengujian aplikasi.
## 3.2 Metode Pengembangan Sistem
Pengembangan aplikasi ini mengadopsi model Waterfall, yang dibagi menjadi
lima tahapan utama: analisis kebutuhan, desain, pengembangan (coding), pengujian,
dan implementasi (deployment). Berikut adalah rincian dari setiap tahapan:
3.2.1 Analisa Kebutuhan (Requirement Analysis)
Tahap ini dimulai dengan analisis kebutuhan pengguna (user requirements)
terhadap sistem yang akan dibangun. Setelah data dikumpulkan melalui kuesioner,
kami menentukan hak akses dan peran pengguna.

## Kode Isi Pertanyaan
## Q1
Saya  membutuhkan  aplikasi  untuk  memantau
kondisi tanaman hidroponik secara real-time.
## Q2
Saya ingin aplikasi dapat menampilkan data sensor
pH, suhu, kelembapan, dan TDS dengan jelas.
## Q3
Saya  memerlukan  fitur  notifikasi  otomatis  jika
kondisi tanaman tidak normal.
## Q4
Saya membutuhkan riwayat data sensor agar dapat
memantau perkembangan tanaman.

## Q5
Saya ingin aplikasi memiliki tampilan antarmuka
yang sederhana dan mudah digunakan.
## Q6
Saya  berharap  aplikasi  dapat  menambah  atau
menghapus alat (kit) secara fleksibel.
## Q7
Saya ingin bisa memantau kondisi hidroponik dari
jarak jauh melalui internet.
## Q8
Aplikasi sebaiknya menyediakan fitur login agar
data pengguna terpisah dan aman.
## Q9
Saya menginginkan aplikasi yang responnya cepat
dan tidak mudah error.
## Q10
Aplikasi  yang  dibuat  harus  dapat  digunakan  di
perangkat Android versi terbaru.
Selanjutnya, dilakukan analisis  kebutuhan  sistem  dengan  membuat
deskripsi umum aplikasi, mendefinisikan fitur-fitur, menganalisis sistem yang ada
(as-is  system),  dan  merancang  sistem  usulan  (to-be  system).  Tahap  ini  juga
mencakup analisis kebutuhan hardware dan software yang diperlukan.
## 3.2.2 Desain
Pada  tahap  ini, dilakukan  perancangan arsitektur  sistem  menggunakan
Unified  Modeling  Language (UML),  termasuk use  case  diagram, activity
diagram, sequence diagram, dan class diagram.
Selanjutnya, dilakukan perancangan skema database menggunakan SQLite.
Tahap  desain  diakhiri  dengan  pembuatan  desain  antarmuka  pengguna  (UI).
Selanjutnya, mulai  dengan  membuat wireframe untuk  kerangka  dasar,  lalu
dilanjutkan dengan desain prototype yang lebih detail, termasuk pemilihan skema
warna, ikon, dan tata letak yang akan diimplementasikan pada aplikasi.
3.2.3 Penulisan Program (Coding)
Tahap development merupakan tahap pengkodean aplikasi sesuai dengan
requirement  dan  desain  yang  telah  dirancang  dan  disepakati. Proses  dimulai
dengan  membangun  REST  API  sebagai  backend  untuk  memungkinkan
komunikasi  antara  aplikasi  dengan  database.  API  ini  dibuat  menggunakan
JavaScript dengan runtime Node.js versi 20.11.0, sementara MySQL digunakan
sebagai DBMS.

Selanjutnya, penulis melanjutkan dengan pengembangan aplikasi mobile
untuk  sistem  operasi  Android.  Aplikasi ini  dibangun  menggunakan  bahasa
pemrograman Dart versi 3.9.2, framework flutter versi 3.35.3, Android SDK versi
36 (API level 36), proses pengembangan dilakukan menggunakan Visual Studio
Code versi 1.104.0 sebagai code editor, sedangkan Android Studio Narwhal versi
2025.1.1 Patch 1 digunakan sebagai IDE resmi untuk kompilasi, debugging, dan
integrasi Flutter.
3.2.4 Pengujian (Testing)
Setelah  pengembangan  selesai, dilakukan pengujian  aplikasi.  Pengujian
dimulai dengan unit testing pada setiap endpoint REST API untuk memastikan
respon  yang  diberikan  sesuai  dengan  permintaan  (request)  yang  dikirim.
Selanjutnya, dilakukan pengujian Black Box Testing pada aplikasi mobile. Metode
ini berfokus pada fungsionalitas aplikasi dengan memeriksa input dan output.
Selanjutnya, menguji semua fitur berdasarkan skenario use case, mengidentifikasi
kesalahan antarmuka, serta memastikan input dan output berjalan sesuai harapan.
Tahap  pengujian  diakhiri  dengan User Acceptance  Testing (UAT)  yang
melibatkan pengguna akhir secara langsung. UAT dilakukan melalui kuesioner
yang  berisi  verifikasi  fitur-fitur  aplikasi.  Setelah  kuesioner  disebar  kepada
pengguna akhir [aplikasi], hasilnya dianalisis untuk memastikan penerimaan fitur
oleh pengguna.
User Acceptance Test (UAT) dilakukan dengan cara menyebar kuesioner
online kepada end-user dengan pendampingan setelah mencoba aplikasi CMMS
mobile. Selanjutnya hasil kuesioner dianalisis, untuk mendapatkan hasil apakah
fitur aplikasi dapat diterima oleh user dengan baik.
## Kode Isi Pertanyaan
## Q1
Aplikasi mudah digunakan untuk login dan navigasi antar
halaman.
Q2 Tampilan aplikasi menarik dan mudah dipahami.


Aplikasi yang berhasil diuji, selanjutnya dideploy kedalam bentuk aplikasi
yang dapat di install langsung pada perangkat pengguna. Aplikasi android dibuat
dalam bentuk package file .apk yang dapat digunakan dengan jaringan internet.
## 3.2.5 Pemeliharaan
Pada tahap ini, pemeliharaan aplikasi dilakukan secara berkala. Salah satu
kegiatan utamanya adalah pencadangan data (backup) rutin pada server setiap
bulan.
3.3 System Usability Scale (SUS)
Penulis melakukan usability  testing menggunakan  metode System  Usability
Scale (SUS). Metode ini digunakan untuk mengukur tingkat kemudahan penggunaan
aplikasi. Kuesioner SUS yang berisi 10 pertanyaan disebarkan kepada pengguna akhir
yang  telah  mencoba  aplikasi.  Pertanyaan  ganjil  memiliki  nada  positif,  sementara
pertanyaan genap bernada negatif. Skala Likert yang digunakan memiliki 5 poin, dengan
deskripsi untuk setiap nilai yaitu, STS (Sangat Tidak Setuju - 1), TS (Tidak Setuju-2),
N (Netral-3), S (Setuju -4), SS (Sangat Setuju - 5).
## Q3
Data sensor (pH, suhu, TDS, kelembapan) tampil dengan
jelas dan real-time.
Q4 Fitur menambahkan alat (kit) berfungsi dengan baik.
## Q5
Fitur notifikasi berjalan dengan benar saat kondisi tertentu
terjadi.
## Q6
Fitur riwayat data dan pemilihan tanggal mudah diakses
dan dipahami.
Q7 Aplikasi stabil dan tidak sering error saat digunakan.
Q8 Fitur hapus perangkat bekerja sesuai harapan.
## Q9
Aplikasi  membantu  pengguna  dalam  memantau  sistem
hidroponik secara efektif.
## Q10
Aplikasi  telah  menyediakan  fitur  yang  saya  butuhkan
untuk kebutuhan monitoring hidroponik.


## Kode Isi Pertanyaan
Q1 Saya pikir akan sering menggunakan fitur pada aplikasi ini.
Q2 Menurut saya aplikasi ini terlalu rumit untuk digunakan.
Q3 Aplikasi ini sangat mudah digunakan.
## Q4
Saya rasa saya membutuhkan bantuan dari seseorang untuk
dapat menggunakan aplikasi ini.
## Q5
Saya  pikir fitur-fitur  dalam  aplikasi  ini  sudah  terintegrasi
dengan baik dalam system.
Q6 Saya pikir dalam aplikasi ini banyak hal yang tidak konsisten.
## Q7
Saya  rasa  mayoritas  pengguna  dapat  mempelajari  cara
menggunakan aplikasi ini dengan cepat.
Q8 Saya merasa aplikasi ini sangat sulit digunakan.
Q9 Saya merasa nyaman menggunakan aplikasi ini.
## Q10
Saya  perlu  belajar  banyak  hal  sebelum  saya  dapat
menggunakan aplikasi ini.

## 3.4 Alur Penelitian
Alur  penelitian  ini  (Gambar  3.1)  dimulai  dengan identifikasi  masalah,
dilanjutkan  dengan  pengumpulan  data  melalui  studi  literatur.  Setelah  itu, penulis
memilih metode Waterfall sebagai pendekatan pengembangan. Setiap tahapan Waterfall
(mulai dari requirement, design, development, testing, deployment, dan maintenance)
dilaksanakan  secara  berurutan.  Di  akhir, penulis melakukan  pengujian  kualitas
perangkat lunak pada aspek usability menggunakan System Usability Scale (SUS).





## BAB IV

## 4.1 Requirement
Dalam tahap pengumpulan kebutuhan sistem, penulis tidak melakukan observasi
langsung, melainkan menggunakan metode studi literatur terhadap berbagai penelitian
dan jurnal yang membahas sistem monitoring dan otomatisasi hidroponik berbasis IoT.
Studi literatur ini bertujuan untuk mengidentifikasi fitur umum yang digunakan dalam
sistem serupa, kemudian dikembangkan menjadi sistem yang lebih adaptif melalui
penerapan metode Fuzzy logic dan Machine Learning (ML) guna meningkatkan akurasi
analisis kondisi lingkungan tanaman hidroponik.
Berdasarkan hasil studi literatur, beberapa penelitian sebelumnya masih terbatas
pada aspek monitoring dan automasi sederhana, seperti pemantauan suhu, kelembapan,
pH, dan TDS secara real-time tanpa adanya sistem analisis cerdas. Oleh karena itu,
dalam  penelitian  ini  penulis  merancang  sistem  yang  tidak  hanya  melakukan
pemantauan, tetapi juga memberikan prediksi dan rekomendasi perawatan tanaman
secara otomatis menggunakan pendekatan berbasis kecerdasan buatan.
Hasil analisis literatur dan pengembangan sistem dijelaskan dalam tabel 4.1
berikut.
## Fitur Penelitian A Penelitian B Penelitian C Fountaine
## Monitoring
## ✓
## Automasi Pompa Air &
pH

## ✓
## Notifikasi Kondisi
## Abnormal

## ✓
## Dashboard Realtime
## ✓
## Riwayat Data Sensor
## ✓
Integrasi IoT
(MQTT/Firebase)

## ✓

## Fuzzy Logic
## ✓
## Machine Learning
## ✓
## Penyesuaian Otomatis
## Berdasarkan Prediksi

## ✓
## Multi User &
## Authentification

## ✓
## Manajemen Alat
(Add/Delete Device)

## ✓
Dari tabel 4.1 dapat disimpulkan bahwa aplikasi FOUNTAINE yang diusulkan
memiliki beberapa keunggulan dibandingkan penelitian sebelumnya, di antaranya:
- Implementasi Fuzzy Logic untuk  menginterpretasi  kondisi  lingkungan
tanaman secara dinamis berdasarkan data sensor.
- Penerapan Machine  Learning untuk  menganalisis  pola  pertumbuhan  dan
memberikan prediksi kondisi tanaman.
- Penambahan  fitur  notifikasi  pintar  yang  menyesuaikan  tingkat urgensi
berdasarkan hasil analisis sistem.
- Dukungan  terhadap multi-user system dengan  autentikasi  agar  data  tiap
pengguna tetap terpisah dan aman.
- Arsitektur sistem yang fleksibel berbasis protokol MQTT untuk komunikasi
data real-time antara perangkat dan aplikasi.
Dengan  demikian,  tahap requirement ini  menjadi  dasar  dalam  pengembangan
sistem  FOUNTAINE  agar  mampu  memberikan  solusi  yang  lebih  akurat,  efisien,  dan
cerdas dalam pengelolaan sistem hidroponik berbasis IoT.
## 4.1.1 Analisis Kebutuhan Pengguna
## 4.1.1.1 Pengguna
Dalam  aplikasi FOUNTAINE,  terdapat satu  jenis  pengguna  utama,
yaitu user (petani hidroponik) yang berperan sebagai pihak yang melakukan
pemantauan  dan  pengelolaan  sistem  hidroponik  secara  langsung.
user memiliki tanggung jawab untuk memantau parameter lingkungan seperti

suhu udara, kelembapan udara, kadar pH air, serta nilai TDS secara real-time
melalui antarmuka aplikasi mobile.
Selain itu, pengguna juga dapat melihat riwayat data sensor, menerima
notifikasi  otomatis  jika  kondisi  lingkungan  berada di  luar  ambang  batas
optimal, serta memperoleh rekomendasi berbasis fuzzy logic dan machine
learning untuk tindakan korektif seperti penyesuaian nutrisi atau pengaturan
sirkulasi air.
Fitur  yang  disediakan  aplikasi  juga  memungkinkan  pengguna
menambahkan  atau menghapus perangkat  (kit)  secara fleksibel, sehingga
sistem dapat disesuaikan dengan jumlah instalasi hidroponik yang mereka
miliki.
Aplikasi FOUNTAINE dirancang agar setiap pengguna memiliki data
yang unik,  aman,  dan  tidak  saling  bercampur,  mengingat setiap  akun
terhubung langsung ke perangkat IoT melalui protokol MQTT.

## 4.1.1.2 Hak Akses Pengguna
Hak akses pengguna pada aplikasi FOUNTAINE dijelaskan dalam tabel
4.2 berikut.
## No Pengguna Status Hak Akses
## 1 User User
− Melakukan login dan registrasi akun.
− Menambahkan   atau   menghapus
perangkat monitoring (kit).
− Melihat data sensor suhu, kelembapan,
pH, dan TDS secara real-time.
− Melihat  grafik  riwayat  data  sensor
(harian, mingguan, dan bulanan).
− Menerima  notifikasi  otomatis  saat
kondisi tanaman tidak normal.
− Mendapatkan rekomendasi penyesuaian
kondisi berdasarkan fuzzy logic.

− Melihat hasil analisis tren pertumbuhan
tanaman   menggunakan machine
learning.
− Menyimpan  dan  mengunduh  laporan
hasil monitoring pribadi.
− Mengatur  ambang  batas  (threshold)
pribadi  untuk  parameter  lingkungan
sesuai kebutuhan tanaman.
Akses  pengguna  dalam  sistem  FOUNTAINE  bersifat  personal  dan
terdistribusi, di mana setiap user hanya dapat mengakses data dari perangkat
miliknya sendiri. Hal ini memastikan keamanan serta keakuratan data yang
diterima, sekaligus menjaga privasi antar pengguna.
4.1.2 Analisis Kebutuhan Perangkat Lunak (Software Requirements)
## 4.1.2.1 Nama Software
Aplikasi  yang  dikembangkan  dalam  penelitian  ini  bernama
FOUNTAINE (Smart Hydroponic Monitoring System).
Nama  ini  berasal  dari  kata  Fountain  yang  berarti  aliran  air,
mencerminkan konsep utama dari sistem hidroponik yang memanfaatkan
sirkulasi  air  sebagai  media  tumbuh  tanaman. Aplikasi  ini  berfokus  pada
pemantauan  kondisi  lingkungan  hidroponik  secara real-time dengan
dukungan analisis fuzzy logic dan machine learning (ML).
## 4.1.2.2 Penjelasan Umum Software
Aplikasi  FOUNTAINE  merupakan  sistem  berbasis mobile yang
berfungsi untuk memantau kondisi lingkungan hidroponik secara otomatis
menggunakan sensor Internet of Things (IoT).
Sensor yang digunakan meliputi:
- Sensor DHT22 untuk mengukur suhu dan kelembapan udara,
- Sensor TDS untuk mendeteksi kadar nutrisi larutan.
- Sensor pH meter untuk mengukur tingkat keasaman air.
- Sensor Higrometer untuk mengukur kelembaban.

Data dari sensor dikirim secara berkala melalui protokol MQTT ke
aplikasi  mobile  berbasis  Flutter,  dan  hasil  pembacaan  tersebut  disajikan
dalam bentuk tampilan real-time serta grafik historis.
Aplikasi  juga  menerapkan fuzzy  logic untuk menentukan  kategori
kondisi tanaman (baik, cukup, buruk) berdasarkan nilai sensor, serta machine
learning  yang  berfungsi  menganalisis  pola  tren  pertumbuhan  dan
memberikan prediksi kondisi berikutnya.
Selain itu, sistem dilengkapi fitur notifikasi pintar (smart alert) yang
akan memberi tahu pengguna jika parameter lingkungan melewati ambang
batas normal.
Dengan  demikian,  pengguna  dapat  melakukan  tindakan  preventif
secara cepat dan tepat dalam menjaga kestabilan sistem hidroponik mereka.
## 4.1.2.3 Fitur Aplikasi
Aplikasi FOUNTAINE memiliki beberapa fitur utama yang dirancang
untuk memudahkan pengguna dalam melakukan monitoring, analisis, dan
pengelolaan sistem hidroponik secara real-time. Penjelasan fitur dapat dilihat
pada tabel 4.2 berikut.
## No Fitur Uraian
## 1 Login
Fitur ini digunakan pengguna untuk masuk ke
dalam  aplikasi  dengan  akun  terdaftar.  Data
pengguna disimpan secara aman menggunakan
sistem autentikasi berbasis Firebase.
## 2 Halaman Home
Menampilkan  ringkasan  kondisi  hidroponik
secara keseluruhan  seperti  suhu,  kelembapan,
pH, dan TDS dalam bentuk tampilan real-time.
Juga terdapat status analisis fuzzy dan prediksi
ML di bagian atas layar.
## 3 Halaman Addkit
Berfungsi untuk menambahkan perangkat IoT
baru  (kit monitoring)  dengan  mengisi  ID
perangkat,  nama,  dan  tipe  sensor  yang

digunakan. Fitur ini memungkinkan pengguna
mengelola lebih dari satu sistem hidroponik.
## 4 Halaman Monitor
Menampilkan hasil pembacaan sensor secara
langsung dari sistem hidroponik, termasuk
visualisasi data dalam bentuk grafik dinamis
serta status “Normal”, “Warning”, atau
“Critical” berdasarkan hasil fuzzy logic.

## 5 Halaman History
Menampilkan riwayat data sensor dalam bentuk
tabel dan grafik berdasarkan tanggal tertentu.
Data ini juga digunakan sebagai dataset untuk
analisis machine learning.
## 6
## Halaman
## Notification
Memberikan  notifikasi  otomatis  kepada
pengguna jika terdapat kondisi lingkungan yang
melebihi  ambang  batas  ideal,  misalnya  pH
terlalu rendah atau TDS di bawah standar.
## 7 Halaman Setting
Berisi pengaturan aplikasi seperti penggantian
ambang  batas  parameter  (threshold),  tema
tampilan, dan pengaturan preferensi notifikasi.
## 8 Halaman Profile
Menampilkan informasi akun pengguna seperti
nama,  email,  dan  daftar  perangkat  yang
terhubung. Pengguna juga dapat keluar (logout)
dari aplikasi melalui halaman ini.

## 4.1.2.4 Perangkat Penelitian
Perangkat yang digunakan dalam pembuatan aplikasi FOUNTAINE
terdiri dari dua bagian, yaitu perangkat hardware dan software.
Rincian perangkat yang digunakan dapat dilihat pada tabel berikut.
## Device Keterangan

Laptop Advan Laptop Ryzen 5 6600H, RAM 16 GB, SSD 512
## GB
## Processor
AMD Ryzen 5 6600H (6 core, 12 thread, 3.3–4.5 GHz)

Memory RAM 16 GB DDR5
## Storage
SSD NVMe 512 GB

Smartphone Poco X3 GT

## Software Keterangan
PC OS Windows 11 Pro 64-bit
Mobile OS
## Android 13

## Bahasa
## Pemrograman
Dart v.3.8.1
Framework Flutter v.3.35.3
## Backend
## Server
## Firebase
Database SQLite
## Protocol
## Komunikasi
MQTT (Mosquitto Broker)
IDE  /  Text
## Editor
Visual Studio Code 1.104.0 dan Android Studio Narwhal
## 2025.1.1
Library cupertino_icons,    firebase_core,    firebase_auth,
firebase_messaging, cloud_firestore, firebase_analytics,
MQTT_client,   fl_chart,   flutter_riverpod,   intl,
url_launcher, flutter_dotenv, firebase_app_check, rxdart,
http, dio, sqflite, path, crypto, uuid
## Testing Tool Postman
SDK Android Android SDK API Level 36

Berdasarkan hasil analisis kebutuhan fitur dan perangkat penelitian,
langkah  berikutnya  adalah  melakukan perancangan  sistem  dan  aplikasi
mobile untuk menggambarkan alur kerja, struktur sistem, dan integrasi antara
komponen perangkat IoT dengan aplikasi FOUNTAINE.
## 4.2 System & Mobile App Design
Pada tahap ini penulis melakukan perancangan sistem aplikasi FOUNTAINE
(Smart Hydroponic Monitoring System) yang bertujuan untuk menggambarkan struktur
logika  dan  alur  kerja  antara  pengguna,  perangkat  IoT,  dan  aplikasi mobile. Tahap
perancangan  ini dilakukan  berdasarkan  hasil  analisis  kebutuhan  pengguna  dan
perangkat lunak yang telah dijelaskan pada tahap sebelumnya.
Proses  perancangan  ini  meliputi  pembuatan  rancangan  sistem,  arsitektur
aplikasi,  serta  desain  antarmuka  pengguna  yang  menjadi  acuan  dalam  tahap
implementasi. Desain sistem mencakup interaksi antar komponen seperti sensor IoT,
Raspberry Pi sebagai gateway, MQTT broker, server API, database, dan aplikasi mobile
## Flutter.
Sistem  FOUNTAINE  dirancang  untuk  bekerja  secara real-time,  di  mana
perangkat  sensor  membaca  data  lingkungan  tanaman  hidroponik  kemudian
mengirimkan hasilnya melalui protokol MQTT ke broker. Selanjutnya, data tersebut
diteruskan ke server REST API untuk diproses dan disimpan di basis data SQLite.
Aplikasi mobile akan mengambil data dari server menggunakan format JSON response
untuk ditampilkan kepada pengguna.
Selain menampilkan data sensor secara langsung, aplikasi juga menjalankan
modul analisis berbasis fuzzy logic untuk menentukan status kondisi tanaman (baik,
cukup, atau buruk), serta modul machine learning yang berfungsi untuk memprediksi
tren perubahan parameter lingkungan berdasarkan pola historis.
Hasil analisis tersebut ditampilkan dalam bentuk grafik interaktif serta notifikasi
cerdas  untuk  membantu  pengguna  mengambil  keputusan  cepat  dalam  pengelolaan
sistem hidroponik.

Pada gambar 4.4 dijelaskan bahwa pengguna melakukan input melalui aplikasi
FOUNTAINE pada perangkat mobile yang telah terhubung dengan sistem IoT. Aplikasi
mengirimkan permintaan (request) ke API server menggunakan metode HTTP, dan

server memberikan response berupa data sensor, status fuzzy, dan hasil analisis machine
learning dalam format JSON.
Data yang diterima kemudian ditampilkan pada aplikasi dalam bentuk grafik,
nilai  numerik,  serta  notifikasi  pintar.  Mekanisme  ini  memungkinkan  sistem  untuk
melakukan  pemantauan  kondisi  lingkungan  secara  otomatis,  efisien,  dan real-time
melalui perangkat mobile.
Berdasarkan hasil rancangan interaksi pengguna dan sistem tersebut, langkah
selanjutnya  adalah  melakukan  perancangan  sistem  secara  terstruktur  menggunakan
diagram UML (Unified Modeling Language), yang mencakup use case diagram, activity
diagram, sequence diagram, dan class diagram untuk memvisualisasikan alur kerja
sistem secara menyeluruh.
## 4.2.1 Perancangan Arsitektur Sistem
Dalam  tahap  ini  penulis  melakukan  perancangan  sistem  menggunakan
diagram  UML  (Unified  Modeling  Language).  UML  digunakan  untuk
memvisualisasikan hubungan antar komponen dan alur proses yang terjadi di
dalam sistem FOUNTAINE.
Tahap  ini  bertujuan  untuk  menggambarkan  interaksi  antara  pengguna,
perangkat  IoT,  server,  serta  aplikasi mobile agar sistem  dapat  dikembangkan
secara terstruktur dan mudah dipahami.
Perancangan  sistem  ini  juga  berfungsi  untuk  mendefinisikan  kebutuhan
fungsional  dan  logika  kerja  aplikasi  berdasarkan  hasil  analisis  sebelumnya.
Melalui  UML,  seluruh  komponen  sistem  dapat  digambarkan  secara  visual
sehingga hubungan antar bagian sistem menjadi lebih jelas.
Dalam penelitian ini, penulis menggunakan beberapa jenis diagram UML,
yaitu use case diagram, activity diagram, sequence diagram, dan class diagram.
Masing-masing  diagram  memiliki  fungsi  tersendiri  dalam  menjelaskan
bagaimana  pengguna  berinteraksi  dengan  aplikasi,  bagaimana  alur  aktivitas
sistem berjalan, bagaimana proses pertukaran data antar komponen terjadi, serta
bagaimana struktur kelas dibentuk pada sistem.
Dengan adanya rancangan sistem ini, proses implementasi dapat dilakukan
dengan  lebih  terarah  karena  setiap  komponen  telah  memiliki  fungsi  dan

keterhubungan  yang  terdefinisi  dengan  baik.  Selain  itu,  dokumentasi  visual
melalui UML juga mempermudah tahap pengujian dan pengembangan sistem di
masa mendatang.
## 4.2.1.1 Use Case Diagram
Use  Case  Diagram pada  aplikasi  FOUNTAINE  digunakan  untuk
menggambarkan  bagaimana  pengguna  berinteraksi  dengan  sistem  dalam
melakukan aktivitas monitoring dan pengelolaan data hidroponik. Diagram
ini menunjukkan fungsi-fungsi utama yang dapat dilakukan oleh pengguna
serta alur komunikasi antara aplikasi mobile dengan komponen sistem lainnya
seperti broker MQTT, auth, dan database.

Pada table terdapat penjelasan deskripsi setiap fungsi dalam use case
diagram yang telah dirancang.
## No Use Case Deskripsi Aktor
1 Login Kegiatan  actor  untuk  masuk
kedalam aplikasi
menggunakan  username  dan
## User

password    yang    telah
diberikan.
2 Monitor Fitur  untuk  melihat  data
sensor  tanaman  secara  real-
time.
## User
3 Manual Control Fitur  untuk  mengendalikan
pompa air dan pompa pupuk
secara   manual   melalui
aplikasi.
## User
4 History Menampilkan  riwayat  data
sensor  yang  tersimpan  di
database   SQLite   agar
pengguna  dapat  memantau
perkembangan tanaman.
## User
5 Notifikasi Menampilkan  pemberitahuan
dari  sistem,  seperti  kondisi
abnormal  atau  kebutuhan
penyiraman,  yang  disimpan
secara lokal.
## User
6 Addkit Fitur  untuk  menambah  kit
baru  atau  perangkat  IoT
tambahan agar bisa terhubung
ke sistem monitoring.
## User
Selanjutnya penulis membuat use case scenario yang berguna untuk
menjelaskan  bagaimana  pengguna  atau  actor berinteraksi  dengan  system
untuk mencapai tujuan tertentu.

## Use Case Name Login
Use Case ID 1
## Actor User

Description Proses masuk atau login ke dalam aplikasi dengan
memasukkan username dan password yang  sudah
ditentukan.
Pre Condition Membuka halaman login aplikasi.
Trigger Aktor mengakses halaman login aplikasi.
Flow of Events Actor System Response
- Akses  halaman login
aplikasi
- Menampilkan form
login
- Input username dan
password

- Klik login 5. Berhasil login dan
menampilkan   halaman
utama.
Alternative Flow 5a.  Data login tidak
sesuai atau kosong maka
system menampilkan data
login salah  atau  tidak
berhasil  login.

Conclusion Aktor berhasil login.
Post Condition Halaman utama aplikasi.
## D
## Use Case Name Monitor
Use Case ID 2
## Actor User
Description Fitur untuk melihat data sensor tanaman secara real-
time,  termasuk  pH,  PPM,  suhu,  dan  kelembapan.
Sistem akan memperbarui tampilan nilai sensor secara
otomatis tanpa perlu refresh.

Pre Condition User  telah  berhasil  login  ke  dalam  aplikasi fan
memiliki perangkat/kit yang terhubung.
Trigger Aktor memilih fitur Monitor dari halaman utama.
Flow of Events Actor System Response
-  Aktor  memilih  menu
## Monitor
-  Sistem  menampilkan
halaman Monitor.
- Sistem mengambil data
sensor terbaru.
-  Sistem  menampilkan
nilai sensor.
- Sistem  memperbarui
nilai  sensor  secara real-
time.
Alternative Flow 3a. Jika  data  sensor  tidak  tersedia  atau  koneksi
terputus,  sistem  menampilkan  pesan “Data  tidak
tersedia” atau  menampilkan  data  terakhir  yang
tersimpan.
Conclusion Aktor  berhasil melihat  data  sensor  tanaman  secara
real-time.
Post Condition Sistem  terus  memperbarui  tampilan  nilai  sensor
selama halaman Monitor dibuka.
## G
## Use Case Name Manual Control
Use Case ID 3
## Actor User
Description Fitur untuk mengendalikan pompa nutrisi, pompa pH
Up, dan pH Down secara manual melalui aplikasi.
Aktor dapat menekan tombol kontrol untuk mengirim
perintah ke perangkat IoT.

Pre Condition User  sudah  login  dan  memiliki  perangkat/kit  yang
terhubung.
Trigger Aktor  memilih  menu Manual  Control  /  Kendali
## Pompa.
Flow of Events Actor System Response



Alternative Flow 4a. Jika  perintah  gagal  dikirim  (misal  koneksi
bermasalah),  sistem  menampilkan  pesan “Perintah
gagal dikirim”.
Conclusion Aktor  berhasil  melakukan  kontrol  manual  terhadap
pompa atau pH melalui aplikasi.
Post Condition Status pompa diperbarui dan ditampilkan di halaman
aplikasi.


## 4.2.1.2 Activity Diagram
## 4.2.1.3 Sequence Diagram
## 4.2.2 Perancangan Database
4.2.3 Perancangan Antarmuka Pengguna (UI/UX Design)
## 4.2.3.1 Wireframe
## 4.2.3.2 Prototype
## 4.3 Development
## 4.3.1 Implementasi Database
4.3.2 Pembuatan & Integrasi API
4.3.3 Implementasi REST API pada Aplikasi Android (Flutter)
## 4.3.4 Implementasi Fitur Aplikasi
## 4.4 Testing
## 4.4.1 Unit Testing
## 4.4.2 Black Box Testing
4.4.3 User Acceptance Testing (UAT)
## 4.5 Deployment
## 4.6 Maintenance

## BAB V

## 5.1 Hasil Akhir Aplikasi
5.2 Hasil User Acceptance Testing (UAT)
5.3 Hasil System Usability Scale (SUS)

## BAB VI

## 6.1 Kesimpulan
## 6.2 Saran