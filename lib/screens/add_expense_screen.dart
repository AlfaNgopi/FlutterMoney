// screens/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttermoney/models/expenses.dart';
import 'package:fluttermoney/services/firebase_service.dart';
import 'package:intl/intl.dart';
import '../constants/categories.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String? selectedAlokasi;
  String? selectedSubCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                      ),
                      onTap: () => _selectDate(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Step 1: Select Alokasi
                  const Text(
                    '1. Pilih Alokasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ALOKASI.map((alokasi) {
                      return FilterChip(
                        label: Text(alokasi),
                        selected: selectedAlokasi == alokasi,
                        onSelected: (selected) {
                          setState(() {
                            selectedAlokasi = selected ? alokasi : null;
                            selectedSubCategory = null;
                          });
                        },
                        selectedColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Step 2: Select SubCategory
                  if (selectedAlokasi != null &&
                      selectedAlokasi != 'Bayar Kos') ...[
                    const Text(
                      '2. Pilih Sub-Kategori',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SUB_CATEGORIES[selectedAlokasi]!.map((subCat) {
                        return ChoiceChip(
                          label: Text(subCat),
                          selected: selectedSubCategory == subCat,
                          onSelected: (selected) {
                            setState(() {
                              selectedSubCategory = selected ? subCat : null;
                            });
                          },
                          selectedColor: Colors.green.shade100,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Special case for Bayar Kos
                  if (selectedAlokasi == 'Bayar Kos') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bayar Kos - Fixed Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Amount: Rp ${NumberFormat('#,###').format(HARGA_KOS)}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Auto-set subcategory
                  ],

                  // Step 3: Amount & Description
                  if ((selectedSubCategory != null &&
                          selectedAlokasi != 'Bayar Kos') ||
                      selectedAlokasi == 'Bayar Kos') ...[
                    const Text(
                      '3. Detail Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount field (not for Bayar Kos)
                    if (selectedAlokasi != 'Bayar Kos')
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (Rp)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Contoh: Makan siang, Beli baju, dll',
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _saveExpense,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Simpan Transaksi2',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    try {
      setState(() => _isLoading = true);

      print('saving expense');

      double amount;
      if (selectedAlokasi == 'Bayar Kos') {
        amount = HARGA_KOS;
      } else {
        if (_amountController.text.isEmpty) {
          _showSnackBar('Masukkan amount', Colors.red);
          return;
        }
        amount = double.parse(_amountController.text);
      }

      final expense = Expense(
        date: _selectedDate,
        alokasi: selectedAlokasi!,
        subCategory: selectedAlokasi == 'Bayar Kos'
            ? 'Sewa Bulanan'
            : selectedSubCategory!,
        description: _descriptionController.text.isEmpty
            ? '-'
            : _descriptionController.text,
        amount: amount,
      );

      await _firestoreService.addExpense(expense);

      _showSnackBar('Transaksi berhasil disimpan!', Colors.green);

      // Clear form and go back
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
