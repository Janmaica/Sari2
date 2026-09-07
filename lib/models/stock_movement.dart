import 'product.dart';

enum StockMovementType { stockIn, sale, damaged, lost, expired, adjustment }

class StockMovement {
  const StockMovement({
    required this.product,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.createdAt,
  });

  final Product product;
  final StockMovementType type;
  final int quantity;
  final String reason;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'type': type.name,
    'quantity': quantity,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    type: StockMovementType.values.firstWhere(
      (type) => type.name == json['type'],
      orElse: () => StockMovementType.adjustment,
    ),
    quantity: json['quantity'] as int,
    reason: json['reason'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
