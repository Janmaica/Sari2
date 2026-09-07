class Product {
  const Product({
    required this.id,
    required this.name,
    required this.capitalPrice,
    required this.sellingPrice,
    required this.stock,
    required this.lowStockThreshold,
  });

  final String id;
  final String name;
  final double capitalPrice;
  final double sellingPrice;
  final int stock;
  final int lowStockThreshold;

  bool get isOutOfStock => stock == 0;
  bool get isLowStock => stock > 0 && stock <= lowStockThreshold;

  Product copyWith({int? stock}) {
    return Product(
      id: id,
      name: name,
      capitalPrice: capitalPrice,
      sellingPrice: sellingPrice,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'capitalPrice': capitalPrice,
    'sellingPrice': sellingPrice,
    'stock': stock,
    'lowStockThreshold': lowStockThreshold,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    capitalPrice: (json['capitalPrice'] as num).toDouble(),
    sellingPrice: (json['sellingPrice'] as num).toDouble(),
    stock: json['stock'] as int,
    lowStockThreshold: json['lowStockThreshold'] as int,
  );
}
