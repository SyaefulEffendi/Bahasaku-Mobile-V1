import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart';

// --- IMPORT LAYAR LAIN ---
import 'package:bahasaku_v1/features/home/screens/information_screen.dart';
import 'package:bahasaku_v1/features/home/screens/information_detail_screen.dart'; // Pastikan file ini sudah dibuat
import 'package:bahasaku_v1/features/home/screens/profile_screen.dart';
import 'package:bahasaku_v1/features/home/screens/video_to_text_screen.dart';
import 'package:bahasaku_v1/features/home/screens/contact_us_screen.dart';
import 'package:bahasaku_v1/features/home/screens/text_to_video_screen.dart';
import 'package:bahasaku_v1/features/home/screens/dictionary_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // 0 = Home, 1 = Info, 2 = Akun
  String _userName = 'User';
  
  // Data Informasi Terbaru dari API
  List<dynamic> _recentInfo = [];
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchRecentInfo(); // Ambil data info saat dashboard dibuka
  }

  // --- 1. LOAD USER DATA ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  // --- 2. FETCH INFO TERBARU (LIMIT 2) ---
  Future<void> _fetchRecentInfo() async {
    try {
      // Panggil API dengan parameter limit=2
      final url = Uri.parse('${ApiClient.baseUrl}/information/?limit=2');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _recentInfo = json.decode(response.body);
            _isLoadingInfo = false;
          });
        }
      } else {
        print("Gagal fetch info: ${response.statusCode}");
        if (mounted) setState(() => _isLoadingInfo = false);
      }
    } catch (e) {
      print("Error koneksi dashboard info: $e");
      if (mounted) setState(() => _isLoadingInfo = false);
    }
  }

  // Helper URL Gambar (Sama seperti di ProfileScreen)
  String _constructImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return '';
    String finalUrl = rawPath;
    if (!rawPath.startsWith('http')) {
       String baseUrl = ApiClient.baseUrl;
       if (baseUrl.endsWith('/api')) baseUrl = baseUrl.replaceAll('/api', '');
       if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
       finalUrl = '$baseUrl${rawPath.startsWith('/') ? '' : '/'}$rawPath';
    }
    if (Platform.isAndroid) {
      if (finalUrl.contains('localhost')) finalUrl = finalUrl.replaceAll('localhost', '10.0.2.2');
      if (finalUrl.contains(':5000')) finalUrl = finalUrl.replaceAll(':5000', ':8080');
    }
    return finalUrl;
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
  // KONTEN HALAMAN HOME
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

        // --- BODY (MENU & INFO) ---
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
                  // --- MENU GRID ---
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
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TextToVideoScreen())), 
                              imageSize: 85.0
                            ),
                            _buildMenuButton(
                              title: 'Video to Text', 
                              imagePath: 'assets/images/menu_video_to_text.png', 
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VideoToTextScreen())), 
                              imageSize: 55.0
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
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DictionaryScreen())), 
                              imageSize: 65.0
                            ),
                            _buildMenuButton(
                              title: 'Hubungi Bahasaku', 
                              imagePath: 'assets/images/menu_contact.png', 
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ContactUsScreen())), 
                              imageSize: 65.0
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // --- INFORMASI TERBARU (DYNAMIC) ---
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
                              onTap: () => _onItemTapped(1), // Pindah ke tab Info
                              child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Loading State
                        if (_isLoadingInfo)
                          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white)))
                        
                        // Empty State
                        else if (_recentInfo.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: Text("Belum ada informasi terbaru.", style: TextStyle(color: Colors.white70))),
                          )
                        
                        // List Data
                        else
                          Column(
                            children: _recentInfo.map((info) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildInfoCard(
                                title: info['title'] ?? '',
                                description: info['content'] ?? '',
                                date: info['created_at'] ?? '-',
                                imageUrl: _constructImageUrl(info['image_url']), // Kirim URL
                                onTap: () {
                                  // Navigasi ke Detail saat diklik
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => InformationDetailScreen(infoData: info)));
                                }
                              ),
                            )).toList(),
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

  // Updated Info Card (Terima onTap & ImageUrl)
  Widget _buildInfoCard({
    required String title, 
    required String description, 
    required String date, 
    required String imageUrl, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Gambar
            Container(
              height: 50, width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), 
                borderRadius: BorderRadius.circular(10),
                image: imageUrl.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null
              ),
              child: imageUrl.isEmpty 
                ? const Icon(Icons.article, color: AppColors.primaryBlue, size: 24) 
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(date, style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}