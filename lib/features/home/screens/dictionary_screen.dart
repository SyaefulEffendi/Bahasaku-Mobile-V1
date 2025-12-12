import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  // Data
  List<dynamic> _allVocabs = [];
  Map<String, List<dynamic>> _groupedVocabs = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchVocabs();
  }

  // --- 1. FETCH & GROUP DATA ---
  Future<void> _fetchVocabs() async {
    try {
      final url = Uri.parse('${ApiClient.baseUrl}/kosa-kata/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Grouping data berdasarkan kategori
        Map<String, List<dynamic>> grouped = {};
        for (var item in data) {
          String category = item['category'] ?? 'Lainnya';
          if (!grouped.containsKey(category)) {
            grouped[category] = [];
          }
          grouped[category]!.add(item);
        }

        setState(() {
          _allVocabs = data;
          _groupedVocabs = grouped;
          _isLoading = false;
        });
      } else {
        print("Gagal load data: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 2. HELPER URL VIDEO ---
  String _constructVideoUrl(String rawPath) {
    String finalUrl = rawPath;
    if (!rawPath.startsWith('http')) {
       String baseUrl = ApiClient.baseUrl;
       if (baseUrl.endsWith('/api')) baseUrl = baseUrl.replaceAll('/api', '');
       if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
       finalUrl = '$baseUrl${rawPath.startsWith('/') ? '' : '/'}$rawPath';
    }
    if (Platform.isAndroid && finalUrl.contains('localhost')) {
      finalUrl = finalUrl.replaceAll('localhost', '10.0.2.2');
    }
    // Handle port mapping jika perlu
    if (Platform.isAndroid && finalUrl.contains(':5000')) {
      finalUrl = finalUrl.replaceAll(':5000', ':8080');
    }
    return finalUrl;
  }

  @override
  Widget build(BuildContext context) {
    // Filter kategori berdasarkan search query jika ada
    Map<String, List<dynamic>> displayData = {};
    
    if (_searchQuery.isEmpty) {
      displayData = _groupedVocabs;
    } else {
      // Jika sedang mencari, kita tampilkan list kata langsung atau tetap per kategori
      // Disini saya buat agar menampilkan kategori yang mengandung kata tersebut
      _groupedVocabs.forEach((key, value) {
        var filteredList = value.where((element) => 
          element['text'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
        
        if (filteredList.isNotEmpty) {
          displayData[key] = filteredList;
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Background abu sangat muda agar clean
      body: Stack(
        children: [
          // --- HEADER BACKGROUND ---
          Container(
            height: 280,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER CONTENT ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(child: SizedBox()), // Spacer
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Kamusku',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tingkatkan kemampuan Bahasa Isyarat kamu dengan melihat daftar kosakata di Kamusku',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ilustrasi 3D Evull
                      SizedBox(
                        width: 140,
                        height: 160,
                        child: Image.asset(
                          'assets/images/image_kamusku.png', // Pastikan aset ini ada
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- SEARCH BAR (Mengambang) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Cari gerakan Bahasa Isyarat',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- CONTENT LIST ---
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : displayData.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                          itemCount: displayData.keys.length + 1, // +1 untuk header info
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildInfoBanner();
                            }
                            
                            String category = displayData.keys.elementAt(index - 1);
                            List<dynamic> items = displayData[category]!;
                            
                            return _buildCategoryCard(category, items);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Info Banner Kecil ---
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.blueAccent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Kategori untuk melihat hasil terjemahan sesuai dengan kategori',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Kartu Kategori ---
  Widget _buildCategoryCard(String category, List<dynamic> items) {
    // Tentukan gambar berdasarkan kategori
    String imagePath = 'assets/images/menu_dictionary.png'; // Default
    if (category.toLowerCase().contains('huruf') || category.toLowerCase().contains('alfabet')) {
      imagePath = 'assets/images/kamusku_alfabet.png';
    } 
    // Tambahkan else if lain jika punya aset untuk kategori Angka, Salam, dll.

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gambar Header Kategori
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [const Color(0xFFE3F2FD), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
          
          // Info Kategori & Tombol
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${items.length} gerakan',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _showWordListModal(context, category, items);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5), // Warna biru agak terang sedikit
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Mulai Melihat',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            'Tidak ada kosakata ditemukan',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // --- MODAL: Daftar Kata dalam Kategori ---
  void _showWordListModal(BuildContext context, String category, List<dynamic> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Row(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${items.length} Item',
                        style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30),
              
              // List Grid Kata
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 kolom
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
                    return GestureDetector(
                      onTap: () {
                        _playVideoDialog(context, item);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['text'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- DIALOG: Putar Video ---
  void _playVideoDialog(BuildContext context, dynamic item) {
    String videoUrl = _constructVideoUrl(item['video_file_path']);
    
    showDialog(
      context: context,
      builder: (context) {
        return _VideoPlayerDialog(videoUrl: videoUrl, title: item['text']);
      },
    );
  }
}

// --- WIDGET TERPISAH: Video Player Dialog ---
// Agar controller ter-dispose dengan benar saat dialog ditutup
class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String title;

  const _VideoPlayerDialog({required this.videoUrl, required this.title});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.play(); // Auto play
          _controller.setLooping(true);
        });
      }).catchError((error) {
        print("Error video: $error");
        setState(() => _hasError = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Isyarat: "${widget.title}"',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 10),
            
            // Area Video
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _hasError
                ? const Center(child: Text('Gagal memuat video', style: TextStyle(color: Colors.white)))
                : _initialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            
            const SizedBox(height: 16),
            const Text(
              "Tekan luar kotak untuk menutup",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}