class ApiClient {
  // --- Pake HP Fisik (Wireless LAN adapter Wi-Fi) ---
  static const String ipAddress = '192.168.1.14'; 

  // --- Pake Android Studio Emulator ---
  // static const String ipAddress = '10.0.2.2';

  // Port Server (Sesuai docker-compose)
  static const String port = '8080';
  static const String baseUrl = 'http://$ipAddress:$port/api';

  // Endpoint Auth
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  
  // Endpoint Lainnya
  static const String kosaKata = '$baseUrl/kosa-kata';
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

    if (finalUrl.contains('localhost')) {
      finalUrl = finalUrl.replaceAll('localhost', ipAddress);
    }

    if (finalUrl.contains(':5000')) {
      finalUrl = finalUrl.replaceAll(':5000', ':$port');
    }

    return finalUrl;
  }
}