import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key, this.repository});

  final StoreRepository? repository;

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitCostController = TextEditingController();

  StoreRepository get _repository =>
      widget.repository ?? StoreRepository.instance;

  void _savePurchase() {
    if (!_formKey.currentState!.validate()) return;

    final supplierName = _supplierController.text.trim();
    final quantity = int.parse(_quantityController.text);
    final unitCost = double.parse(_unitCostController.text);

    final error = _repository.addPurchase(
      supplierName: supplierName,
      quantity: quantity,
      unitCost: unitCost,
      product: _repository.products.first,
    );

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    _supplierController.clear();
    _quantityController.text = '1';
    _unitCostController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Purchase recorded.')));
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        actions: [
          IconButton(
            tooltip: 'Add purchase',
            onPressed: () => _savePurchase(),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _supplierController,
                  decoration: const InputDecoration(labelText: 'Supplier name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter supplier name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    final quantity = int.tryParse(value ?? '');
                    return quantity == null || quantity <= 0
                        ? 'Enter quantity greater than zero'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unitCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Unit cost',
                    prefixText: 'P ',
                  ),
                  validator: (value) {
                    final cost = double.tryParse(value ?? '');
                    return cost == null || cost < 0
                        ? 'Enter a valid cost'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _savePurchase,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Save purchase'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent purchases',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (_repository.purchases.isEmpty)
                  const Expanded(
                    child: Center(child: Text('No purchases yet.')),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _repository.purchases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final purchase = _repository.purchases.reversed
                            .toList()[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(purchase.supplierName),
                            subtitle: Text(
                              '${purchase.productName} • ${purchase.quantity} pcs',
                            ),
                            trailing: Text(
                              'P${purchase.totalCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
