import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart'; 

import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart';
import 'package:bahasaku_v1/features/auth/screens/register_screen.dart';
import 'package:bahasaku_v1/features/home/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller
  final TextEditingController _identifierController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isRememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBE7FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- HEADER ---
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
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 30),

              // --- LOGO ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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

              // --- TEXT ---
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

              // --- FORM ---
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
                    // 1. Email atau No Telepon
                    _buildTextField(
                      controller: _identifierController,
                      hint: 'Email atau Nomor Telepon', 
                      suffixIcon: Icons.person_outline, 
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

                    // --- TOMBOL MASUK ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final identifier = _identifierController.text;
                          final password = _passwordController.text;

                          if (identifier.isEmpty || password.isEmpty) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.warning,
                              title: 'Oops...',
                              text: 'Email/No. Telepon dan Password wajib diisi!',
                              confirmBtnColor: AppColors.primaryBlue,
                            );
                            return;
                          }

                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.loading,
                            title: 'Mohon Tunggu',
                            text: 'Sedang memproses login...',
                            disableBackBtn: true,
                          );

                          try {
                            final response = await http.post(
                              Uri.parse(ApiClient.login),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "email": identifier, 
                                "password": password,
                              }),
                            );

                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (response.statusCode == 200) {
                              final data = jsonDecode(response.body);
                              final token = data['access_token'];
                              final user = data['user'];

                              final prefs = await SharedPreferences.getInstance();
                              
                              // PENYIMPANAN DATA LENGKAP (UPDATE)
                              await prefs.setString('token', token);
                              await prefs.setInt('userId', user['id']);
                              await prefs.setString('userName', user['full_name']);
                              await prefs.setString('email', user['email']);
                              
                              // Simpan Role & User Type
                              await prefs.setString('role', user['role'] ?? 'User');
                              await prefs.setString('userType', user['user_type'] ?? 'Umum');

                              // Simpan Tempat Tinggal (Location)
                              await prefs.setString('location', user['location'] ?? '');

                              // Simpan Tanggal Lahir (Birth Date)
                              await prefs.setString('birthDate', user['birth_date'] ?? '');

                              // Simpan No Telepon
                              if (user['phone_number'] != null && user['phone_number'] != "") {
                                await prefs.setString('phoneNumber', user['phone_number']);
                              } else {
                                await prefs.setString('phoneNumber', 'Tidak ada No Telepon');
                              }
                              
                              // Simpan Foto Profil
                              if (user['profile_pic_url'] != null) {
                                await prefs.setString('photoProfile', user['profile_pic_url']);
                              }

                              if (context.mounted) {
                                await QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: 'Berhasil!',
                                  text: 'Selamat datang kembali, ${user['full_name']}',
                                  confirmBtnColor: AppColors.primaryBlue,
                                  onConfirmBtnTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                    );
                                  },
                                );
                              }
                            } else {
                              final errorData = jsonDecode(response.body);
                              if (context.mounted) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Gagal Login',
                                  text: errorData['error'] ?? 'Akun tidak ditemukan.',
                                  confirmBtnColor: Colors.red,
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                            if (context.mounted) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Koneksi Gagal',
                                text: 'Tidak dapat terhubung ke server.\nError: $e',
                                confirmBtnColor: Colors.red,
                              );
                            }
                          }
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
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
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.black12)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau',
                      style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black12)),
                ],
              ),
              const SizedBox(height: 20),
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
                            'assets/images/google_logo.png',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Masuk dengan Google',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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