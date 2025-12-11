import 'package:flutter/material.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Kebijakan Privasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Komitmen Kami terhadap Privasi Anda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 10),
            const Text(
              "Di Bahasaku, privasi Anda adalah prioritas kami. Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda.",
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            
            const SizedBox(height: 25),
            _buildSection(
              "1. Informasi yang Kami Kumpulkan",
              "Kami mengumpulkan informasi yang Anda berikan secara langsung saat mendaftar atau menggunakan fitur aplikasi, meliputi:\n"
              "• Data Identitas: Nama lengkap, tanggal lahir, dan jenis pengguna (Tuli/Dengar).\n"
              "• Kontak: Alamat email, nomor telepon, dan tempat tinggal.\n"
              "• Media: Foto profil yang Anda unggah.\n"
              "• Pesan: Kritik dan saran yang Anda kirim melalui fitur Hubungi Kami.",
            ),

            _buildSection(
              "2. Penggunaan Izin Perangkat",
              "Untuk menjalankan fitur utama, aplikasi Bahasaku mungkin meminta akses ke:\n"
              "• Kamera: Untuk fitur Video-to-Text (mendeteksi isyarat tangan) dan mengambil foto profil.\n"
              "• Penyimpanan/Galeri: Untuk mengunggah foto profil dari galeri.",
            ),

            _buildSection(
              "3. Bagaimana Kami Menggunakan Data Anda",
              "Informasi Anda digunakan untuk:\n"
              "• Memverifikasi identitas dan mengelola akun Anda.\n"
              "• Meningkatkan akurasi sistem penerjemah bahasa isyarat kami.\n"
              "• Menghubungi Anda terkait pembaruan layanan atau respon terhadap keluhan.",
            ),

            _buildSection(
              "4. Keamanan Data",
              "Kami menerapkan langkah-langkah keamanan teknis untuk melindungi data Anda dari akses yang tidak sah. Password Anda disimpan dalam bentuk terenkripsi (Hashed) dan tidak dapat dilihat oleh siapapun, termasuk tim kami.",
            ),

            _buildSection(
              "5. Hak Anda",
              "Anda memiliki hak untuk mengakses, memperbarui, atau menghapus informasi pribadi Anda kapan saja melalui menu 'Edit Profil' di dalam aplikasi.",
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                "Terakhir diperbarui: 11 Desember 2025",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget Helper
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(color: Colors.black87, height: 1.6, fontSize: 14),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}