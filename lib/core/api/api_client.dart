// lib/core/api/api_client.dart
class ApiClient {
  // GANTI IP INI SESUAI IPCONFIG LAPTOP ANDA
  // Jangan pakai localhost untuk HP Fisik!
  static const String baseUrl = 'http://192.168.23.207:5000/api'; 
  
  // Endpoint Auth
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  
  // Endpoint Lainnya nanti
  static const String kosaKata = '$baseUrl/kosa-kata';
}