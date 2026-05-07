// screens/select_alokasi_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttermoney/constants/categories.dart';
import 'package:go_router/go_router.dart';

class SelectAlokasiScreen extends StatelessWidget {
  const SelectAlokasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alokasi'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ALOKASI.length,
        itemBuilder: (context, index) {
          final alokasi = ALOKASI[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              child: InkWell(
                onTap: () {
                  // Navigate to next step based on selection
                  if (alokasi == 'Bayar Kos') {
                    // Auto-select subcategory and go to detail
                    context.pushNamed(
                      'expense-detail',
                      extra: {
                        'alokasi': alokasi,
                        'subCategory': 'Sewa Bulanan',
                      },
                    );
                  } else {
                    context.pushNamed(
                      'select-subcategory',
                      extra: alokasi,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForAlokasi(alokasi),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alokasi,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (alokasi == 'Bayar Kos')
                              Text(
                                'Fixed: Rp${HARGA_KOS.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForAlokasi(String alokasi) {
    switch (alokasi) {
      case 'Kebutuhan':
        return Icons.shopping_cart;
      case 'Sosial':
        return Icons.people;
      case 'Keinginan':
        return Icons.favorite;
      case 'Bayar Kos':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}