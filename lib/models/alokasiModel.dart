// models/alokasi_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AlokasiModel {
  final String id;
  final String color;
  final String icon;
  final String name;
  final List<String> subKategori;

  AlokasiModel({
    required this.id,
    required this.color,
    required this.icon,
    required this.name,
    required this.subKategori,
  });

  factory AlokasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlokasiModel(
      id: doc.id,
      color: data['color'] as String,
      icon: data['icon'] as String,
      name: data['name'] as String,
      subKategori: List<String>.from(data['sub_kategories'] ?? []),
    );
  }
}

// models/settings_model.dart
class SettingsModel {
  final double alokasiKebutuhan;
  final double alokasiKeinginan;
  final double alokasiSosial;
  final double gajiBulanan;
  final double hargaKos;

  SettingsModel({
    required this.alokasiKebutuhan,
    required this.alokasiKeinginan,
    required this.alokasiSosial,
    required this.gajiBulanan,
    required this.hargaKos,
  });

  factory SettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SettingsModel(
      alokasiKebutuhan: (data['alokasiKebutuhan'] as num).toDouble(),
      alokasiKeinginan: (data['alokasiKeinginan'] as num).toDouble(),
      alokasiSosial: (data['alokasiSosial'] as num).toDouble(),
      gajiBulanan: (data['gajiBulanan'] as num).toDouble(),
      hargaKos: (data['hargaKos'] as num).toDouble(),
    );
  }
}