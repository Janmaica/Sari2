class Purchase {
  const Purchase({
    required this.id,
    required this.supplierName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.createdAt,
  });

  final String id;
  final String supplierName;
  final String productId;
  final String productName;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'supplierName': supplierName,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'unitCost': unitCost,
    'totalCost': totalCost,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
    id: json['id'] as String,
    supplierName: json['supplierName'] as String,
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    quantity: json['quantity'] as int,
    unitCost: (json['unitCost'] as num).toDouble(),
    totalCost: (json['totalCost'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
