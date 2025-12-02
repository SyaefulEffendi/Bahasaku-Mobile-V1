import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import './register_screen.dart';
import './login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Tinggi gambar 65% agar tidak terlalu zoom
            height: size.height * 0.65, 
            child: Image.asset(
              'assets/images/background_landing.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter, 
            ),
          ),

          // 2. WHITE CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: size.height * 0.45, 
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30), 
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Judul Besar
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Badge "di Aplikasi Bahasaku"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'di Aplikasi Bahasaku',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Deskripsi
                    const Text(
                      'Membuka Semua Akses Bahasa Isyarat\nuntuk Semua',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    
                    // --- PERBAIKAN DISINI ---
                    // Sebelumnya Spacer(), sekarang diganti SizedBox fixed height
                    // Jaraknya jadi fix 40 pixel, tidak akan menjauh lagi
                    const SizedBox(height: 40), 

                    // Tombol Masuk & Daftar
                    Row(
                      children: [
                        // Tombol MASUK
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigasi ke Login Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), 

                        // Tombol DAFTAR
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // --- NAVIGASI KE REGISTER SCREEN ---
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Spacer kecil di bawah tombol sebelum footer (opsional)
                    const Spacer(), 

                    // Footer Text
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                        children: [
                          TextSpan(text: 'Dengan masuk dan mendaftarkan diri Anda menyetujui\n'),
                          TextSpan(
                            text: 'Ketentuan Layanan',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                          TextSpan(text: ' dan '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}