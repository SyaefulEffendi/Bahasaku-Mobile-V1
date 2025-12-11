import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; 
import 'package:quickalert/quickalert.dart';

import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart'; 
import 'package:bahasaku_v1/features/auth/screens/login_screen.dart';
import 'package:bahasaku_v1/features/home/screens/edit_profile_screen.dart';
import 'package:bahasaku_v1/features/home/screens/contact_us_screen.dart';
import 'package:bahasaku_v1/features/home/screens/terms_and_conditions_screen.dart';
import 'package:bahasaku_v1/features/home/screens/privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel Data User
  String _userName = 'Username';
  String _email = 'username@gmail.com';
  String _phone = 'Tidak ada No Telepon';
  
  // Variabel URL Foto
  String? _photoUrl; 
  
  bool _isNotificationOn = true; 
  final ImagePicker _picker = ImagePicker(); 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- 1. HELPER PENTING: Memperbaiki URL Gambar ---
  String _constructImageUrl(String rawPath) {
    if (rawPath.isEmpty) return '';

    String finalUrl = rawPath;

    // KASUS 1: Jika Backend mengirim path relatif (contoh: /static/foto...)
    if (!rawPath.startsWith('http')) {
       String baseUrl = ApiClient.baseUrl;
       // Bersihkan trailing slash dan /api jika ada
       if (baseUrl.endsWith('/api')) {
         baseUrl = baseUrl.replaceAll('/api', '');
       }
       if (baseUrl.endsWith('/')) {
         baseUrl = baseUrl.substring(0, baseUrl.length - 1);
       }
       finalUrl = '$baseUrl${rawPath.startsWith('/') ? '' : '/'}$rawPath';
    }

    // KASUS 2: Logika Khusus Android Emulator & Port Mapping
    if (Platform.isAndroid) {
      // Langkah A: Ubah localhost menjadi 10.0.2.2 (IP Emulator)
      if (finalUrl.contains('localhost')) {
        finalUrl = finalUrl.replaceAll('localhost', '10.0.2.2');
      }

      // Langkah B: Ubah Port 5000 ke 8080 (PENTING!)
      // Karena di profile.jsx Anda melakukan hal yang sama (5000 -> 8080)
      if (finalUrl.contains(':5000')) {
        finalUrl = finalUrl.replaceAll(':5000', ':8080');
      }
    }

    print("DEBUG FINAL IMAGE URL: $finalUrl"); 
    return finalUrl;
  }

  // --- 2. LOAD DATA USER & SYNC DENGAN API ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Ambil data lokal dulu (Cache)
    setState(() {
      _userName = prefs.getString('userName') ?? 'Username';
      _email = prefs.getString('email') ?? 'username@gmail.com';
      _phone = prefs.getString('phoneNumber') ?? 'Tidak ada No Telepon';
      _isNotificationOn = prefs.getBool('isNotificationOn') ?? true;

      String? rawPath = prefs.getString('photoProfile');
      if (rawPath != null && rawPath.isNotEmpty) {
        _photoUrl = _constructImageUrl(rawPath);
      }
    });

    // 2. Panggil API untuk data terbaru
    await _fetchLatestFromApi();
  }

  Future<void> _fetchLatestFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('token'); 

    if (userId == null) return;

    try {
      final url = Uri.parse('${ApiClient.baseUrl}/users/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json',
        }
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Simpan data terbaru ke SharedPreferences
        if (data['profile_pic_url'] != null) await prefs.setString('photoProfile', data['profile_pic_url']);
        if (data['email'] != null) await prefs.setString('email', data['email']);
        if (data['phone_number'] != null) await prefs.setString('phoneNumber', data['phone_number']);
        if (data['full_name'] != null) await prefs.setString('userName', data['full_name']);

        // Update UI
        if (mounted) {
          setState(() {
            _userName = data['full_name'] ?? _userName;
            _email = data['email'] ?? _email;
            _phone = data['phone_number'] ?? _phone;
            if (data['profile_pic_url'] != null) {
              _photoUrl = _constructImageUrl(data['profile_pic_url']);
            }
          });
        }
      } else {
        print("Gagal fetch user: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error koneksi fetch user: $e");
    }
  }

  // --- 3. UPLOAD FOTO ---
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          title: 'Mengupload...',
          text: 'Mohon tunggu sebentar',
          disableBackBtn: true,
        );

        await _uploadImageToServer(File(image.path));
        
        if (mounted) Navigator.pop(context); // Tutup loading
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImageToServer(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('token');

    if (userId == null) return;

    var uri = Uri.parse('${ApiClient.baseUrl}/users/$userId/photo');
    var request = http.MultipartRequest('POST', uri);
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

    try {
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(respStr);
        
        // Ambil URL dari response: {"user": { "profile_pic_url": "...", ... }}
        String newPhotoPath = jsonResponse['user']['profile_pic_url'];
        
        // Simpan ke memory
        await prefs.setString('photoProfile', newPhotoPath);

        // Update UI dengan URL yang sudah dikonversi (10.0.2.2 & Port 8080)
        if (mounted) {
          setState(() {
            _photoUrl = _constructImageUrl(newPhotoPath);
          });

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil!',
            text: 'Foto Profil telah diperbarui.',
          );
        }
      } else {
        print("Error Upload: $respStr");
        if (mounted) {
           QuickAlert.show(context: context, type: QuickAlertType.error, text: 'Gagal upload foto.');
        }
      }
    } catch (e) {
      if (mounted) {
         QuickAlert.show(context: context, type: QuickAlertType.error, text: 'Koneksi Error: $e');
      }
    }
  }

  void _handleLogout() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Keluar?',
      text: 'Apakah Anda yakin ingin keluar dari aplikasi?',
      confirmBtnText: 'Ya, Keluar',
      cancelBtnText: 'Batal',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================== HEADER BIRU ==================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30), 
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // --- BAGIAN FOTO PROFIL ---
                      Stack(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              // Warna background jika gambar gagal dimuat
                              color: Colors.grey.shade300, 
                              image: DecorationImage(
                                image: (_photoUrl != null && _photoUrl!.isNotEmpty)
                                    ? NetworkImage(_photoUrl!) as ImageProvider
                                    : const AssetImage('assets/images/header_illustration.png'), 
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print("Gagal menampilkan gambar di UI: $_photoUrl");
                                  print("Error detail: $exception");
                                },
                              ),
                            ),
                            // Icon fallback jika foto null
                            child: (_photoUrl == null || _photoUrl!.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white, size: 40)
                                : null,
                          ),
                          // Tombol Kamera Kecil
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primaryBlue),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          _userName, 
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Info Email & Telepon (Card Transparan)
                  _buildGlassInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _email, 
                  ),
                  const SizedBox(height: 15),
                  _buildGlassInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Telepon',
                    value: _phone, 
                  ),
                ],
              ),
            ),

            // ================== MENU ITEMS ==================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Profil',
                    subtitle: 'Kelola informasi pribadi Anda',
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                      _loadUserData(); 
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.headset_mic,
                    title: 'Hubungi Bahasaku',
                    subtitle: 'Bantuan dan dukungan pelanggan',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen())),
                  ),

                  const SizedBox(height: 25),
                  const Text('Lainnya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 15),
                  
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifikasi',
                    subtitle: 'Kelola pemberitahuan aplikasi',
                    isSwitch: true,
                    switchValue: _isNotificationOn,
                    onTap: () {},
                    onSwitchChanged: (val) async {
                      setState(() => _isNotificationOn = val);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isNotificationOn', val);
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.description,
                    title: 'Ketentuan dan Layanan',
                    subtitle: 'Syarat dan ketentuan penggunaan',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen())),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.verified_user, 
                    title: 'Kebijakan Privasi',
                    subtitle: 'Perlindungan data dan privasi',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    subtitle: 'Keluar dari akun Anda',
                    isDestructive: true, 
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: 30),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.phone_android, size: 16, color: Colors.grey),
                        SizedBox(height: 4),
                        Text('v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(height: 8),
                        Text('© 2025, All Right Reserved Bahasaku Indonesia', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildGlassInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isSwitch = false,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
  }) {
    return GestureDetector(
      onTap: isSwitch ? null : onTap, 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive ? const Color(0xFFFFEBEE) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDestructive ? Colors.red : AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            if (isSwitch)
              Switch(value: switchValue, activeColor: Colors.white, activeTrackColor: const Color(0xFF4CAF50), onChanged: onSwitchChanged)
            else
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}