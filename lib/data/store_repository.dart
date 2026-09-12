import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_database.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../models/sale.dart';
import '../models/stock_movement.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../models/expense.dart';

class StoreRepository extends ChangeNotifier {
  StoreRepository();

  static const _storageKey = 'sari2_store_state';

  static bool get _isFlutterTest =>
      Platform.environment['FLUTTER_TEST'] == 'true';

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
  final List<Purchase> _purchases = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Sale> get sales => List.unmodifiable(_sales);
  List<StockMovement> get stockMovements => List.unmodifiable(_stockMovements);
  List<Customer> get customers => List.unmodifiable(_customers);
  List<Debt> get debts => List.unmodifiable(_debts);
  List<Payment> get payments => List.unmodifiable(_payments);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Purchase> get purchases => List.unmodifiable(_purchases);
  double get outstandingUtang =>
      _customers.fold(0, (total, customer) => total + customer.balance);

  double get todaySalesTotal =>
      _sales.fold(0, (total, sale) => total + sale.total);

  double get totalSalesRevenue =>
      _sales.fold(0, (total, sale) => total + sale.total);

  double get totalCostOfGoodsSold {
    double totalCost = 0;
    for (final sale in _sales) {
      for (final product in _products) {
        if (product.id == sale.productId) {
          totalCost += product.capitalPrice * sale.quantity;
          break;
        }
      }
    }
    return totalCost;
  }

  double get grossProfit => totalSalesRevenue - totalCostOfGoodsSold;

  double get totalExpenses =>
      _expenses.fold(0, (total, expense) => total + expense.amount);

  double get cashSalesInflow => _sales.fold(
    0,
    (total, sale) =>
        sale.saleType == SaleType.cash ? total + sale.total : total,
  );

  double get utangSalesInflow => _sales.fold(
    0,
    (total, sale) =>
        sale.saleType == SaleType.utang ? total + sale.total : total,
  );

  double get netCashFlow => cashSalesInflow - totalExpenses;

  Map<String, dynamic> toBackupJson() => {
    'products': _products.map((product) => product.toJson()).toList(),
    'customers': _customers.map((customer) => customer.toJson()).toList(),
    'sales': _sales.map((sale) => sale.toJson()).toList(),
    'stockMovements': _stockMovements
        .map((movement) => movement.toJson())
        .toList(),
    'debts': _debts.map((debt) => debt.toJson()).toList(),
    'payments': _payments.map((payment) => payment.toJson()).toList(),
    'expenses': _expenses.map((expense) => expense.toJson()).toList(),
    'purchases': _purchases.map((purchase) => purchase.toJson()).toList(),
  };

  String exportBackup() => jsonEncode(toBackupJson());

