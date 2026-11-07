# UBantu

**UBantu** adalah platform ekosistem digital *peer-to-peer micro-services* yang dirancang khusus untuk mahasiswa **Fakultas Ilmu Komputer (FILKOM) Universitas Brawijaya**. UBantu mempertemukan mahasiswa yang memiliki keterbatasan waktu akibat padatnya aktivitas perkuliahan dengan sesama mahasiswa dan masyarakat sekitar untuk saling membantu dalam menyelesaikan berbagai aktivitas harian secara efisien, aman, dan terjangkau.

---

## 📌 Problem Statement

Mahasiswa seringkali mengalami kesulitan dalam manajemen waktu akibat tingginya beban akademis, praktikum, serta aktivitas organisasi. Berdasarkan penelitian oleh *Damayanti et al. (2023)*, terdapat korelasi langsung antara minimnya efisiensi manajemen waktu dengan tingginya tingkat stres mahasiswa. 

Untuk mengatasi permasalahan tersebut, diperlukan sebuah solusi berbasis ekosistem saling bantu yang mampu mempermudah pengerjaan aktivitas harian sekaligus menciptakan peluang ekonomi berkelanjutan bagi sesama mahasiswa.

---

## 💡 Solution & Layanan Utama

UBantu hadir sebagai penyedia ekosistem jasa mikro terintegrasi yang mencakup 3 layanan utama:

1. 🧹 **Jasa Kebersihan Kos**: Layanan bantuan pembersihan kamar kos, penyedotan debu, dan perapihan area tempat tinggal mahasiswa.
2. 📦 **Jasa Pindah Kos**: Layanan pengangkutan, pengemasan, dan pemindahan barang kos antar lokasi secara aman.
3. 🛵 **Layanan Pesan Antar Barang**: Jasa antar-jemput dokumen, tugas cetak/print, makanan, serta kebutuhan harian kampus.

---

## ⭐ Fitur Utama & Keunggulan

* 🔐 **Sistem Autentikasi & Verifikasi Mitra**
  * Login & Registrasi menggunakan email kampus (`@student.ub.ac.id`) atau email umum.
  * Verifikasi Kartu Tanda Mahasiswa (KTM) Universitas Brawijaya sebelum mitra dapat menerima pesanan.
  * Dukungan bypass otomatis untuk pengujian saat fitur konfirmasi email dimatikan.
* 📅 **Smart Scheduling System**
  * Sistem penjadwalan fleksibel yang memungkinkan pengguna membooking jadwal di jam tertentu dengan notifikasi pengingat real-time.
* ⭐ **Rating & Review Engine**
  * Transparansi penilaian bintang dan ulasan ulasan dari sesi bantuan sebelumnya untuk menjamin kualitas layanan.
* 🚨 **In-App Emergency Button (SOS)**
  * Tombol darurat yang dapat diakses pengguna saat tidak merasa aman selama layanan berlangsung dengan pelacakan status darurat.
* 🎁 **Loyalty & Reward Points**
  * Sistem pengumpulan poin bantuan yang dapat ditukarkan menjadi voucher jasa gratis 1x.
* 👩 **Filter Women-Only**
  * Fitur penyaringan penyedia jasa khusus perempuan untuk menjamin kenyamanan dan keamanan ekstra bagi mahasiswi.
* 🔄 **Sistem Barter (Tukar Jasa)**
  * Dukungan penukaran jasa bantuan dengan makanan atau barang secara fleksibel.

---

## 🛠️ Tech Stack

UBantu dibangun menggunakan teknologi modern:

* **Bahasa & Framework:** Flutter (Dart 3.x)
* **Pattern Arsitektur:** Clean MVVM (Model-View-ViewModel / Provider)
* **State Management:** Provider Pattern (`MultiProvider`)
* **Routing & Navigasi:** `go_router`
* **Backend-as-a-Service (BaaS):** Supabase
  * **PostgreSQL** — penyimpanan data profil pengguna, tugas, laporan SOS, notifikasi, dan poin reward.
  * **Auth** — manajemen sesi dan autentikasi JWT.
  * **Storage** — penyimpanan foto verifikasi KTM dan avatar pengguna.
  * **Realtime** — sinkronisasi status laporan dan notifikasi darurat.

---

## 🏗️ Arsitektur Aplikasi

UBantu mengadopsi struktur **Clean 4-Layer Architecture** untuk memastikan pemisahan tanggung jawab (*separation of concerns*), keterujian (*testability*), dan kemudahan pemeliharaan kode:

```text
lib/
├── core/                 # Shared Infrastructure: Config, DI Service Locator, Exception Handler, Navigation, Theme, Utils
│   ├── config/
│   ├── di/
│   ├── errors/
│   ├── navigation/
│   ├── theme/
│   └── utils/
├── data/                 # Data Layer: Models (DTOs & Domain Entities), Repositories, Services
│   ├── models/
│   ├── repositories/
│   └── services/
├── logic/                # Business Logic / UseCases
├── ui/                   # Feature-based Presentation (Views, Providers, and Widgets)
│   ├── aktivitas/
│   ├── antar_jemput/
│   ├── auth/
│   ├── bersih_kos/
│   ├── chat/
│   ├── home/
│   ├── mitra/
│   ├── notification/
│   ├── onboarding/
│   ├── pindah_kos/
│   ├── profile/
│   ├── sos/
│   └── widgets/
├── app.dart              # MultiProvider Root & MaterialApp Setup
└── main.dart             # Application Bootstrap & Re-exports
```

---

## 🔑 Akun Demo & Kredensial Testing

Untuk memfasilitasi pengujian fitur tanpa proses pendaftaran manual, akun-akun berikut aktif di Supabase Auth & Database (Password default: `Testing123!`):

| Nama Pengguna | Email Login | Status Verifikasi | Nomor Telepon |
|---|---|---|---|
| **Mahasiswa Tester UB** | `tester@student.ub.ac.id` | Verified UB (KTM Approved) | `081234567890` |
| **Bintang Pratama** | `bintang.pratama@gmail.com` | Verified | `081298765432` |
| **Anisa Rahmawati** | `anisa.rahmawati@yahoo.com` | Verified | `085712345678` |
| **Farhan Kurniawan** | `farhan.kurnia@gmail.com` | Verified | `082134567890` |
| **Dinda Kirana** | `dinda.kirana@outlook.com` | Verified | `081345678901` |
| **Rizky Aditya** | `rizky.aditya@gmail.com` | Verified | `087812345678` |

---

## 🚀 Setup & Cara Menjalankan Project

1. **Clone Repository:**
   ```bash
   git clone https://github.com/zuhdiarif/Ubantu.git
   cd Ubantu
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Environment:**
   Salin `.env.example.json` ke `.env.json` lalu isi nilai kredensial Supabase Anda:
   ```bash
   cp .env.example.json .env.json
   ```

4. **Jalankan Automated Test Suite:**
   ```bash
   flutter test
   ```

---

## 📦 Menjalankan & Build

Pastikan file `.env.json` telah dikonfigurasi (salin dari `.env.example.json` dan isi nilai yang sesuai).

* **Menjalankan Aplikasi (Debug/Development):**
  ```bash
  flutter run --dart-define-from-file=.env.json
  ```

* **Build Android APK (Release):**
  ```bash
  flutter build apk --release --dart-define-from-file=.env.json
  ```

* **Build Android App Bundle (Release):**
  ```bash
  flutter build appbundle --release --dart-define-from-file=.env.json
  ```
