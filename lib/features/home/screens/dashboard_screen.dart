import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/features/home/screens/information_screen.dart';
import 'package:bahasaku_v1/features/home/screens/profile_screen.dart';
// IMPORT BARU: Import file VideoToTextScreen agar bisa dipanggil
import 'package:bahasaku_v1/features/home/screens/video_to_text_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // 0 = Home, 1 = Info, 2 = Akun
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
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
        // LOGIKA SWITCHING HALAMAN
        child: _selectedIndex == 0 
            ? _buildHomeContent() 
            : _selectedIndex == 1 
                ? const InformationScreen() 
                : const ProfileScreen(),
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

  // ==========================================
  // KONTEN HALAMAN HOME (DIPISAH KE FUNGSI)
  // ==========================================
  Widget _buildHomeContent() {
    return Column(
      children: [
        // --- HEADER ---
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 45, width: 45,
                          decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/images/logo_circle.png', fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bahasaku', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                              SizedBox(height: 2),
                              Text('Sistem Penerjemah Bahasa Isyarat', style: TextStyle(fontSize: 9, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Hi, $_userName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('Yuk jelajahi Dunia Tuli bersama Evull!', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  height: 150, width: 150,
                  child: Image.asset('assets/images/header_illustration.png', fit: BoxFit.contain, alignment: Alignment.topRight),
                ),
              ),
            ],
          ),
        ),

        // --- BODY MENU ---
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMenuButton(title: 'Text to Video', imagePath: 'assets/images/menu_text_to_video.png', onTap: () {}, imageSize: 85.0),
                            
                            // === TOMBOL VIDEO TO TEXT ===
                            _buildMenuButton(
                              title: 'Video to Text', 
                              imagePath: 'assets/images/menu_video_to_text.png', 
                              onTap: () {
                                // NAVIGASI KE SCREEN VIDEO TO TEXT
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const VideoToTextScreen()),
                                );
                              }, 
                              imageSize: 55.0
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMenuButton(title: 'Kamus Isyarat', imagePath: 'assets/images/menu_dictionary.png', onTap: () {}, imageSize: 65.0),
                            _buildMenuButton(title: 'Hubungi Bahasaku', imagePath: 'assets/images/menu_contact.png', onTap: () {}, imageSize: 65.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Bagian Info Terbaru (Preview di Home)
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Informasi Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            GestureDetector(
                              // Saat klik "Lihat Semua", pindah tab ke index 1 (Informasi)
                              onTap: () => _onItemTapped(1), 
                              child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(title: 'Tips Belajar Isyarat Cepat', description: 'Pelajari dasar-dasar...', date: '12 Des 2025', icon: Icons.lightbulb_outline),
                        const SizedBox(height: 12),
                        _buildInfoCard(title: 'Event Komunitas Tuli', description: 'Ikuti gathering online...', date: '20 Des 2025', icon: Icons.event),
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
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildMenuButton({required String title, required String imagePath, required VoidCallback onTap, double imageSize = 70.0}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 100, width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFBBDAF1), shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Center(child: Image.asset(imagePath, height: imageSize, width: imageSize, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String description, required String date, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45, width: 45,
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(date, style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}