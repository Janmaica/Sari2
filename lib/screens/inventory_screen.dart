import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key, this.repository});

  final StoreRepository? repository;

  StoreRepository get _repository => repository ?? StoreRepository.instance;

  void _showAddProductForm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddProductSheet(repository: _repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () => _showAddProductForm(context),
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          itemCount: _repository.products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final product = _repository.products[index];
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet({required this.repository});

  final StoreRepository repository;

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capitalPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _thresholdController = TextEditingController(text: '5');

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

    widget.repository.addProduct(
      name: _nameController.text.trim(),
      capitalPrice: double.parse(_capitalPriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      stock: int.parse(_stockController.text),
      lowStockThreshold: int.parse(_thresholdController.text),
    );
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
                'Add product',
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
