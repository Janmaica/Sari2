class Expense {
  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime createdAt;
}
