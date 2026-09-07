import 'product.dart';

enum SaleType { cash, utang }

class SaleDraft {
  const SaleDraft({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  final Product product;
  final double quantity;
  final double unitPrice;
}

class Sale {
  const Sale({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.saleType,
    required this.createdAt,
    this.customerId,
  });

  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final SaleType saleType;
  final DateTime createdAt;
  final String? customerId;

  double get total => quantity * unitPrice;
}
