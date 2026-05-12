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
  SettingsModel? _cachedSettings;
  bool _isLoading = false;
  DateTime? _lastLoadTime;
  final Duration _cacheDuration = Duration(minutes: 30); // Cache selama 30 menit

  // Getters untuk akses konstanta
  List<AlokasiModel> get alokasiList {
    if (_cachedAlokasiList == null) {
      throw Exception('Alokasi data not loaded yet. Call loadAllData() first.');
    }
    return _cachedAlokasiList!;
  }

  SettingsModel get settings {
    if (_cachedSettings == null) {
      throw Exception('Settings not loaded yet. Call loadAllData() first.');
    }
    return _cachedSettings!;
  }

  // Cek apakah cache masih valid
  bool get isCacheValid {
    if (_lastLoadTime == null) return false;
    return DateTime.now().difference(_lastLoadTime!) < _cacheDuration;
  }

  // Load semua data (panggil sekali di awal aplikasi)
  Future<void> loadAllData({bool forceRefresh = false}) async {
    // Jika sudah loading, tunggu
    if (_isLoading) return;
    
    // Jika cache masih valid dan tidak dipaksa refresh, skip
    if (!forceRefresh && isCacheValid && _cachedAlokasiList != null && _cachedSettings != null) {
      print('Using cached data');
      return;
    }

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
      
      // Load settings data
      final settingsSnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('status')
          .get();
      
      if (settingsSnapshot.exists) {
        _cachedSettings = SettingsModel.fromFirestore(settingsSnapshot);
      }
      
      _lastLoadTime = DateTime.now();
      print('Data loaded successfully. Alokasi count: ${_cachedAlokasiList?.length}, Settings: ${_cachedSettings != null}');
      
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
      default:
        return Icons.category;
    }
  }

  // Check if data is loaded
  bool get isDataLoaded => _cachedAlokasiList != null && _cachedSettings != null;
}