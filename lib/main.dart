import 'package:flutter/material.dart';
import 'features/auth/screens/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahasaku',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins', // Jika Anda nanti ingin menambahkan font custom
      ),
      home: const LandingPage(),
    );
  }
}