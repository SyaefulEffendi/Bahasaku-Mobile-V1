import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart';
import 'package:bahasaku_v1/features/home/screens/information_detail_screen.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  List<dynamic> _infoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllInfo();
  }

  // --- FETCH DATA API ---
  Future<void> _fetchAllInfo() async {
    try {
      // Ambil semua data (tanpa limit)
      final url = Uri.parse('${ApiClient.baseUrl}/information/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _infoList = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        print("Gagal fetch info: ${response.statusCode}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error koneksi info screen: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper URL Gambar
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================== BAGIAN 1: HEADER INFORMASI ==================
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: Text(
              'Informasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // ================== BAGIAN 2: KONTEN LIST (KARTU) ==================
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _infoList.isEmpty
                ? const Center(child: Text("Belum ada informasi terbaru", style: TextStyle(color: Colors.grey)))
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'Informasi Terkini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Text(
                        'Dapatkan informasi terbaru dari Bahasaku',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- LIST KARTU DARI API ---
                      ..._infoList.map((info) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => InformationDetailScreen(infoData: info)));
                          },
                          child: _buildBigInfoCard(
                            title: info['title'] ?? '',
                            date: info['created_at'] ?? '-',
                            imageUrl: _constructImageUrl(info['image_url']),
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // Widget Helper Kartu Besar (Styling Sama Persis)
  Widget _buildBigInfoCard({required String title, required String date, required String imageUrl}) {
    return Container(
      width: double.infinity,
      height: 200, // Tinggi kartu
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bagian Atas: Gambar (Sekarang Dinamis)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Warna dasar abu-abu
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.image, color: Colors.white, size: 50),
                    )
                  : null,
            ),
          ),
          
          // Bagian Bawah: Teks Judul & Tanggal
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}