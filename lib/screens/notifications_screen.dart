import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.repository});

  final StoreRepository? repository;

  StoreRepository get _repository => repository ?? StoreRepository.instance;

  @override
  Widget build(BuildContext context) {
    final alerts = <String>[];

    for (final product in _repository.products) {
      if (product.isOutOfStock) {
        alerts.add('${product.name} is out of stock.');
      }
    }

    for (final customer in _repository.customers) {
      if (customer.balance > 0) {
        alerts.add(
          '${customer.name} owes P${customer.balance.toStringAsFixed(2)}.',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts right now.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: alerts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                child: ListTile(
                  leading: Icon(
                    alert.contains('out of stock')
                        ? Icons.remove_shopping_cart_outlined
                        : Icons.account_balance_wallet_outlined,
                    color: alert.contains('out of stock')
                        ? const Color(0xFFB3261E)
                        : const Color(0xFF156B4B),
                  ),
                  title: Text(alert),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
