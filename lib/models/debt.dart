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
}
