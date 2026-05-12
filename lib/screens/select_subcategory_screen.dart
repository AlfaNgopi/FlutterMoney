// screens/select_subcategory_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttermoney/models/alokasiModel.dart';
import 'package:go_router/go_router.dart';

class SelectSubCategoryScreen extends StatelessWidget {
  final AlokasiModel alokasi;

  const SelectSubCategoryScreen({super.key, required this.alokasi});

  @override
  Widget build(BuildContext context) {
    final subCategories = alokasi.subKategori;

    return Scaffold(
      appBar: AppBar(title: Text('Detail $alokasi'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = subCategories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              child: InkWell(
                onTap: () {
                  context.pushNamed(
                    'expense-detail',
                    extra: {'alokasi': alokasi, 'subCategory': subCategory},
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Row(
                    children: [
                      Icon(_getIconForSubCategory(subCategory), size: 28),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          subCategory,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 20),
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

  IconData _getIconForSubCategory(String subCategory) {
    switch (subCategory) {
      case 'Makan':
      case 'Makan (Enak)':
        return Icons.restaurant;
      case 'Laundry':
        return Icons.local_laundry_service;
      case 'Bensin':
        return Icons.local_gas_station;
      case 'Barang':
        return Icons.shopping_bag;
      case 'Keluar':
        return Icons.nightlife;
      case 'Sewa Bulanan':
        return Icons.home_work;
      default:
        return Icons.arrow_right;
    }
  }
}
