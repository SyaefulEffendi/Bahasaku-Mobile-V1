import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pastikan tambah intl di pubspec.yaml jika belum
import 'package:quickalert/quickalert.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
// Sesuaikan import ApiClient Anda
import 'package:bahasaku_v1/core/api/api_client.dart'; 

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _dateController = TextEditingController();
    _loadUserData();
  }

  // 1. Ambil Data Awal dari SharedPreferences untuk mengisi form
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phoneNumber') ?? '';
      
      // Jika Anda menyimpan location/birth_date saat login, load disini.
      // Jika tidak, biarkan kosong atau fetch dari API (opsional).
      // Contoh dummy atau ambil dari prefs jika sudah disimpan sebelumnya:
      _locationController.text = prefs.getString('location') ?? ''; 
      _dateController.text = prefs.getString('birthDate') ?? ''; 
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // 2. Fungsi Simpan Data ke Server
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Menyimpan...',
      text: 'Mohon tunggu sebentar',
      disableBackBtn: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('userId'); // ID yang kita simpan di Langkah 1

      if (token == null || userId == null) {
        Navigator.pop(context); // Tutup loading
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Sesi tidak valid. Silakan login ulang.',
        );
        return;
      }

      // URL Update User (PUT /users/<id>)
      // Ganti url_base sesuai ApiClient Anda
      // Asumsi: ApiClient.baseUrl adalah "http://10.0.2.2:5000/api"
      // Jika ApiClient.register berisi full URL, sesuaikan logic string ini.
      final url = Uri.parse('http://10.0.2.2:5000/api/users/$userId'); 

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "full_name": _nameController.text,
          "phone_number": _phoneController.text,
          "location": _locationController.text,
          "birth_date": _dateController.text, // Format YYYY-MM-DD
          // Email tidak dikirim agar tidak berubah, atau dikirim tapi backend validasi
        }),
      );

      // Tutup Loading Alert
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        // Update sukses: Simpan data baru ke SharedPreferences
        await prefs.setString('userName', _nameController.text);
        await prefs.setString('phoneNumber', _phoneController.text);
        await prefs.setString('location', _locationController.text);
        await prefs.setString('birthDate', _dateController.text);

        if (mounted) {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil!',
            text: 'Profil berhasil diperbarui.',
            onConfirmBtnTap: () {
              Navigator.pop(context); // Tutup Alert
              Navigator.pop(context, true); // Kembali ke halaman Profil & Refresh
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
            text: errorData['error'] ?? 'Gagal memperbarui profil.',
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup loading jika error koneksi
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Koneksi Error',
          text: e.toString(),
        );
      }
    }
  }

  // Helper untuk Date Picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            children: [
              // Foto Profil (Opsional: Bisa ditambahkan fitur ganti foto disini nanti)
              // Center(
              //   child: CircleAvatar(radius: 50, ...),
              // ),
              // const SizedBox(height: 30),

              _buildTextField(
                label: "Nama Lengkap",
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: "Email",
                controller: _emailController,
                icon: Icons.email_outlined,
                isReadOnly: true, // KUNCI: Email tidak bisa diedit
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: "Nomor Telepon",
                controller: _phoneController,
                icon: Icons.phone_outlined,
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: "Tempat Tinggal",
                controller: _locationController,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer( // Mencegah keyboard muncul
                  child: _buildTextField(
                    label: "Tanggal Lahir",
                    controller: _dateController,
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: inputType,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
          validator: (value) {
            if (!isReadOnly && (value == null || value.isEmpty)) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}