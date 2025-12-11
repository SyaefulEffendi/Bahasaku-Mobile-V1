import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
// Sesuaikan dengan lokasi ApiClient Anda jika perlu
import 'package:bahasaku_v1/core/api/api_client.dart'; 

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _messageController = TextEditingController();
    _loadUserData();
  }

  // 1. Ambil Data User dari HP (Auto Input)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Mengambil nama dan email yang tersimpan saat login
      _nameController.text = prefs.getString('userName') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // 2. Kirim Pesan ke Backend
  Future<void> _sendFeedback() async {
    // Tutup keyboard agar tidak menutupi alert
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Mengirim...',
      text: 'Mohon tunggu sebentar',
      disableBackBtn: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Sesi habis, silakan login ulang.',
        );
        return;
      }

      // URL Endpoint Feedback
      // Pastikan blueprint feedback sudah di-register di app.py dengan prefix '/api/feedback'
      //part 1 final url = Uri.parse('http://10.0.2.2:5000/api/feedback/'); 192.168.240.1
      //final url = Uri.parse('${ApiClient.baseUrl}/users/$userId');
      //Kalau pake Andorid STudio:
      final url = Uri.parse('${ApiClient.baseUrl}/feedback/');
      //hp fisik:
      //final url = Uri.parse('http://192.168.23.226:5000/api/feedback/');

      // Request POST sesuai routes feedback_routes.py
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Backend butuh @jwt_required
        },
        body: jsonEncode({
          "message": _messageController.text,
          // user_id tidak perlu dikirim karena backend mengambilnya otomatis dari token
        }),
      );

      // Tutup Loading
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Terkirim!',
            text: 'Terima kasih, pesan Anda telah kami terima.',
            onConfirmBtnTap: () {
              Navigator.pop(context); // Tutup Alert
              Navigator.pop(context); // Kembali ke halaman Akun
            },
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Gagal',
            text: errorData['error'] ?? 'Gagal mengirim pesan.',
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error Koneksi',
          text: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hubungi Kami", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Saran & Masukan",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masukan Anda sangat berarti bagi pengembangan Bahasaku kedepannya.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // 1. Nama Lengkap (Read Only - Auto Input)
              _buildTextField(
                label: "Nama Lengkap",
                controller: _nameController,
                icon: Icons.person_outline,
                isReadOnly: true, // Tidak bisa diedit user
              ),
              const SizedBox(height: 20),

              // 2. Email (Read Only - Auto Input)
              _buildTextField(
                label: "Email",
                controller: _emailController,
                icon: Icons.email_outlined,
                isReadOnly: true, // Tidak bisa diedit user
              ),
              const SizedBox(height: 20),

              // 3. Pesan (Bisa diisi user)
              const Text("Pesan", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 5, // Kotak lebih besar
                decoration: InputDecoration(
                  hintText: "Tulis kritik, saran, atau kendala Anda disini...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pesan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Kirim Pesan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Text Field Read-Only
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          style: TextStyle(color: isReadOnly ? Colors.grey : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : AppColors.primaryBlue),
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }
}