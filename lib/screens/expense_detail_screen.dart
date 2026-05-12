// screens/expense_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttermoney/constants/categories.dart';
import 'package:fluttermoney/models/expenses.dart';
import 'package:fluttermoney/services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String alokasi;
  final String subCategory;

  const ExpenseDetailScreen({
    super.key,
    required this.alokasi,
    required this.subCategory,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isFixedAmount = false;
  double? _fixedAmount;

  @override
  void initState() {
    super.initState();
    // Check if this is Bayar Kos with fixed amount
    if (widget.alokasi == 'Bayar Kos') {
      _isFixedAmount = true;
      _fixedAmount = HARGA_KOS;
      _amountController.text = HARGA_KOS.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
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
    final expense = Expense(
      date: _selectedDate,
      alokasi: widget.alokasi,
      subCategory: widget.subCategory,
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
    );

    print('asdfsd');

    await _firestoreService.addExpense(expense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Alokasi:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            widget.alokasi,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sub-Kategori:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            widget.subCategory,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Date Picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tanggal'),
                subtitle: Text(
                  _selectedDate.day.toString().padLeft(2, '0') +
                      '/' +
                      _selectedDate.month.toString().padLeft(2, '0') +
                      '/' +
                      _selectedDate.year.toString(),
                ),
                onTap: () => _selectDate(context),
              ),

              const Divider(),

              // Amount Field
              TextFormField(
                controller: _amountController,
                enabled: !_isFixedAmount,
                decoration: InputDecoration(
                  labelText: _isFixedAmount ? 'Amount (Fixed)' : 'Amount (Rp)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: const OutlineInputBorder(),
                  suffixText: 'IDR',
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

              // Description Field (Optional)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi tambahan (opsional)',
                  prefixIcon: const Icon(Icons.description),
                  border: const OutlineInputBorder(),
                  helperText:
                      'Contoh: Makan siang di kantin, Beli baju di mall, dll',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _saveExpense();
                    context.pop();
                    context.goNamed('home');
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
