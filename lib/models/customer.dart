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

  Customer copyWith({double? balance}) {
    return Customer(
      id: id,
      name: name,
      contact: contact,
      notes: notes,
      balance: balance ?? this.balance,
    );
  }
}
