// screens/select_alokasi_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttermoney/services/cache_service.dart';
import 'package:fluttermoney/services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class SelectAlokasiScreen extends StatelessWidget {
  const SelectAlokasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cache = CacheService();

    final alokasiList = cache.alokasiList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alokasi'),
        centerTitle: true,
        actions: [
          // Tombol refresh untuk reload data dari Firestore
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await cache.refreshData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data alokasi telah diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh halaman
                if (context.mounted) {
                  Navigator.of(context).pop();
                  context.pushNamed('select-alokasi');
                }
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alokasiList.length,
        itemBuilder: (context, index) {
          final alokasi = alokasiList[index];
          final color = cache.getColorForAlokasi(alokasi.name);
          final icon = cache.getIconForAlokasi(alokasi.name);

          // Dapatkan jumlah pengeluaran untuk alokasi ini
          return FutureBuilder<double>(
            future: _getTotalForAlokasi(alokasi.name),
            builder: (context, totalSnapshot) {
              final total = totalSnapshot.data ?? 0;
              final budget = alokasi.budget;
              final remaining = budget - total;
              final isOverBudget = remaining < 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      
                        context.pushNamed(
                          'select-subcategory',
                          extra: alokasi,
                        );
                      
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.15),
                            color.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, size: 30, color: color),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alokasi.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${alokasi.subKategori.length} subkategori',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ],
                          ),

                          ...[
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Budget',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Rp ${_formatAmount(budget)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Terpakai',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Rp ${_formatAmount(total)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Sisa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Rp ${_formatAmount(remaining.abs())}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isOverBudget
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: total / budget,
                                backgroundColor: Colors.grey[200],
                                color: isOverBudget ? Colors.red : color,
                                minHeight: 8,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<double> _getTotalForAlokasi(String alokasiName) async {
    try {
      final firestoreService = FirestoreService();
      return await firestoreService.getMonthlyTotal(
        DateTime.now().year,
        DateTime.now().month,
        alokasi: alokasiName,
      );
    } catch (e) {
      print('Error getting total for $alokasiName: $e');
      return 0;
    }
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
