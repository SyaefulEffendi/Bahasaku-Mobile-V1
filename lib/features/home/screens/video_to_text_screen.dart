import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart'; 

class VideoToTextScreen extends StatefulWidget {
  const VideoToTextScreen({super.key});

  @override
  State<VideoToTextScreen> createState() => _VideoToTextScreenState();
}

class _VideoToTextScreenState extends State<VideoToTextScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  
  // Variabel baru untuk melacak index kamera (0 biasanya belakang, 1 biasanya depan)
  int _selectedCameraIndex = 0;
  
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  String _translationResult = "Menunggu gerakan...";
  Timer? _timer;

  final Uri _apiUri = Uri.parse('${ApiClient.baseUrl}/ai/predict');

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. Ambil list kamera jika belum ada
      cameras ??= await availableCameras();
      
      if (cameras == null || cameras!.isEmpty) {
        print("Tidak ada kamera ditemukan");
        return;
      }

      // 2. Set default ke kamera depan saat pertama kali buka (opsional)
      // Jika _cameraController belum pernah diinit, cari kamera depan
      if (_cameraController == null) {
        int frontIndex = cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
        _selectedCameraIndex = frontIndex != -1 ? frontIndex : 0;
      }

      // 3. Inisialisasi controller berdasarkan index yang dipilih
      _cameraController = CameraController(
        cameras![_selectedCameraIndex],
        ResolutionPreset.medium, 
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error inisialisasi kamera: $e");
    }
  }

  // --- FUNGSI BARU: Ganti Kamera ---
  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hanya satu kamera terdeteksi')),
      );
      return;
    }

    // 1. Matikan timer scanning sementara (agar tidak crash saat switch)
    bool wasScanning = _isScanning;
    if (wasScanning) {
      _timer?.cancel();
    }

    // 2. Dispose controller lama
    await _cameraController?.dispose();

    // 3. Ganti Index Kamera
    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;
    });

    // 4. Inisialisasi ulang dengan index baru
    await _initializeCamera();

    // 5. Nyalakan scanning lagi jika sebelumnya sedang scanning
    if (wasScanning && mounted) {
      setState(() {
        _isScanning = true;
      });
      _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        _captureAndSendFrame();
      });
    }
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        _captureAndSendFrame();
      });
    } else {
      _timer?.cancel();
      setState(() {
        _translationResult = "Scan berhenti.";
      });
    }
  }

  Future<void> _captureAndSendFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isTakingPicture) return;

    try {
      final XFile imageFile = await _cameraController!.takePicture();

      var request = http.MultipartRequest('POST', _apiUri);
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = json.decode(respStr);
        
        String detectedText = jsonResponse['text'] ?? "";
        
        if (mounted) {
          setState(() {
            if (detectedText.isNotEmpty) {
              _translationResult = detectedText;
            }
          });
        }
      } else {
        print("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error capturing/sending: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Penerjemah Bahasa Isyarat"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. Tampilan Kamera
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CameraPreview(_cameraController!),
          ),

          // 2. Overlay Tombol Switch (Opsional, jika ingin tombol mengambang di layar)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                onPressed: _switchCamera,
              ),
            ),
          ),

          // 3. Overlay Hasil & Tombol Scan
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Hasil Terjemahan:",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _translationResult,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _toggleScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isScanning ? Colors.red : AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(_isScanning ? Icons.stop : Icons.videocam, color: Colors.white),
                      label: Text(
                        _isScanning ? "Hentikan Scan" : "Mulai Deteksi",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}