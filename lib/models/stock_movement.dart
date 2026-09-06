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
}
