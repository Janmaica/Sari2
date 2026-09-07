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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
