class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.contact = '',
    this.notes = '',
    this.balance = 0,
  });

  final String id;
  final String name;
  final String contact;
  final String notes;
  final double balance;

  Customer copyWith({
    String? name,
    String? contact,
    String? notes,
    double? balance,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      notes: notes ?? this.notes,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'contact': contact,
    'notes': notes,
    'balance': balance,
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as String,
    name: json['name'] as String,
    contact: (json['contact'] ?? '') as String,
    notes: (json['notes'] ?? '') as String,
    balance: (json['balance'] as num? ?? 0).toDouble(),
  );
}
