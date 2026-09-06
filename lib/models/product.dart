class Product {
  const Product({
    required this.id,
    required this.name,
    required this.defaultPrice,
    required this.stock,
  });

  final String id;
  final String name;
  final double defaultPrice;
  final int stock;
}
