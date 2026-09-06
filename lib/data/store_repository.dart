import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/sale.dart';

class StoreRepository extends ChangeNotifier {
  StoreRepository._();

  static final instance = StoreRepository._();

  final List<Product> _products = [
    const Product(
      id: 'rice-1kg',
      name: 'Rice (1 kg)',
      defaultPrice: 55,
      stock: 18,
    ),
    const Product(
      id: 'sardines-155g',
      name: 'Sardines (155 g)',
      defaultPrice: 28,
      stock: 8,
    ),
    const Product(
      id: 'instant-noodles',
      name: 'Instant noodles',
      defaultPrice: 15.5,
      stock: 4,
    ),
  ];

  final List<Sale> _sales = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Sale> get sales => List.unmodifiable(_sales);

  double get todaySalesTotal =>
      _sales.fold(0, (total, sale) => total + sale.total);

  int get lowStockCount =>
      _products.where((product) => product.stock <= 5).length;

  void recordSale({
    required Product product,
    required double quantity,
    required double unitPrice,
    required SaleType saleType,
  }) {
    _sales.add(
      Sale(
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: unitPrice,
        saleType: saleType,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
