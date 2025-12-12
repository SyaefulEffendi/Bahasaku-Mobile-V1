import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bahasaku_v1/core/constants/colors.dart';
import 'package:bahasaku_v1/core/api/api_client.dart';

class InformationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> infoData;

  const InformationDetailScreen({super.key, required this.infoData});

  // Helper URL (Copy logic yang sama agar gambar muncul di Emulator)
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
    final String imageUrl = _constructImageUrl(infoData['image_url']);
    final bool hasEdit = infoData['updated_at'] != '-' && infoData['updated_at'] != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- APP BAR DENGAN GAMBAR ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[300], child: Icon(Icons.image_not_supported, size: 50)),
                    )
                  : Container(color: AppColors.primaryBlue.withOpacity(0.1), child: Icon(Icons.article, size: 80, color: AppColors.primaryBlue)),
            ),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: AppColors.textDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // --- KONTEN BERITA ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    infoData['title'] ?? 'Tanpa Judul',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.3),
                  ),
                  const SizedBox(height: 16),

                  // Info Metadata (Penulis & Tanggal)
                  Row(
                    children: [
                      const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.person, size: 18, color: AppColors.primaryBlue)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(infoData['created_by'] ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(infoData['created_at'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),

                  // Info Edit (Jika ada)
                  if (hasEdit) 
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_note, size: 14, color: Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            "Diedit oleh ${infoData['updated_by']} pada ${infoData['updated_at']}",
                            style: const TextStyle(fontSize: 10, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),

                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                  // Isi Konten
                  Text(
                    infoData['content'] ?? '',
                    style: const TextStyle(fontSize: 16, height: 1.8, color: Color(0xFF4A4A4A)),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}