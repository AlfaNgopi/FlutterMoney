// models/expense.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String? id; // Firestore document ID
  final DateTime date;
  final String alokasi;
  final String subCategory;
  final String description;
  final double amount;

  Expense({
    this.id,
    required this.date,
    required this.alokasi,
    required this.subCategory,
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'alokasi': alokasi,
    'subCategory': subCategory,
    'description': description,
    'amount': amount,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Expense.fromJson(Map<String, dynamic> json, String docId) {
    return Expense(
      id: docId,
      date: DateTime.parse(json['date']),
      alokasi: json['alokasi'],
      subCategory: json['subCategory'],
      description: json['description'] ?? '',
      amount: json['amount'].toDouble(),
    );
  }
}