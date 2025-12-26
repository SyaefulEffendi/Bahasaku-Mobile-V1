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
  
  int _selectedCameraIndex = 0;
  
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  
  bool _isFlashOn = false; 
  bool _isProcessing = false; 

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
      cameras ??= await availableCameras();
      
      if (cameras == null || cameras!.isEmpty) {
        debugPrint("Tidak ada kamera ditemukan");
        return;
      }

      if (_cameraController == null) {
        int frontIndex = cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
        _selectedCameraIndex = frontIndex != -1 ? frontIndex : 0;
      }

      _cameraController = CameraController(
        cameras![_selectedCameraIndex],
        ResolutionPreset.medium, 
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.jpeg 
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
      } catch (_) {}

      // Reset Zoom ke 1.0
      try {
        double minZoom = await _cameraController!.getMinZoomLevel();
        double maxZoom = await _cameraController!.getMaxZoomLevel();
        double targetZoom = 1.0; 
        if (targetZoom < minZoom) targetZoom = minZoom;
        if (targetZoom > maxZoom) targetZoom = maxZoom;
        await _cameraController!.setZoomLevel(targetZoom);
      } catch (e) {
        debugPrint("Gagal set zoom: $e");
      }

      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _isFlashOn = false;
      });
    } catch (e) {
      debugPrint("Error inisialisasi kamera: $e");
    }
  }

  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    bool wasScanning = _isScanning;
    if (wasScanning) {
      _timer?.cancel();
    }

    await _cameraController?.dispose();

    CameraDescription currentCamera = cameras![_selectedCameraIndex];
    int newIndex = 0;

    if (currentCamera.lensDirection == CameraLensDirection.front) {
      newIndex = cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      if (newIndex == -1) newIndex = 0;
    } else {
      newIndex = cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (newIndex == -1) newIndex = 0;
    }

    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = newIndex;
    });

    await _initializeCamera();

    if (wasScanning && mounted) {
      _startScanning();
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      FlashMode mode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(mode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyalakan flash')),
      );
    }
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _startScanning();
    } else {
      _timer?.cancel();
      setState(() {
        _translationResult = "Scan berhenti.";
        _isProcessing = false; 
      });
    }
  }

  void _startScanning() {
    _timer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      _captureAndSendFrame();
    });
  }

  Future<void> _captureAndSendFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isTakingPicture) return;
    
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();

      var request = http.MultipartRequest('POST', _apiUri);
      
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imageFile.path,
      ));

      var response = await request.send().timeout(const Duration(seconds: 5));

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
      } 
      
      File(imageFile.path).delete().catchError((e) => null);

    } catch (e) {
      debugPrint("Skip frame (network/camera busy): $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    final bool isBackCamera = cameras![_selectedCameraIndex].lensDirection == CameraLensDirection.back;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Penerjemah Bahasa Isyarat"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. LAYER KAMERA (Preview Fullscreen)
          Center(
            child: CameraPreview(_cameraController!),
          ),

          // 2. LAYER OVERLAY (Membuat area luar kotak menjadi gelap)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), 
              BlendMode.srcOut // Teknik membuat 'lubang' transparan
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    height: 280, // Ukuran Kotak Vertikal
                    width: 280,  // Ukuran Kotak Horizontal
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. LAYER BORDER & TEXT GUIDE (Bingkai Asli)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Teks Petunjuk di atas kotak
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Letakkan tangan di dalam kotak",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ),
                // Kotak Bingkai
                Container(
                  height: 280, 
                  width: 280,
                  decoration: BoxDecoration(
                    // Border Putih saat diam, Hijau saat Scan aktif
                    border: Border.all(
                      color: _isScanning ? Colors.greenAccent : Colors.white, 
                      width: 3
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),

          // 4. INDIKATOR STATUS (Pojok Kiri Atas)
          if (_isScanning)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isProcessing ? Colors.orange.withOpacity(0.8) : Colors.green.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(_isProcessing ? Icons.sync : Icons.radar, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _isProcessing ? "Menganalisa..." : "Mendeteksi",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // 5. TOMBOL CONTROLLER (Flash & Switch Camera - Kanan Atas)
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                    onPressed: _switchCamera,
                  ),
                ),
                if (isBackCamera)
                  Container(
                    decoration: BoxDecoration(
                      color: _isFlashOn 
                          ? Colors.yellow.withOpacity(0.8) 
                          : Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off, 
                        color: _isFlashOn ? Colors.black : Colors.white
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),
              ],
            ),
          ),

          // 6. PANEL HASIL TERJEMAHAN (Bawah)
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