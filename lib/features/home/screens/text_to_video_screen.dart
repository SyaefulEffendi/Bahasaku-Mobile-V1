import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:quickalert/quickalert.dart'; // Pastikan sudah install quickalert
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart';
import 'package:bahasaku_v1/features/home/screens/contact_us_screen.dart';

class TextToVideoScreen extends StatefulWidget {
  const TextToVideoScreen({super.key});

  @override
  State<TextToVideoScreen> createState() => _TextToVideoScreenState();
}

class _TextToVideoScreenState extends State<TextToVideoScreen> {
  final TextEditingController _textController = TextEditingController();
  
  // State untuk Data
  List<dynamic> _vocabList = [];
  bool _isFetchingData = true;
  
  // State untuk Video
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllVocabs(); // 1. Ambil semua data saat masuk (mirip useEffect)
  }

  @override
  void dispose() {
    _textController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // --- 1. FETCH DATA DARI API ---
  Future<void> _fetchAllVocabs() async {
    try {
      // Endpoint sesuai backend route: GET /api/kosa-kata/
      final url = Uri.parse('${ApiClient.baseUrl}/kosa-kata/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _vocabList = json.decode(response.body);
          _isFetchingData = false;
        });
        print("Berhasil memuat ${_vocabList.length} kosakata.");
      } else {
        print("Gagal memuat data: ${response.statusCode}");
        setState(() => _isFetchingData = false);
      }
    } catch (e) {
      print("Error koneksi: $e");
      setState(() => _isFetchingData = false);
    }
  }

  // --- 2. LOGIKA CARI & PUTAR VIDEO ---
  void _handleTranslate() async {
    // Reset video lama jika ada
    if (_videoController != null) {
      await _videoController!.pause();
      setState(() {
        _isVideoInitialized = false;
        _videoController = null;
      });
    }

    String inputText = _textController.text.trim().toLowerCase();
    if (inputText.isEmpty) {
      QuickAlert.show(context: context, type: QuickAlertType.warning, text: 'Mohon masukkan teks terlebih dahulu.');
      return;
    }

    FocusScope.of(context).unfocus(); // Tutup keyboard
    setState(() => _isVideoLoading = true);

    // Cari kecocokan di list lokal (Case Insensitive)
    // Sesuai logika React: const matchedVocab = vocabs.find(...)
    final matchedVocab = _vocabList.firstWhere(
      (vocab) => vocab['text'].toString().toLowerCase() == inputText,
      orElse: () => null,
    );

    // Simulasi delay sedikit agar terasa prosesnya (opsional)
    await Future.delayed(const Duration(milliseconds: 500));

    if (matchedVocab != null) {
      String rawVideoPath = matchedVocab['video_file_path'];
      await _initializeVideo(rawVideoPath);
    } else {
      setState(() => _isVideoLoading = false);
      _showNotFoundDialog(inputText);
    }
  }

  // Helper untuk Memperbaiki URL Video (PENTING UNTUK EMULATOR)
  Future<void> _initializeVideo(String rawPath) async {
    // Logika convert URL sama seperti di Profile Screen
    String finalUrl = rawPath;

    if (!rawPath.startsWith('http')) {
       String baseUrl = ApiClient.baseUrl;
       // Bersihkan /api jika url video ada di root static
       if (baseUrl.endsWith('/api')) baseUrl = baseUrl.replaceAll('/api', '');
       if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
       
       finalUrl = '$baseUrl${rawPath.startsWith('/') ? '' : '/'}$rawPath';
    }

    if (Platform.isAndroid && finalUrl.contains('localhost')) {
      finalUrl = finalUrl.replaceAll('localhost', '10.0.2.2');
    }
    
    // Ganti port jika perlu (misal backend lari di 5000 tapi diakses via 8080)
    if (Platform.isAndroid && finalUrl.contains(':5000')) {
      finalUrl = finalUrl.replaceAll(':5000', ':8080');
    }

    print("Playing Video URL: $finalUrl");

    // Init Video Player
    _videoController = VideoPlayerController.networkUrl(Uri.parse(finalUrl));

    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true); // Loop video
      await _videoController!.play(); // Auto play
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      print("Error playing video: $e");
      if (mounted) {
        setState(() => _isVideoLoading = false);
        QuickAlert.show(context: context, type: QuickAlertType.error, text: 'Gagal memutar video.');
      }
    }
  }

  void _showNotFoundDialog(String word) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Tidak Ditemukan',
      text: 'Kata "$word" belum tersedia di database kami.',
      confirmBtnText: 'Laporkan',
      cancelBtnText: 'Batal',
      showCancelBtn: true,
      onConfirmBtnTap: () {
        Navigator.pop(context); // Tutup alert
        // Navigasi ke halaman kontak (sesuai logika React)
        Navigator.push(context, MaterialPageRoute(builder: (c) => ContactUsScreen()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teks ke Video"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- INPUT SECTION ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Masukkan kata atau kalimat',
                        hintText: 'Contoh: Makan, Tidur...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.keyboard),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: (_isFetchingData || _isVideoLoading) ? null : _handleTranslate,
                        icon: _isVideoLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.translate),
                        label: Text(_isVideoLoading ? "Memproses..." : "Terjemahkan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- VIDEO PLAYER SECTION ---
            if (_isVideoInitialized && _videoController != null)
              Column(
                children: [
                  const Text("Hasil Terjemahan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController!),
                            _ControlsOverlay(controller: _videoController!), // Kontrol Play/Pause
                            VideoProgressIndicator(_videoController!, allowScrubbing: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (!_isFetchingData && !_isVideoLoading)
              Column(
                children: [
                  Icon(Icons.videocam_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text("Video terjemahan akan muncul di sini", style: TextStyle(color: Colors.grey)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Widget Kecil untuk Overlay Tombol Play/Pause
class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 50.0),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}