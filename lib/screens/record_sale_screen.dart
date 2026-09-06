import 'package:flutter/material.dart';

import '../data/store_repository.dart';
import '../models/product.dart';
import '../models/sale.dart';

class RecordSaleScreen extends StatefulWidget {
  const RecordSaleScreen({super.key, this.repository});

  final StoreRepository? repository;

  @override
  State<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _SaleLine {
  _SaleLine(this.product)
    : quantityController = TextEditingController(text: '1'),
      priceController = TextEditingController(
        text: product.defaultPrice.toStringAsFixed(2),
      );

  Product product;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  double get total {
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    return quantity * price;
  }

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final StoreRepository _repository;
  late final List<_SaleLine> _lines;
  SaleType _saleType = SaleType.cash;

  double get _total => _lines.fold(0, (total, line) => total + line.total);

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? StoreRepository.instance;
    _lines = [_SaleLine(_repository.products.first)];
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() => _lines.add(_SaleLine(_repository.products.first)));
  }

  void _removeItem(int index) {
    final line = _lines.removeAt(index);
    line.dispose();
    setState(() {});
  }

  void _recordSale() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    for (final line in _lines) {
      _repository.recordSale(
        product: line.product,
        quantity: double.parse(line.quantityController.text),
        unitPrice: double.parse(line.priceController.text),
        saleType: _saleType,
      );
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sale recorded locally.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record a sale')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New sale',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF17372D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add every item in the customer\'s transaction.',
                  style: TextStyle(color: Color(0xFF68736D)),
                ),
                const SizedBox(height: 20),
                SegmentedButton<SaleType>(
                  segments: const [
                    ButtonSegment(
                      value: SaleType.cash,
                      label: Text('Cash'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                    ButtonSegment(
                      value: SaleType.utang,
                      label: Text('Utang'),
                      icon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                  ],
                  selected: {_saleType},
                  onSelectionChanged: (selection) {
                    setState(() => _saleType = selection.first);
                  },
                ),
                const SizedBox(height: 24),
                ..._lines.asMap().entries.map(
                  (entry) => _buildSaleLine(entry.key, entry.value),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add another item'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: const Color(0xFFE8F1EB),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total sale',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'P${_total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF156B4B),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _recordSale,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save sale'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFF156B4B),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaleLine(int index, _SaleLine line) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (_lines.length > 1)
                  IconButton(
                    tooltip: 'Remove item',
                    onPressed: () => _removeItem(index),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: line.product.id,
              decoration: const InputDecoration(
                labelText: 'Product',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              items: _repository.products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product.id,
                      child: Text(product.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final product = _repository.products.firstWhere(
                  (item) => item.id == value,
                );
                setState(() {
                  line.product = product;
                  line.priceController.text = product.defaultPrice
                      .toStringAsFixed(2);
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: line.quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final quantity = double.tryParse(value ?? '');
                      if (quantity == null || quantity <= 0) {
                        return 'Enter a quantity above zero';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: line.priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price per item',
                      prefixText: 'P ',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price <= 0) {
                        return 'Enter a price above zero';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
