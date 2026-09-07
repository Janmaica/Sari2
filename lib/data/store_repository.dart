import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/sale.dart';
import '../models/stock_movement.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../models/expense.dart';

class StoreRepository extends ChangeNotifier {
  StoreRepository();

  static final instance = StoreRepository();

  final List<Product> _products = [
    const Product(
      id: 'rice-1kg',
      name: 'Rice (1 kg)',
      capitalPrice: 50,
      sellingPrice: 55,
      stock: 18,
      lowStockThreshold: 5,
    ),
    const Product(
      id: 'sardines-155g',
      name: 'Sardines (155 g)',
      capitalPrice: 24,
      sellingPrice: 28,
      stock: 8,
      lowStockThreshold: 3,
    ),
    const Product(
      id: 'instant-noodles',
      name: 'Instant noodles',
      capitalPrice: 12,
      sellingPrice: 15.5,
      stock: 4,
      lowStockThreshold: 5,
    ),
  ];

  final List<Sale> _sales = [];
  final List<StockMovement> _stockMovements = [];
  final List<Customer> _customers = [];
  final List<Debt> _debts = [];
  final List<Payment> _payments = [];
  final List<Expense> _expenses = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Sale> get sales => List.unmodifiable(_sales);
  List<StockMovement> get stockMovements => List.unmodifiable(_stockMovements);
  List<Customer> get customers => List.unmodifiable(_customers);
  List<Debt> get debts => List.unmodifiable(_debts);
  List<Payment> get payments => List.unmodifiable(_payments);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  double get outstandingUtang =>
      _customers.fold(0, (total, customer) => total + customer.balance);

  double get todaySalesTotal =>
      _sales.fold(0, (total, sale) => total + sale.total);

  double get totalExpenses =>
      _expenses.fold(0, (total, expense) => total + expense.amount);

  int get lowStockCount =>
      _products.where((product) => product.isLowStock).length;

  int get outOfStockCount =>
      _products.where((product) => product.isOutOfStock).length;

  void addProduct({
    required String name,
    required double capitalPrice,
    required double sellingPrice,
    required int stock,
    required int lowStockThreshold,
  }) {
    _products.add(
      Product(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        capitalPrice: capitalPrice,
        sellingPrice: sellingPrice,
        stock: stock,
        lowStockThreshold: lowStockThreshold,
      ),
    );
    notifyListeners();
  }

  void recordSale({
    required Product product,
    required double quantity,
    required double unitPrice,
    required SaleType saleType,
    Customer? customer,
  }) {
    recordTransaction(
      items: [
        SaleDraft(product: product, quantity: quantity, unitPrice: unitPrice),
      ],
      saleType: saleType,
      customer: customer,
    );
  }

  String? validateTransaction(List<SaleDraft> items) {
    for (final item in items) {
      if (item.quantity > item.product.stock) {
        return '${item.product.name} has only ${item.product.stock} in stock';
      }
    }
    return null;
  }

  String? recordTransaction({
    required List<SaleDraft> items,
    required SaleType saleType,
    Customer? customer,
  }) {
    final error = validateTransaction(items);
    if (error != null) return error;

    if (saleType == SaleType.utang && customer == null) {
      return 'Select a customer for this utang sale';
    }

    final remainingStock = <String, int>{
      for (final product in _products) product.id: product.stock,
    };
    for (final item in items) {
      final remaining = remainingStock[item.product.id] ?? 0;
      if (item.quantity > remaining) {
        return '${item.product.name} has only $remaining in stock';
      }
      remainingStock[item.product.id] = remaining - item.quantity.toInt();
    }

    final now = DateTime.now();
    final totalDebtAmount = saleType == SaleType.utang
        ? items.fold<double>(
            0,
            (sum, item) => sum + (item.quantity * item.unitPrice).toDouble(),
          )
        : 0.0;

    if (saleType == SaleType.utang && customer != null) {
      final customerIndex = _customers.indexWhere(
        (item) => item.id == customer.id,
      );
      if (customerIndex != -1) {
        final updatedCustomer = _customers[customerIndex].copyWith(
          balance: _customers[customerIndex].balance + totalDebtAmount,
        );
        _customers[customerIndex] = updatedCustomer;
        _debts.add(
          Debt(
            customerId: customer.id,
            amount: totalDebtAmount,
            remainingAmount: totalDebtAmount,
            createdAt: now,
          ),
        );
      }
    }

    for (final item in items) {
      final index = _products.indexWhere(
        (product) => product.id == item.product.id,
      );
      _products[index] = item.product.copyWith(
        stock: remainingStock[item.product.id],
      );
      _sales.add(
        Sale(
          productId: item.product.id,
          productName: item.product.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          saleType: saleType,
          createdAt: now,
          customerId: customer?.id,
        ),
      );
      _stockMovements.add(
        StockMovement(
          product: _products[index],
          type: StockMovementType.sale,
          quantity: item.quantity.toInt(),
          reason: 'Sale',
          createdAt: now,
        ),
      );
    }
    notifyListeners();
    return null;
  }

  String? adjustStock({
    required Product product,
    required int quantity,
    required StockMovementType type,
    required String reason,
  }) {
    if (quantity <= 0) return 'Quantity must be greater than zero';
    final index = _products.indexWhere((item) => item.id == product.id);
    final newStock = type == StockMovementType.stockIn
        ? product.stock + quantity
        : product.stock - quantity;
    if (newStock < 0) {
      return '${product.name} has only ${product.stock} in stock';
    }
    _products[index] = product.copyWith(stock: newStock);
    _stockMovements.add(
      StockMovement(
        product: _products[index],
        type: type,
        quantity: quantity,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  Customer addCustomer({
    required String name,
    String contact = '',
    String notes = '',
  }) {
    final customer = Customer(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      contact: contact,
      notes: notes,
    );
    _customers.add(customer);
    notifyListeners();
    return customer;
  }

  String? addDebt({required Customer customer, required double amount}) {
    if (amount <= 0) return 'Debt amount must be greater than zero';
    final index = _customers.indexWhere((item) => item.id == customer.id);
    final updatedCustomer = customer.copyWith(
      balance: customer.balance + amount,
    );
    _customers[index] = updatedCustomer;
    _debts.add(
      Debt(
        customerId: customer.id,
        amount: amount,
        remainingAmount: amount,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  String? addExpense({
    required String name,
    required double amount,
    required String category,
  }) {
    if (name.trim().isEmpty) return 'Expense name is required';
    if (amount <= 0) return 'Expense amount must be greater than zero';

    _expenses.add(
      Expense(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        amount: amount,
        category: category.trim().isEmpty ? 'General' : category.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  String? recordPayment({required Customer customer, required double amount}) {
    if (amount <= 0) return 'Payment must be greater than zero';
    if (amount > customer.balance) {
      return 'Payment cannot be greater than the remaining balance';
    }
    final index = _customers.indexWhere((item) => item.id == customer.id);
    _customers[index] = customer.copyWith(balance: customer.balance - amount);
    _payments.add(
      Payment(
        customerId: customer.id,
        amount: amount,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }
}
