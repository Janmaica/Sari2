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

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'saleType': saleType.name,
    'createdAt': createdAt.toIso8601String(),
    'customerId': customerId,
  };

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    unitPrice: (json['unitPrice'] as num).toDouble(),
    saleType: SaleType.values.firstWhere(
      (type) => type.name == json['saleType'],
      orElse: () => SaleType.cash,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    customerId: json['customerId'] as String?,
  );
}
