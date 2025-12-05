import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart'; // Import QuickAlert

import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart';
import 'package:bahasaku_v1/features/auth/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State
  String _selectedUserType = ''; 
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBE7FD), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Daftar Akun',
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

              // --- TITLE ---
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Bergabunglah dengan kami!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Daftar untuk memulai perjalanan belajar yang\nmenakjubkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                      hint: 'Masukkan nama lengkap',
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Tipe Pengguna',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    IntrinsicHeight( 
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildUserTypeCard(
                              label: 'Tuli',
                              desc: 'Keterbatasan dengar',
                              icon: Icons.hearing_disabled,
                            ),
                          ),
                          const SizedBox(width: 8), 
                          Expanded(
                            child: _buildUserTypeCard(
                              label: 'Dengar',
                              desc: 'Pendengaran normal',
                              icon: Icons.hearing,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildUserTypeCard(
                              label: 'Umum',
                              desc: 'Pengguna umum',
                              icon: Icons.person,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: 'Tempat Tinggal',
                      controller: _locationController,
                      hint: 'Tempat Tinggal',
                      suffixIcon: Icons.location_on,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      label: 'Tanggal Lahir',
                      controller: _dateController,
                      hint: 'Tanggal Lahir',
                      suffixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            // Format YYYY-MM-DD
                            _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      label: 'Alamat Email',
                      controller: _emailController,
                      hint: 'Alamat Email',
                      suffixIcon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      label: 'Kata Sandi',
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
                    const SizedBox(height: 30),

                    // --- TOMBOL DAFTAR (INTEGRASI) ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // 1. Validasi Input
                          if (_nameController.text.isEmpty || 
                              _emailController.text.isEmpty || 
                              _passwordController.text.isEmpty ||
                              _selectedUserType.isEmpty) {
                            
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.warning,
                              title: 'Data Belum Lengkap',
                              text: 'Mohon isi nama, email, password, dan pilih tipe pengguna.',
                              confirmBtnColor: AppColors.primaryBlue,
                            );
                            return;
                          }

                          // 2. Loading
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.loading,
                            title: 'Mendaftar...',
                            text: 'Mohon tunggu sebentar',
                            disableBackBtn: true,
                          );

                          try {
                            // 3. Kirim ke Flask
                            final response = await http.post(
                              Uri.parse(ApiClient.register),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "full_name": _nameController.text,
                                "email": _emailController.text,
                                "password": _passwordController.text,
                                "user_type": _selectedUserType,
                                "location": _locationController.text,
                                "birth_date": _dateController.text, // Format YYYY-MM-DD
                              }),
                            );

                            // Tutup Loading
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            // 4. Cek Response
                            if (response.statusCode == 201) {
                              // SUKSES
                              if (context.mounted) {
                                await QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: 'Pendaftaran Berhasil!',
                                  text: 'Silakan login dengan akun baru Anda.',
                                  confirmBtnColor: AppColors.primaryBlue,
                                  onConfirmBtnTap: () {
                                    // Tutup Alert & Pindah ke Login
                                    Navigator.of(context).pop(); 
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  },
                                );
                              }
                            } else {
                              // GAGAL (Email sudah ada dll)
                              final errorData = jsonDecode(response.body);
                              if (context.mounted) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Gagal Mendaftar',
                                  text: errorData['error'] ?? 'Terjadi kesalahan.',
                                  confirmBtnColor: Colors.red,
                                );
                              }
                            }
                          } catch (e) {
                            // Error Koneksi
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop(); // Tutup loading
                            }
                            if (context.mounted) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Koneksi Gagal',
                                text: 'Tidak dapat terhubung ke server.\n$e',
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
                          'Daftar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Footer Text
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                            children: [
                              TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(
                                text: 'Masuk Sekarang',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: TEXT FIELD ---
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    bool readOnly = false,
    VoidCallback? onTap,
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
        readOnly: readOnly,
        onTap: onTap,
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

  // --- WIDGET HELPER: KARTU TIPE PENGGUNA ---
  Widget _buildUserTypeCard({
    required String label,
    required String desc,
    required IconData icon,
  }) {
    bool isSelected = _selectedUserType == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey.shade600, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9, 
                color: Colors.grey.shade600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}