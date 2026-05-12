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
    
    // Pastikan data sudah dimuat
    if (!cache.isDataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pilih Alokasi'),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              final budget = _getBudgetForAlokasi(alokasi.name, cache);
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
                      // Navigate to next step based on selection
                      if (alokasi.name == 'Bayar Kos') {
                        // Auto-select subcategory and go to detail
                        context.pushNamed(
                          'expense-detail',
                          extra: {
                            'alokasi': alokasi.name,
                            'subCategory': alokasi.subKategori.isNotEmpty 
                                ? alokasi.subKategori[0] 
                                : 'Sewa Bulanan',
                            'suggestedAmount': cache.settings.hargaKos,
                          },
                        );
                      } else {
                        context.pushNamed(
                          'select-subcategory',
                          extra: alokasi.name,
                        );
                      }
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
                                child: Icon(
                                  icon,
                                  size: 30,
                                  color: color,
                                ),
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
                          
                          // Budget info for non-Kos categories
                          if (alokasi.name != 'Bayar Kos') ...[
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
                                        color: isOverBudget ? Colors.red : Colors.green,
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
                          ] else ...[
                            // Bayar Kos specific info
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Harga Kos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Rp ${_formatAmount(cache.settings.hargaKos)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            if (total > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sudah dibayar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatAmount(total)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              if (total >= cache.settings.hargaKos)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                                        SizedBox(width: 8),
                                        Text(
                                          'Kos sudah lunas bulan ini',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ],
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

  double _getBudgetForAlokasi(String alokasiName, CacheService cache) {
    switch (alokasiName) {
      case 'Kebutuhan':
        return cache.settings.alokasiKebutuhan;
      case 'Sosial':
        return cache.settings.alokasiSosial;
      case 'Keinginan':
        return cache.settings.alokasiKeinginan;
      case 'Bayar Kos':
        return cache.settings.hargaKos;
      default:
        return 0;
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}