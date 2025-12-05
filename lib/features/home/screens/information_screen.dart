import 'package:flutter/material.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================== BAGIAN 1: HEADER INFORMASI ==================
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: Text(
              'Informasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // ================== BAGIAN 2: KONTEN LIST (KARTU) ==================
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Informasi Terkini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Text(
                  'Dapatkan informasi terbaru dari Bahasaku',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),

                // --- LIST KARTU INFORMASI BESAR ---
                _buildBigInfoCard(
                  title: 'Workshop Bahasa Isyarat',
                  date: '15 Des 2025',
                ),
                const SizedBox(height: 20),
                _buildBigInfoCard(
                  title: 'Update Fitur Baru v2.0',
                  date: '20 Des 2025',
                ),
                const SizedBox(height: 20),
                _buildBigInfoCard(
                  title: 'Kisah Inspiratif Teman Tuli',
                  date: '25 Des 2025',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk membuat Kartu Besar (Abu-abu & Putih)
  Widget _buildBigInfoCard({required String title, required String date}) {
    return Container(
      width: double.infinity,
      height: 200, // Tinggi kartu
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bagian Atas: Gambar Placeholder (Abu-abu)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Warna abu-abu sesuai desain
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              // Nanti bisa diganti Image.asset jika sudah ada gambar
              child: const Center(
                child: Icon(Icons.image, color: Colors.white, size: 50),
              ),
            ),
          ),
          // Bagian Bawah: Teks Judul
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}