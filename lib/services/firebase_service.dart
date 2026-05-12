// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttermoney/models/expenses.dart';
import 'cache_service.dart';

class FirestoreService {
  final CollectionReference _expensesCollection = FirebaseFirestore.instance
      .collection('expenses');
  final CacheService _cache = CacheService();

  // Create - Add new expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _expensesCollection.add(expense.toJson());
      print('Expense added successfully');
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  // Read - Get all expenses
  Stream<QuerySnapshot> getExpenses() {
    return _expensesCollection.orderBy('date', descending: true).snapshots();
  }

  // Read - Get expenses by date range
  Stream<QuerySnapshot> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expensesCollection
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Read - Get expenses by category
  Stream<QuerySnapshot> getExpensesByCategory(String alokasi) {
    return _expensesCollection
        .where('alokasi', isEqualTo: alokasi)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Update - Edit expense
  Future<void> updateExpense(String docId, Expense expense) async {
    try {
      await _expensesCollection.doc(docId).update(expense.toJson());
      print('Expense updated successfully');
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  // Delete - Remove expense
  Future<void> deleteExpense(String docId) async {
    try {
      await _expensesCollection.doc(docId).delete();
      print('Expense deleted successfully');
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // Get total by category
  Future<double> getTotalByCategory(String alokasi) async {
    final snapshot = await _expensesCollection
        .where('alokasi', isEqualTo: alokasi)
        .get();

    return snapshot.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc['amount'] as double),
    );
  }

  // Get monthly total with optional alokasi filter
  Future<double> getMonthlyTotal(int year, int month, {String? alokasi}) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);

    Query query = _expensesCollection
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String());

    // Add alokasi filter if provided
    if (alokasi != null) {
      query = query.where('alokasi', isEqualTo: alokasi);
    }

    final snapshot = await query.get();

    return snapshot.docs.fold<double>(
      0,
      (sum, doc) => sum + ((doc['amount'] as num).toDouble()),
    );
  }

  
  
}
