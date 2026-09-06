enum SaleType { cash, utang }

class Sale {
  const Sale({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.saleType,
    required this.createdAt,
  });

  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final SaleType saleType;
  final DateTime createdAt;

  double get total => quantity * unitPrice;
}
