// services/cache_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoney/models/alokasiModel.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache data
  List<AlokasiModel>? _cachedAlokasiList;
  bool _isLoading = false;

  // Getters untuk akses konstanta
  List<AlokasiModel> get alokasiList {
    if (_cachedAlokasiList == null) {
      throw Exception('Alokasi data not loaded yet. Call loadAllData() first.');
    }
    return _cachedAlokasiList!;
  }

  // Load semua data (panggil sekali di awal aplikasi)
  Future<void> loadAllData({bool forceRefresh = false}) async {
    // Jika sudah loading, tunggu
    if (_isLoading) return;

    _isLoading = true;

    try {
      print('Loading fresh data from Firestore...');

      // Load alokasi data
      final alokasiSnapshot = await FirebaseFirestore.instance
          .collection('alokasis')
          .get();

      _cachedAlokasiList = alokasiSnapshot.docs
          .map((doc) => AlokasiModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading data: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  // Refresh data (paksa load baru)
  Future<void> refreshData() async {
    await loadAllData(forceRefresh: true);
  }

  // Get single alokasi by name
  AlokasiModel? getAlokasiByName(String name) {
    return _cachedAlokasiList?.firstWhere(
      (a) => a.name == name,
      orElse: () => throw Exception('Alokasi not found: $name'),
    );
  }

  // Get subcategories untuk alokasi tertentu
  List<String> getSubCategories(String alokasiName) {
    final alokasi = getAlokasiByName(alokasiName);
    return alokasi?.subKategori ?? [];
  }

  // Get color for alokasi
  Color getColorForAlokasi(String alokasiName) {
    final alokasi = getAlokasiByName(alokasiName);
    if (alokasi == null) return Colors.grey;

    switch (alokasi.color.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get icon for alokasi
  IconData getIconForAlokasi(String alokasiName) {
    final alokasi = getAlokasiByName(alokasiName);
    if (alokasi == null) return Icons.category;

    switch (alokasi.icon) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'favorite':
        return Icons.favorite;
      case 'people':
        return Icons.people;
      case 'house':
        return Icons.house;
      default:
        return Icons.category;
    }
  }

  
}
