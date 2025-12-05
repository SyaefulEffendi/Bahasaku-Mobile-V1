import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/features/auth/screens/login_screen.dart';
import 'package:quickalert/quickalert.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel Data User
  String _userName = 'Username';
  String _email = 'username@gmail.com';
  String _phone = 'Tidak ada No Telepon'; // Variabel baru untuk No HP
  
  bool _isNotificationOn = true; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- FUNGSI LOAD DATA DARI MEMORI HP ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ambil data sesuai key yang disimpan saat Login
      _userName = prefs.getString('userName') ?? 'Username';
      _email = prefs.getString('email') ?? 'username@gmail.com';
      _phone = prefs.getString('phoneNumber') ?? 'Tidak ada No Telepon';
    });
  }

  // Fungsi Logout
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
        // 1. Hapus Data Login
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 2. Navigasi ke Login (Hapus semua history)
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Tutup Alert
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
                  // Foto Profil & Nama
                  Row(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/header_illustration.png'), 
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          _userName, // Data Nama Dinamis
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

                  // Info Email (Kotak Transparan)
                  _buildGlassInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _email, // Data Email Dinamis
                  ),
                  const SizedBox(height: 15),

                  // Info Telepon (Kotak Transparan)
                  _buildGlassInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Telepon',
                    value: _phone, // Data Telepon Dinamis
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
                  // --- SECTION AKUN ---
                  const Text(
                    'Akun',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Profil',
                    subtitle: 'Kelola informasi pribadi Anda',
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.headset_mic,
                    title: 'Hubungi Bahasaku',
                    subtitle: 'Bantuan dan dukungan pelanggan',
                    onTap: () {},
                  ),

                  const SizedBox(height: 25),

                  // --- SECTION LAINNYA ---
                  const Text(
                    'Lainnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Notifikasi dengan Switch
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifikasi',
                    subtitle: 'Kelola pemberitahuan aplikasi',
                    isSwitch: true,
                    switchValue: _isNotificationOn,
                    onTap: () {},
                    onSwitchChanged: (val) {
                      setState(() => _isNotificationOn = val);
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.description,
                    title: 'Ketentuan dan Layanan',
                    subtitle: 'Syarat dan ketentuan penggunaan',
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.verified_user, 
                    title: 'Kebijakan Privasi',
                    subtitle: 'Perlindungan data dan privasi',
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),
                  
                  // Tombol Keluar
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    subtitle: 'Keluar dari akun Anda',
                    isDestructive: true, 
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: 30),
                  
                  // --- FOOTER VERSION ---
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.phone_android, size: 16, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          'v1.0.0',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '© 2025, All Right Reserved Bahasaku Indonesia',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Spacer bawah
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: INFO BOX TRANSPARAN (HEADER) ---
  Widget _buildGlassInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Efek transparan
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
          // Menggunakan Expanded agar teks panjang tidak overflow (error kuning hitam)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: MENU ITEM (CARD PUTIH) ---
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
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon Kiri (Background Kotak)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive ? const Color(0xFFFFEBEE) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Teks Judul & Subjudul
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Bagian Kanan (Panah atau Switch)
            if (isSwitch)
              Switch(
                value: switchValue,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF4CAF50), 
                onChanged: onSwitchChanged,
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}