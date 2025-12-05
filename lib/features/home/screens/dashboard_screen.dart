import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Import ini
import 'package:bahasaku_v1/core/constants/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _userName = 'User'; // 2. Variable untuk menampung nama

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 3. Panggil fungsi ambil data saat layar dibuka
  }

  // 4. Fungsi mengambil nama dari SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ambil 'userName' yang disimpan saat login, default 'User' jika kosong
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ================== BAGIAN 1: HEADER ==================
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kiri: Logo & Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/logo_circle.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // 5. TAMPILKAN NAMA USER DI SINI
                        Text(
                          'Hi, $_userName', 
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        const Text(
                          'Yuk jelajahi Dunia Tuli bersama Evull!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Kanan: Ilustrasi
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: Image.asset(
                      'assets/images/header_illustration.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topRight,
                    ),
                  ),
                ],
              ),
            ),

            // ================== BAGIAN 2: KONTEN UTAMA ==================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      // --- GRID MENU ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMenuButton(
                                  title: 'Text to Video',
                                  imagePath: 'assets/images/menu_text_to_video.png',
                                  onTap: () => print("Text to Video Clicked"),
                                  imageSize: 85.0,
                                ),
                                _buildMenuButton(
                                  title: 'Video to Text',
                                  imagePath: 'assets/images/menu_video_to_text.png',
                                  onTap: () => print("Video to Text Clicked"),
                                  imageSize: 55.0,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMenuButton(
                                  title: 'Kamus Isyarat',
                                  imagePath: 'assets/images/menu_dictionary.png',
                                  onTap: () => print("Kamus Isyarat Clicked"),
                                  imageSize: 65.0,
                                ),
                                _buildMenuButton(
                                  title: 'Hubungi Bahasaku',
                                  imagePath: 'assets/images/menu_contact.png',
                                  onTap: () => print("Hubungi Clicked"),
                                  imageSize: 65.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ================== BAGIAN 3: INFORMASI TERBARU (BIRU BAWAH) ==================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Informasi Terbaru',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => print("Lihat Semua"),
                                  child: const Text(
                                    'Lihat Semua',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // --- LIST KARTU INFORMASI ---
                            _buildInfoCard(
                              title: 'Tips Belajar Isyarat Cepat',
                              description: 'Pelajari dasar-dasar gerakan tangan dalam 5 menit sehari.',
                              date: '12 Des 2025',
                              icon: Icons.lightbulb_outline,
                            ),
                            const SizedBox(height: 12),

                            _buildInfoCard(
                              title: 'Event Komunitas Tuli',
                              description: 'Ikuti gathering online bersama teman-teman Tuli se-Indonesia.',
                              date: '20 Des 2025',
                              icon: Icons.event,
                            ),
                            
                            const SizedBox(height: 30), 
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Informasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  // --- WIDGET HELPER: TOMBOL MENU ---
  Widget _buildMenuButton({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
    double imageSize = 70.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFBBDAF1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                height: imageSize,
                width: imageSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: KARTU INFORMASI ---
  Widget _buildInfoCard({
    required String title,
    required String description,
    required String date,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), 
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}