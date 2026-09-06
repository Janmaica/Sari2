import 'package:flutter/material.dart';

import '../data/store_repository.dart';
import '../models/stock_movement.dart';

class StockHistoryScreen extends StatelessWidget {
  const StockHistoryScreen({super.key, this.repository});

  final StoreRepository? repository;

  StoreRepository get _repository => repository ?? StoreRepository.instance;

  String _typeLabel(StockMovementType type) {
    switch (type) {
      case StockMovementType.stockIn:
        return 'Stock in';
      case StockMovementType.sale:
        return 'Sale';
      case StockMovementType.damaged:
        return 'Damaged';
      case StockMovementType.lost:
        return 'Lost';
      case StockMovementType.expired:
        return 'Expired';
      case StockMovementType.adjustment:
        return 'Adjustment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock history')),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          if (_repository.stockMovements.isEmpty) {
            return const Center(child: Text('No stock movements yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _repository.stockMovements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final movement = _repository.stockMovements.reversed.elementAt(
                index,
              );
              final isAddition = movement.type == StockMovementType.stockIn;
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Icon(
                  isAddition
                      ? Icons.add_circle_outline
                      : Icons.remove_circle_outline,
                  color: isAddition
                      ? const Color(0xFF156B4B)
                      : const Color(0xFFC46A16),
                ),
                title: Text(
                  movement.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${_typeLabel(movement.type)}: ${movement.reason}',
                ),
                trailing: Text(
                  '${isAddition ? '+' : '-'}${movement.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isAddition
                        ? const Color(0xFF156B4B)
                        : const Color(0xFFC46A16),
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
