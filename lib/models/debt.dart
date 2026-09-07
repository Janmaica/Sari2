class Debt {
  const Debt({
    required this.customerId,
    required this.amount,
    required this.remainingAmount,
    required this.createdAt,
  });

  final String customerId;
  final double amount;
  final double remainingAmount;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'amount': amount,
    'remainingAmount': remainingAmount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
    customerId: json['customerId'] as String,
    amount: (json['amount'] as num).toDouble(),
    remainingAmount: (json['remainingAmount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class Payment {
  const Payment({
    required this.customerId,
    required this.amount,
    required this.createdAt,
  });

  final String customerId;
  final double amount;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    customerId: json['customerId'] as String,
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
