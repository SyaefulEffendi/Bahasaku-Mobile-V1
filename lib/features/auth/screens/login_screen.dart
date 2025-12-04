import 'package:flutter/material.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/features/auth/screens/register_screen.dart';
import './dashboard_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bahasaku_v1/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State
  bool _isPasswordVisible = false;
  bool _isRememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBE7FD), // Background Biru Muda
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- HEADER (Tombol Back & Judul Masuk) ---
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: Colors.black,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Penyeimbang
                ],
              ),
              const SizedBox(height: 30),

              // --- LOGO BAHASAKU DALAM KOTAK ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), // Sudut tumpul
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo_bahasaku.png',
                  height: 50, 
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),

              // --- TEKS SAMBUTAN ---
              const Text(
                'Selamat Datang Kembali!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk untuk melanjutkan perjalanan belajar\nAnda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 30),

              // --- KARTU PUTIH (FORM LOGIN) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 1. Email
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Alamat Email',
                      suffixIcon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    // 2. Password
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Kata Sandi',
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // 3. Ingat Saya & Lupa Password
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _isRememberMe,
                            activeColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isRememberMe = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ingat saya',
                          style: TextStyle(fontSize: 12, color: AppColors.textDark),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            print("Lupa Password ditekan");
                          },
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

// 4. TOMBOL MASUK
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // 1. Ambil input
                          final email = _emailController.text;
                          final password = _passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email dan Password wajib diisi!')),
                            );
                            return;
                          }

                          // 2. Loading Indicator (Opsional, biar UX bagus)
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            // 3. Kirim Request ke Flask
                            final response = await http.post(
                              Uri.parse(ApiClient.login),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "email": email,
                                "password": password,
                                // "remember_me": _isRememberMe // Bisa dikirim jika Flask support
                              }),
                            );

                            // Tutup Loading
                            if (mounted) Navigator.pop(context);

                            // 4. Cek Response
                            if (response.statusCode == 200) {
                              final data = jsonDecode(response.body);
                              final token = data['access_token'];
                              final userName = data['user']['full_name'];

                              print("Login Sukses! Token: $token");

                              // 5. Simpan Token ke HP (Penyimpanan Lokal)
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('token', token);
                              await prefs.setString('userName', userName);

                              // 6. Pindah ke Dashboard
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                );
                              }
                            } else {
                              // Login Gagal (Password salah / User tak ditemukan)
                              final errorData = jsonDecode(response.body);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorData['error'] ?? 'Login Gagal'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // Error Koneksi (Server mati / Beda WiFi)
                            if (mounted) Navigator.pop(context); // Tutup loading
                            print("Error Koneksi: $e");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal terhubung ke server. Pastikan IP benar: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          // ... (style tetap sama)
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- FOOTER: BELUM PUNYA AKUN? ---
              GestureDetector(
                onTap: () {
                  // Pindah ke Register Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    children: [
                      TextSpan(text: 'Belum punya akun? '),
                      TextSpan(
                        text: 'Daftar Sekarang',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- DIVIDER "ATAU" ---
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.black12)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black12)),
                ],
              ),

              const SizedBox(height: 20),

              // --- TOMBOL GOOGLE ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      print("Login Google ditekan");
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google_logo.png', // Pastikan nama file benar
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Padding bawah
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.primaryBlue,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : (suffixIcon != null
                  ? Icon(suffixIcon, color: AppColors.primaryBlue)
                  : null),
        ),
      ),
    );
  }
}