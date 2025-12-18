// lib/core/api/api_client.dart
class ApiClient {
  // =======================================================================
  // 1. PENGATURAN IP ADDRESS (GANTI DI SINI SAJA)
  // =======================================================================
  
  // GANTI IP INI SESUAI IPCONFIG LAPTOP
  // Jangan pakai localhost untuk HP Fisik!

  // --- OPSI A: Pake HP Fisik (Wireless LAN adapter Wi-Fi) ---
  // Pastikan cek 'ipconfig' setiap kali connect hotspot, karena bisa berubah!
  static const String ipAddress = '10.2.4.230'; 

  // --- OPSI B: Pake Android Studio Emulator ---
  // Hapus tanda komentar (//) di bawah jika pakai Emulator, dan matikan Opsi A
  // static const String ipAddress = '10.0.2.2';

  // Port Server (Sesuai docker-compose)
  static const String port = '8080';
  
  // Base URL (Otomatis menggabungkan IP dan Port di atas)
  static const String baseUrl = 'http://$ipAddress:$port/api';

  // =======================================================================
  // 2. DAFTAR ENDPOINT API
  // =======================================================================
  
  // Endpoint Auth
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  
  // Endpoint Lainnya
  static const String kosaKata = '$baseUrl/kosa-kata';

  // =======================================================================
  // 3. FUNGSI MAGIC UNTUK GAMBAR (Panggil ini di semua layar)
  // =======================================================================
  static String getImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return '';

    String finalUrl = rawPath;

    // A. Jika path relatif (misal: /static/foto.jpg), gabungkan dengan Base URL
    if (!rawPath.startsWith('http')) {
       // Ambil root URL (http://ip:port) tanpa '/api'
       String rootUrl = baseUrl.replaceAll('/api', ''); 
       if (rootUrl.endsWith('/')) rootUrl = rootUrl.substring(0, rootUrl.length - 1);
       
       finalUrl = '$rootUrl${rawPath.startsWith('/') ? '' : '/'}$rawPath';
    }

    // B. Perbaikan Otomatis: Ganti 'localhost' dengan IP yang kita set di atas
    // Ini penting jika database menyimpan URL lama sebagai localhost
    if (finalUrl.contains('localhost')) {
      finalUrl = finalUrl.replaceAll('localhost', ipAddress);
    }

    // C. Perbaikan Port: Pastikan pakai port 8080 (bukan 5000)
    if (finalUrl.contains(':5000')) {
      finalUrl = finalUrl.replaceAll(':5000', ':$port');
    }

    return finalUrl;
  }
}