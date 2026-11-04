import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CategoryModel>> _categoriesFuture;
  final ApiService _apiService = ApiService();

  // Color Palette DOKEMAS
  static const Color primaryGreen = Color(0xFF198754);
  static const Color navyDark = Color(0xFF0D233A);

  @override
  void initState() {
    super.initState();
    // Memanggil API saat widget pertama kali diinisialisasi
    _categoriesFuture = _apiService.getCategories();
  }

  // Helper untuk memetakan nama ikon Bootstrap/API ke IconData Material
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'bi-tree-fill':
        return Icons.park;
      case 'bi-cup-hot-fill':
        return Icons.restaurant;
      case 'bi-people-fill':
        return Icons.groups;
      case 'bi-bank':
        return Icons.account_balance;
      case 'bi-moon-stars-fill':
        return Icons.nights_stay;
      default:
        return Icons.explore;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Sidebar Navigasi Desktop
          Container(
            width: 240,
            color: navyDark,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo DOKEMAS (Kotak Putih 40x40px pada background gelap)
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.terrain,
                        color: primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'DOKEMAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.white),
                  title: const Text(
                    'Kategori',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.place_outlined,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Destinasi',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Area Konten Utama
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori Wisata Banyumas',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: navyDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Platform Kurasi Perjalanan & Ekowisata Kabupaten Banyumas',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // FutureBuilder untuk Fetch & Menampilkan Data Kategori
                  Expanded(
                    child: FutureBuilder<List<CategoryModel>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Gagal mengambil data: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'Tidak ada data kategori yang ditemukan.',
                            ),
                          );
                        }

                        final categories = snapshot.data!;

                        // Grid Kategori Responsif untuk Desktop
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 240,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primaryGreen.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(category.icon),
                                        size: 28,
                                        color: primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${category.destinationsCount} Destinasi',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