  String? restoreBackup(String backup) {
    if (backup.trim().isEmpty) return 'Backup is empty';

    try {
      final decoded = jsonDecode(backup) as Map<String, dynamic>;
      _products
        ..clear()
        ..addAll(
          (decoded['products'] as List? ?? const [])
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      _customers
        ..clear()
        ..addAll(
          (decoded['customers'] as List? ?? const [])
              .map((item) => Customer.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      _sales
        ..clear()
        ..addAll(
          (decoded['sales'] as List? ?? const [])
              .map((item) => Sale.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      _stockMovements
        ..clear()
        ..addAll(
          (decoded['stockMovements'] as List? ?? const [])
              .map(
                (item) => StockMovement.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        );
      _debts
        ..clear()
        ..addAll(
          (decoded['debts'] as List? ?? const [])
              .map((item) => Debt.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      _payments
        ..clear()
        ..addAll(
          (decoded['payments'] as List? ?? const [])
              .map((item) => Payment.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      _expenses
        ..clear()
        ..addAll(
          (decoded['expenses'] as List? ?? const [])
              .map((item) => Expense.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      _purchases
        ..clear()
        ..addAll(
          (decoded['purchases'] as List? ?? const [])
              .map((item) => Purchase.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
    } catch (_) {
      return 'Backup is not valid JSON data';
    }

    notifyListeners();
    unawaited(saveToDisk());
    return null;
  }

  static Future<StoreRepository> loadFromDisk() async {
    final repository = StoreRepository();
    Map<String, dynamic>? decoded;

    final databaseSnapshot = _isFlutterTest
        ? null
        : await LocalDatabase.instance.readSnapshot();
    if (databaseSnapshot != null) {
      decoded = databaseSnapshot;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return repository;
      }

      try {
        decoded = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return repository;
      }
    }

    try {
      repository._products.clear();
      repository._customers.clear();
      repository._sales.clear();
      repository._stockMovements.clear();
      repository._debts.clear();
      repository._payments.clear();
      repository._expenses.clear();
      repository._purchases.clear();

      final productList = (decoded['products'] as List? ?? const [])
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
      final customerList = (decoded['customers'] as List? ?? const [])
          .map((item) => Customer.fromJson(item as Map<String, dynamic>))
          .toList();
      final saleList = (decoded['sales'] as List? ?? const [])
          .map((item) => Sale.fromJson(item as Map<String, dynamic>))
          .toList();
      final stockMovementList = (decoded['stockMovements'] as List? ?? const [])
          .map((item) => StockMovement.fromJson(item as Map<String, dynamic>))
          .toList();
      final debtList = (decoded['debts'] as List? ?? const [])
          .map((item) => Debt.fromJson(item as Map<String, dynamic>))
          .toList();
      final paymentList = (decoded['payments'] as List? ?? const [])
          .map((item) => Payment.fromJson(item as Map<String, dynamic>))
          .toList();
      final expenseList = (decoded['expenses'] as List? ?? const [])
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList();
      final purchaseList = (decoded['purchases'] as List? ?? const [])
          .map((item) => Purchase.fromJson(item as Map<String, dynamic>))
          .toList();

      repository._products.addAll(productList);
      repository._customers.addAll(customerList);
      repository._sales.addAll(saleList);
      repository._stockMovements.addAll(stockMovementList);
      repository._debts.addAll(debtList);
      repository._payments.addAll(paymentList);
      repository._expenses.addAll(expenseList);
      repository._purchases.addAll(purchaseList);
    } catch (_) {
      return repository;
    }

    if (databaseSnapshot == null) {
      await repository.saveToDisk();
    }
    repository.notifyListeners();
    return repository;
  }

  Future<void> saveToDisk() async {
    if (_isFlutterTest) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(toBackupJson()));
      return;
    }
    await LocalDatabase.instance.writeSnapshot(toBackupJson());
  }

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
    String category = 'Groceries',
  }) {
    _products.add(
      Product(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        capitalPrice: capitalPrice,
        sellingPrice: sellingPrice,
        stock: stock,
        lowStockThreshold: lowStockThreshold,
        category: category,
      ),
    );
    notifyListeners();
    unawaited(saveToDisk());
  }

  void updateProduct({
    required Product product,
    String? name,
    double? capitalPrice,
    double? sellingPrice,
    int? stock,
    int? lowStockThreshold,
    String? category,
  }) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) return;

    _products[index] = product.copyWith(
      name: name,
      capitalPrice: capitalPrice,
      sellingPrice: sellingPrice,
      stock: stock,
      lowStockThreshold: lowStockThreshold,
      category: category,
    );
    notifyListeners();
    unawaited(saveToDisk());
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
    unawaited(saveToDisk());
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
    unawaited(saveToDisk());
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
    unawaited(saveToDisk());
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
    unawaited(saveToDisk());
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
    unawaited(saveToDisk());
    return null;
  }

  String? addPurchase({
    Product? product,
    required String supplierName,
    required int quantity,
    required double unitCost,
  }) {
    if (supplierName.trim().isEmpty) {
      return 'Supplier name is required';
    }
    if (quantity <= 0) return 'Quantity must be greater than zero';
    if (unitCost < 0) return 'Unit cost cannot be negative';

    final selectedProduct = product ?? _products.first;
    final purchase = Purchase(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      supplierName: supplierName.trim(),
      productId: selectedProduct.id,
      productName: selectedProduct.name,
      quantity: quantity,
      unitCost: unitCost,
      totalCost: unitCost * quantity,
      createdAt: DateTime.now(),
    );
    _purchases.add(purchase);

    final stockError = adjustStock(
      product: selectedProduct,
      quantity: quantity,
      type: StockMovementType.stockIn,
      reason: 'Supplier: ${supplierName.trim()}',
    );
    if (stockError != null) {
      _purchases.removeLast();
      return stockError;
    }
    notifyListeners();
    unawaited(saveToDisk());
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
    unawaited(saveToDisk());
    return null;
  }
}
