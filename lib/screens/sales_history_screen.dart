import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key, this.repository});

  final StoreRepository? repository;

  StoreRepository get _repository => repository ?? StoreRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales history')),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          if (_repository.sales.isEmpty) {
            return const Center(child: Text('No sales recorded yet.'));
          }

          final sales = _repository.sales.reversed.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: sales.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final sale = sales[index];
              final total = sale.quantity * sale.unitPrice;
              return Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F1EB),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF156B4B),
                    ),
                  ),
                  title: Text(sale.productName),
                  subtitle: Text(
                    '${sale.quantity} x P${sale.unitPrice.toStringAsFixed(2)} • ${sale.saleType.name.toUpperCase()}',
                  ),
                  trailing: Text(
                    'P${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF156B4B),
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
}
