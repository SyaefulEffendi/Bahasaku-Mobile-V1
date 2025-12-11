import 'package:flutter/material.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Ketentuan dan Layanan",
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
            // Header Image (Opsional, bisa dihapus jika tidak ada gambar)
            // Center(
            //   child: Image.asset('assets/images/terms_header.png', height: 150),
            // ),
            // const SizedBox(height: 20),

            const Text(
              "Selamat Datang di Bahasaku",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 10),
            const Text(
              "Terima kasih telah menggunakan aplikasi Bahasaku. Mohon baca Syarat dan Ketentuan ini dengan saksama sebelum menggunakan layanan kami.",
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            
            const SizedBox(height: 25),
            _buildSection(
              "1. Penerimaan Syarat",
              "Dengan mengakses dan menggunakan aplikasi Bahasaku, Anda dianggap telah membaca, memahami, dan menyetujui semua syarat dan ketentuan yang tertulis di sini. Jika Anda tidak setuju, mohon untuk tidak menggunakan aplikasi ini.",
            ),

            _buildSection(
              "2. Layanan Kami",
              "Bahasaku menyediakan fitur penerjemah bahasa isyarat ke teks dan sebaliknya, serta kamus bahasa isyarat. Kami terus berupaya meningkatkan akurasi, namun tidak menjamin bahwa terjemahan akan selalu 100% akurat atau bebas dari kesalahan.",
            ),

            _buildSection(
              "3. Akun Pengguna",
              "• Anda bertanggung jawab menjaga kerahasiaan informasi akun dan kata sandi Anda.\n"
              "• Anda setuju untuk memberikan data yang akurat saat pendaftaran (Nama, Email, dll).\n"
              "• Kami berhak menonaktifkan akun jika ditemukan pelanggaran.",
            ),

            _buildSection(
              "4. Penggunaan yang Dilarang",
              "Anda dilarang menggunakan aplikasi ini untuk:\n"
              "• Tindakan ilegal atau melanggar hukum.\n"
              "• Menyebarkan konten berbahaya (virus, malware).\n"
              "• Melakukan spam atau pelecehan terhadap pengguna lain.",
            ),

            _buildSection(
              "5. Hak Kekayaan Intelektual",
              "Seluruh konten, desain, logo, dan kode pemrograman dalam aplikasi ini adalah milik Bahasaku dan dilindungi oleh undang-undang hak cipta. Dilarang menyalin atau mendistribusikan ulang tanpa izin tertulis.",
            ),

            _buildSection(
              "6. Perubahan Ketentuan",
              "Kami berhak mengubah syarat dan ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui pembaruan aplikasi atau notifikasi.",
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

  // Widget Helper untuk membuat Section Teks agar rapi
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