import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/sale.dart';

class StoreRepository extends ChangeNotifier {
  StoreRepository();

  static final instance = StoreRepository();

  final List<Product> _products = [
    const Product(
      id: 'rice-1kg',
      name: 'Rice (1 kg)',
      capitalPrice: 50,
      sellingPrice: 55,
      stock: 18,
      lowStockThreshold: 5,
    ),
    const Product(
      id: 'sardines-155g',
      name: 'Sardines (155 g)',
      capitalPrice: 24,
      sellingPrice: 28,
      stock: 8,
      lowStockThreshold: 3,
    ),
    const Product(
      id: 'instant-noodles',
      name: 'Instant noodles',
      capitalPrice: 12,
      sellingPrice: 15.5,
      stock: 4,
      lowStockThreshold: 5,
    ),
  ];

  final List<Sale> _sales = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Sale> get sales => List.unmodifiable(_sales);

  double get todaySalesTotal =>
      _sales.fold(0, (total, sale) => total + sale.total);

  int get lowStockCount =>
      _products.where((product) => product.isLowStock).length;

  int get outOfStockCount =>
      _products.where((product) => product.isOutOfStock).length;

  void addProduct({
    required String name,
    required double capitalPrice,
    required double sellingPrice,
    required int stock,
    required int lowStockThreshold,
  }) {
    _products.add(
      Product(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        capitalPrice: capitalPrice,
        sellingPrice: sellingPrice,
        stock: stock,
        lowStockThreshold: lowStockThreshold,
      ),
    );
    notifyListeners();
  }

  void recordSale({
    required Product product,
    required double quantity,
    required double unitPrice,
    required SaleType saleType,
  }) {
    recordTransaction(
      items: [
        SaleDraft(product: product, quantity: quantity, unitPrice: unitPrice),
      ],
      saleType: saleType,
    );
  }

  String? validateTransaction(List<SaleDraft> items) {
    for (final item in items) {
      if (item.quantity > item.product.stock) {
        return '${item.product.name} has only ${item.product.stock} in stock';
      }
    }
    return null;
  }

  String? recordTransaction({
    required List<SaleDraft> items,
    required SaleType saleType,
  }) {
    final error = validateTransaction(items);
    if (error != null) return error;

    final now = DateTime.now();
    for (final item in items) {
      final index = _products.indexWhere(
        (product) => product.id == item.product.id,
      );
      _products[index] = item.product.copyWith(
        stock: item.product.stock - item.quantity.toInt(),
      );
      _sales.add(
        Sale(
          productId: item.product.id,
          productName: item.product.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          saleType: saleType,
          createdAt: now,
        ),
      );
    }
    notifyListeners();
    return null;
  }
}
