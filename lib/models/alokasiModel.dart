// models/alokasi_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AlokasiModel {
  final String id;
  final double budget;
  final String color;
  final String icon;
  final String name;
  final List<String> subKategori;

  AlokasiModel({
    required this.id,
    required this.budget,
    required this.color,
    required this.icon,
    required this.name,
    required this.subKategori,
  });

  factory AlokasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlokasiModel(
      id: doc.id,
      budget: doc['budget'] as double,
      color: data['color'] as String,
      icon: data['icon'] as String,
      name: data['name'] as String,
      subKategori: List<String>.from(data['sub_kategories'] ?? []),
    );
  }
}


