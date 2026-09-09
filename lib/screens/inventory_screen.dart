import 'package:flutter/material.dart';

import '../data/store_repository.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';
import 'stock_history_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, this.repository});

  final StoreRepository? repository;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  static const _categories = [
    'All',
    'Groceries',
    'Beverages',
    'School supplies',
    'Snacks',
    'Household',
    'Hygiene',
  ];

  String _selectedCategory = 'All';

  StoreRepository get _repository =>
      widget.repository ?? StoreRepository.instance;

  void _showAddProductForm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddProductSheet(repository: _repository),
    );
  }

  void _showEditProductForm(BuildContext context, Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _AddProductSheet(repository: _repository, product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            tooltip: 'Stock history',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StockHistoryScreen(repository: _repository),
              ),
            ),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'Add product',
            onPressed: () => _showAddProductForm(context),
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          final products = _selectedCategory == 'All'
              ? _repository.products
              : _repository.products
                    .where((product) => product.category == _selectedCategory)
                    .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF17372D),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
              if (products.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No products in $_selectedCategory.'),
                  ),
                )
              else
                ...products.map((product) {
                  return Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: product.isOutOfStock
                            ? const Color(0xFFFCE8E6)
                            : product.isLowStock
                            ? const Color(0xFFFFF1D6)
                            : const Color(0xFFE8F1EB),
                        child: Icon(
                          product.isOutOfStock
                              ? Icons.remove_shopping_cart_outlined
                              : Icons.inventory_2_outlined,
                          color: product.isOutOfStock
                              ? const Color(0xFFB3261E)
                              : product.isLowStock
                              ? const Color(0xFFC46A16)
                              : const Color(0xFF156B4B),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Category: ${product.category}\n'
                        'Selling price: P${product.sellingPrice.toStringAsFixed(2)}\n'
                        'Capital price: P${product.capitalPrice.toStringAsFixed(2)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.stock} in stock',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.isOutOfStock
                                ? 'Out of stock'
                                : product.isLowStock
                                ? 'Low stock'
                                : 'In stock',
                            style: TextStyle(
                              color: product.isOutOfStock
                                  ? const Color(0xFFB3261E)
                                  : product.isLowStock
                                  ? const Color(0xFFC46A16)
                                  : const Color(0xFF156B4B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showEditProductForm(context, product),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _showStockAdjustment(BuildContext context, Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _StockAdjustmentSheet(repository: _repository, product: product),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet({required this.repository, this.product});

  final StoreRepository repository;
  final Product? product;

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _capitalPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _thresholdController;
  String _category = 'Groceries';

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _capitalPriceController = TextEditingController(
      text: product?.capitalPrice.toStringAsFixed(2) ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: product?.sellingPrice.toStringAsFixed(2) ?? '',
    );
    _stockController = TextEditingController(text: '${product?.stock ?? 0}');
    _thresholdController = TextEditingController(
      text: '${product?.lowStockThreshold ?? 5}',
    );
    _category = product?.category ?? 'Groceries';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capitalPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final product = widget.product;
    final name = _nameController.text.trim();
    final capitalPrice = double.parse(_capitalPriceController.text);
    final sellingPrice = double.parse(_sellingPriceController.text);
    final stock = int.parse(_stockController.text);
    final threshold = int.parse(_thresholdController.text);

    if (product == null) {
      widget.repository.addProduct(
        name: name,
        capitalPrice: capitalPrice,
        sellingPrice: sellingPrice,
        stock: stock,
        lowStockThreshold: threshold,
        category: _category,
      );
    } else {
      widget.repository.updateProduct(
        product: product,
        name: name,
        capitalPrice: capitalPrice,
        sellingPrice: sellingPrice,
        stock: stock,
        lowStockThreshold: threshold,
        category: _category,
      );
    }
    Navigator.of(context).pop();
  }

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number < 0
        ? 'Enter zero or a positive number'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.product == null ? 'Add product' : 'Edit product',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF17372D),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a product name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capitalPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Capital price',
                  prefixText: 'P ',
                ),
                validator: _positiveNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellingPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Selling price',
                  prefixText: 'P ',
                ),
                validator: _positiveNumber,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: 'Groceries',
                    child: Text('Groceries'),
                  ),
                  DropdownMenuItem(
                    value: 'Beverages',
                    child: Text('Beverages'),
                  ),
                  DropdownMenuItem(
                    value: 'School supplies',
                    child: Text('School supplies'),
                  ),
                  DropdownMenuItem(value: 'Snacks', child: Text('Snacks')),
                  DropdownMenuItem(
                    value: 'Household',
                    child: Text('Household'),
                  ),
                  DropdownMenuItem(value: 'Hygiene', child: Text('Hygiene')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock quantity',
                      ),
                      validator: (value) {
                        final stock = int.tryParse(value ?? '');
                        return stock == null || stock < 0
                            ? 'Enter 0 or more'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Low-stock threshold',
                      ),
                      validator: (value) {
                        final threshold = int.tryParse(value ?? '');
                        return threshold == null || threshold < 0
                            ? 'Enter 0 or more'
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: const Text('Save product')),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockAdjustmentSheet extends StatefulWidget {
  const _StockAdjustmentSheet({
    required this.repository,
    required this.product,
  });

  final StoreRepository repository;
  final Product product;

  @override
  State<_StockAdjustmentSheet> createState() => _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends State<_StockAdjustmentSheet> {
  final _quantityController = TextEditingController(text: '1');
  StockMovementType _type = StockMovementType.stockIn;
  String _reason = 'Restock';

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a quantity greater than zero.')),
      );
      return;
    }
    final error = widget.repository.adjustStock(
      product: widget.product,
      quantity: quantity,
      type: _type,
      reason: _reason,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isStockIn = _type == StockMovementType.stockIn;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.product.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<StockMovementType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Movement type'),
            items: const [
              DropdownMenuItem(
                value: StockMovementType.stockIn,
                child: Text('Stock in'),
              ),
              DropdownMenuItem(
                value: StockMovementType.damaged,
                child: Text('Damaged'),
              ),
              DropdownMenuItem(
                value: StockMovementType.lost,
                child: Text('Lost'),
              ),
              DropdownMenuItem(
                value: StockMovementType.expired,
                child: Text('Expired'),
              ),
              DropdownMenuItem(
                value: StockMovementType.adjustment,
                child: Text('Manual adjustment'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _type = value;
                  _reason = value == StockMovementType.stockIn
                      ? 'Restock'
                      : value.name;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: isStockIn ? 'Quantity to add' : 'Quantity to remove',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save movement')),
        ],
      ),
    );
  }
}
