import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; 
import 'package:quickalert/quickalert.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart'; 

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKeyProfile = GlobalKey<FormState>(); 
  final _formKeyPassword = GlobalKey<FormState>(); 

  // Controller Profil
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;

  // Controller Password
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  // Visibility Password
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // State khusus untuk menampung error dari Backend (Password Lama Salah)
  String? _backendOldPasswordError;

  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Init Profil
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _dateController = TextEditingController();

    // Init Password
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Listener: Hapus error backend jika user mulai mengetik ulang di password lama
    _oldPasswordController.addListener(() {
      if (_backendOldPasswordError != null) {
        setState(() {
          _backendOldPasswordError = null;
        });
      }
    });

    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus) {
        if (_phoneController.text == 'Tidak ada No Telepon') {
          _phoneController.clear();
        }
      }
    });

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      
      String phone = prefs.getString('phoneNumber') ?? '';
      if (phone.isEmpty || phone == 'null' || phone == 'Tidak ada No Telepon') {
        _phoneController.text = 'Tidak ada No Telepon';
      } else {
        _phoneController.text = phone;
      }

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
    
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _phoneFocusNode.dispose(); 
    super.dispose();
  }

  // ================= LOGIKA SIMPAN PROFIL =================
  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus(); 

    if (!_formKeyProfile.currentState!.validate()) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Menyimpan Profil...',
      text: 'Mohon tunggu sebentar',
      disableBackBtn: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('userId'); 

      if (token == null || userId == null) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop(); 
        return;
      }

      String finalPhone = _phoneController.text;
      if (finalPhone == 'Tidak ada No Telepon') {
        finalPhone = ''; 
      }

      final url = Uri.parse('${ApiClient.baseUrl}/users/$userId'); 

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "full_name": _nameController.text,
          "phone_number": finalPhone,
          "location": _locationController.text,
          "birth_date": _dateController.text, 
        }),
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        await prefs.setString('userName', _nameController.text);
        
        if (finalPhone.isEmpty) {
           await prefs.setString('phoneNumber', 'Tidak ada No Telepon');
        } else {
           await prefs.setString('phoneNumber', finalPhone);
        }
        
        await prefs.setString('location', _locationController.text);
        await prefs.setString('birthDate', _dateController.text);

        if (mounted) {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil!',
            text: 'Data profil berhasil diperbarui.',
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
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
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

  // ================= LOGIKA GANTI PASSWORD =================
  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();

    // Reset error backend sebelum validasi baru
    setState(() {
      _backendOldPasswordError = null;
    });

    if (!_formKeyPassword.currentState!.validate()) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Mengganti Password...',
      text: 'Mohon tunggu sebentar',
      disableBackBtn: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('userId');

      if (token == null || userId == null) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        return;
      }

      final url = Uri.parse('${ApiClient.baseUrl}/users/$userId/change-password');

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "old_password": _oldPasswordController.text,
          "new_password": _newPasswordController.text,
        }),
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        // SUKSES
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _backendOldPasswordError = null;
        });

        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil!',
            text: 'Password Anda telah diperbarui.',
          );
        }
      } else {
        // GAGAL
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['error'] ?? 'Gagal mengganti password.';
        
        // Cek jika errornya spesifik "Password lama salah" (sesuai pesan dari backend Python)
        // Di user_routes.py: return jsonify({"error": "Password lama salah."}), 401
        if (errorMessage.contains("Password lama salah")) {
          setState(() {
            _backendOldPasswordError = "Password lama yang Anda masukkan salah";
          });
          // KITA TIDAK MEMUNCULKAN QUICKALERT DISINI, 
          // Melainkan mengupdate UI Textfield Password Lama
        } else {
          // Jika error lain (misal server error), baru munculkan alert
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Gagal',
              text: errorMessage,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SECTION PROFIL =================
            Form(
              key: _formKeyProfile,
              child: Column(
                children: [
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
                    isReadOnly: true, 
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Nomor Telepon",
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    inputType: TextInputType.phone,
                    focusNode: _phoneFocusNode, 
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
                    child: AbsorbPointer(
                      child: _buildTextField(
                        label: "Tanggal Lahir",
                        controller: _dateController,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                        "Simpan Perubahan Profil",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Divider(thickness: 2, color: Colors.grey),
            const SizedBox(height: 20),

            // ================= SECTION GANTI PASSWORD =================
            const Text(
              "Ganti Password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),

            Form(
              key: _formKeyPassword,
              child: Column(
                children: [
                  _buildPasswordField(
                    label: "Password Lama",
                    controller: _oldPasswordController,
                    obscureText: _obscureOld,
                    // Pass error text dari backend ke sini
                    forceErrorText: _backendOldPasswordError, 
                    onToggleVisibility: () {
                      setState(() {
                        _obscureOld = !_obscureOld;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    label: "Password Baru",
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    label: "Konfirmasi Password Baru",
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Konfirmasi password wajib diisi';
                      if (val.length < 6) return 'Password minimal 6 karakter';
                      if (val != _newPasswordController.text) return 'Password tidak cocok';
                      return null;
                    }
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Perbarui Password",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
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
    FocusNode? focusNode, 
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
          focusNode: focusNode, 
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
            if (!isReadOnly && label != "Nomor Telepon" && (value == null || value.isEmpty)) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  // MODIFIKASI: Menambahkan parameter forceErrorText
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    String? forceErrorText, // Parameter baru untuk error dari backend
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            // Tampilkan error text jika ada kiriman dari backend (forceErrorText)
            errorText: forceErrorText,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
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
            // Mengatur style error agar berwarna merah
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
          // Validator default jika tidak disediakan: Cek Kosong & Cek Minimal 6 Karakter
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            if (value.length < 6) {
              return 'Password minimal 6 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }
}