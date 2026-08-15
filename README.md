# UBantu - Platform Ekosistem Saling Bantu Mahasiswa

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20MVVM-green)
![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)

## 📌 Overview

Tidak jarang mahasiswa menghadapi keterbatasan waktu akibat padatnya aktivitas perkuliahan, praktikum, dan organisasi. Kondisi ini membuat mahasiswa sering mengalami kesulitan dalam mengurus aktivitas harian seperti **bersih-bersih kos, pesan antar barang, hingga pindah kos**.

**UBantu** hadir sebagai platform digital berbasis Flutter & Supabase yang menghubungkan mahasiswa untuk saling membantu menyelesaikan aktivitas harian tersebut secara efisien, aman, dan terjangkau.

---

## ❓ Problem Statement

Berdasarkan analisis oleh *Damayanti et al. (2023)*, terdapat korelasi kuat antara tingginya tingkat stres mahasiswa dengan minimnya manajemen waktu di tengah kesibukan akademik. Untuk meningkatkan efisiensi waktu, diperlukan solusi berbasis ekosistem saling bantu yang dapat memenuhi kebutuhan harian mahasiswa sekaligus membuka peluang bernilai ekonomi berkelanjutan.

---

## 💡 Solution & Layanan Utama

**UBantu** berperan sebagai ekosistem layanan mikro antar mahasiswa dan masyarakat sekitar. Terdapat 3 layanan utama:

1. 🧹 **Jasa Kebersihan Kos**: Bantuan pembersihan kamar kos secara fleksibel.
2. 📦 **Jasa Pindah Kos**: Layanan pengangkutan barang pindahan kos antar lokasi.
3. 🛵 **Layanan Pesan Antar Barang**: Jasa antar-jemput barang, dokumen, atau kebutuhan harian.

---

## ⭐ Key Advantages & Innovative Features

- 📅 **Smart Scheduling System**: Fitur pemesanan dan pemantauan jadwal fleksibel dengan notifikasi pengingat real-time.
- ⭐ **Rating & Review Engine**: Transparansi ulasan dan skor reputasi penyedia jasa.
- 🆔 **Verifikasi Identitas Mitra (KTM UB)**: Proses verifikasi Kartu Tanda Mahasiswa (KTM) Universitas Brawijaya sebelum mitra dapat menerima order.
- 🚨 **In-App Emergency Button (SOS)**: Tombol darurat pelacakan dan bantuan saat pengguna tidak merasa aman selama layanan berlangsung.
- 🎁 **Loyalty & Reward Points**: Sistem penukaran poin bantuan menjadi voucher jasa gratis 1x.
- 👩 **Filter Women-Only**: Pilihan penyaringan penyedia jasa khusus perempuan untuk kenyamanan ekstra.

---

## 🛠️ Technology Stack

| Component | Technology |
|---|---|
| **Frontend Framework** | Flutter 3.x (Dart 3.x) |
| **Architecture Pattern** | Clean MVVM (Model-View-ViewModel/Provider) |
| **State Management** | Provider Pattern (`MultiProvider`) |
| **Navigation & Routing** | `go_router` |
| **Backend & Cloud** | Supabase (PostgreSQL, Supabase Auth, Storage) |

---

## 🏗️ Clean MVVM Architecture Overview

Aplikasi dibangun mengikuti standar **Clean MVVM Architecture** untuk modularitas dan keterujian maksimal:

```text
lib/
├── components/           # UI Reusable Widgets (Theme, Custom Badge, Buttons, Cards, States)
├── core/                 # Infrastructure (AppConfig, DI, Error Handling, Navigation, Utils)
├── data/                 # Data Layer (DTOs, RepositoriesImpl, Supabase Services, Local Storage)
├── domain/               # Logic Layer (Entities, Abstract Repository Contracts, UseCases)
└── presentation/         # UI Layer (ChangeNotifier Providers & Presentation Views)
```

---

## 🔑 Demo Account & Seed Credentials

Untuk memfasilitasi pengujian aplikasi tanpa pendaftaran manual, seluruh akun berikut aktif di Supabase Auth & DB (Password default: `Testing123!`):

| Nama Pengguna | Email Login | Status | Telepon |
|---|---|---|---|
| **Mahasiswa Tester UB** | `tester@student.ub.ac.id` | Verified UB | 081234567890 |
| **Bintang Pratama** | `bintang.pratama@gmail.com` | Verified | 081298765432 |
| **Anisa Rahmawati** | `anisa.rahmawati@yahoo.com` | Verified | 085712345678 |
| **Farhan Kurniawan** | `farhan.kurnia@gmail.com` | Verified | 082134567890 |
| **Dinda Kirana** | `dinda.kirana@outlook.com` | Verified | 081345678901 |
| **Rizky Aditya** | `rizky.aditya@gmail.com` | Verified | 087812345678 |

---

## 🚀 Quick Start & Installation Guide

### Prasyarat
- Flutter SDK `^3.12.0`
- Supabase Project & Credentials

### Langkah Setup

1. **Clone Repository**:
   ```bash
   git clone https://github.com/zuhdiarif/Ubantu.git
   cd Ubantu
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://orpilmyjifanjwpxxmdi.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
   ```
