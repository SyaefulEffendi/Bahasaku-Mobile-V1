// lib/core/api/api_client.dart
class ApiClient {
  // GANTI IP INI SESUAI IPCONFIG LAPTOP ANDA
  // Jangan pakai localhost untuk HP Fisik!
  //pake andorid studio:
  //static const String baseUrl = 'http://10.0.2.2:8080/api';
  //pake hp fisik: gunakan Wireless LAN adapter Wi-Fi: IPv4 Address. . . . . . . . . . . :
  static const String baseUrl = 'http://10.17.166.114:8080/api';

  
  // Endpoint Auth
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  
  // Endpoint Lainnya nanti
  static const String kosaKata = '$baseUrl/kosa-kata';
}