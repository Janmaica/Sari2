import 'package:flutter/material.dart';

import '../data/store_repository.dart';
import '../models/customer.dart';
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
        text: product.sellingPrice.toStringAsFixed(2),
      ),
      productController = TextEditingController(text: product.name);

  Product product;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController productController;

  double get total {
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    return quantity * price;
  }

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    productController.dispose();
  }
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final StoreRepository _repository;
  late final List<_SaleLine> _lines;
  SaleType _saleType = SaleType.cash;
  Customer? _selectedCustomer;

  double get _total => _lines.fold(0, (total, line) => total + line.total);

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? StoreRepository.instance;
    _lines = [_SaleLine(_repository.products.first)];
    _selectedCustomer = _repository.customers.isNotEmpty
        ? _repository.customers.first
        : null;
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

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a customer name.')),
                  );
                  return;
                }
                final customer = _repository.addCustomer(
                  name: name,
                  contact: contactController.text.trim(),
                );
                setState(() => _selectedCustomer = customer);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save customer'),
            ),
          ],
        );
      },
    );
  }

  void _recordSale() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_saleType == SaleType.utang && _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a customer before saving an utang sale.'),
        ),
      );
      return;
    }

    final error = _repository.recordTransaction(
      items: _lines
          .map(
            (line) => SaleDraft(
              product: line.product,
              quantity: double.parse(line.quantityController.text),
              unitPrice: double.parse(line.priceController.text),
            ),
          )
          .toList(),
      saleType: _saleType,
      customer: _selectedCustomer,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
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
                    setState(() {
                      _saleType = selection.first;
                      if (_saleType == SaleType.utang &&
                          _selectedCustomer == null &&
                          _repository.customers.isNotEmpty) {
                        _selectedCustomer = _repository.customers.first;
                      }
                    });
                  },
                ),
                if (_saleType == SaleType.utang) ...[
                  const SizedBox(height: 18),
                  if (_repository.customers.isEmpty)
                    OutlinedButton.icon(
                      onPressed: _showAddCustomerDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Add customer for utang'),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedCustomer?.id,
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: _repository.customers
                          .map(
                            (customer) => DropdownMenuItem(
                              value: customer.id,
                              child: Text(customer.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCustomer = _repository.customers.firstWhere(
                            (customer) => customer.id == value,
                          );
                        });
                      },
                      validator: (value) {
                        if (_saleType == SaleType.utang && value == null) {
                          return 'Select a customer';
                        }
                        return null;
                      },
                    ),
                ],
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
            Autocomplete<Product>(
              optionsBuilder: (value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) {
                  return _repository.products;
                }
                return _repository.products.where(
                  (product) => product.name.toLowerCase().contains(query),
                );
              },
              displayStringForOption: (product) => product.name,
              onSelected: (product) {
                setState(() {
                  line.product = product;
                  line.productController.text = product.name;
                  line.priceController.text = product.sellingPrice
                      .toStringAsFixed(2);
                });
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    textEditingController.text = line.productController.text;
                    return TextFormField(
                      controller: line.productController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => onFieldSubmitted(),
                    );
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
                      if (quantity == null ||
                          quantity <= 0 ||
                          quantity % 1 != 0) {
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
                    readOnly: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price per item',
                      prefixText: 'P ',
                    ),
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
