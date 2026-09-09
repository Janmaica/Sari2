import 'package:flutter/material.dart';

import '../data/store_repository.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class UtangScreen extends StatelessWidget {
  const UtangScreen({super.key, this.repository});

  final StoreRepository? repository;

  StoreRepository get _repository => repository ?? StoreRepository.instance;

  void _showAddCustomer(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _CustomerDialog(repository: _repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utang'),
        actions: [
          IconButton(
            tooltip: 'Add customer',
            onPressed: () => _showAddCustomer(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          if (_repository.customers.isEmpty) {
            return const Center(child: Text('No customers yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _repository.customers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final customer = _repository.customers[index];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F1EB),
                  child: Icon(Icons.person_outline, color: Color(0xFF156B4B)),
                ),
                title: Text(
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  customer.balance == 0
                      ? 'Paid in full'
                      : 'Remaining balance: P${customer.balance.toStringAsFixed(2)}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CustomerDetailScreen(
                      customerId: customer.id,
                      repository: _repository,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    required this.repository,
  });

  final String customerId;
  final StoreRepository repository;

  Customer? get _customer => repository.customers.cast<Customer?>().firstWhere(
    (customer) => customer?.id == customerId,
    orElse: () => null,
  );

  void _showAmountDialog(
    BuildContext context,
    Customer customer,
    bool payment,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _AmountDialog(
        customer: customer,
        repository: repository,
        payment: payment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer account')),
      body: ListenableBuilder(
        listenable: repository,
        builder: (context, _) {
          final customer = _customer;
          if (customer == null) {
            return const Center(child: Text('Customer not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  customer.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF17372D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (customer.contact.isNotEmpty) Text(customer.contact),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: const Color(0xFFFFF1D6),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Remaining balance'),
                        const SizedBox(height: 5),
                        Text(
                          'P${customer.balance.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Credited items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF17372D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _CreditedItemsList(
                    sales: repository.sales
                        .where(
                          (sale) =>
                              sale.customerId == customer.id &&
                              sale.saleType == SaleType.utang,
                        )
                        .toList()
                        .reversed
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => _showAmountDialog(context, customer, false),
                  icon: const Icon(Icons.add_card_rounded),
                  label: const Text('Add debt'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: customer.balance == 0
                      ? null
                      : () => _showAmountDialog(context, customer, true),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Record payment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CreditedItemsList extends StatelessWidget {
  const _CreditedItemsList({required this.sales});

  final List<Sale> sales;

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: Text('No itemized credit sales yet.'),
      );
    }

    return ListView.separated(
      itemCount: sales.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final sale = sales[index];
        final quantity = sale.quantity == sale.quantity.truncateToDouble()
            ? sale.quantity.toInt().toString()
            : sale.quantity.toStringAsFixed(2);
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.white,
          child: ListTile(
            leading: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF156B4B),
            ),
            title: Text(
              sale.productName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Quantity: $quantity  |  P${sale.unitPrice.toStringAsFixed(2)} each',
            ),
            trailing: Text(
              'P${sale.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}

class _CustomerDialog extends StatefulWidget {
  const _CustomerDialog({required this.repository});

  final StoreRepository repository;

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.repository.addCustomer(
      name: _nameController.text.trim(),
      contact: _contactController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add customer'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a customer name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save customer')),
      ],
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.customer,
    required this.repository,
    required this.payment,
  });

  final Customer customer;
  final StoreRepository repository;
  final bool payment;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount greater than zero.')),
      );
      return;
    }
    final error = widget.payment
        ? widget.repository.recordPayment(
            customer: widget.customer,
            amount: amount,
          )
        : widget.repository.addDebt(customer: widget.customer, amount: amount);
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
    return AlertDialog(
      title: Text(widget.payment ? 'Record payment' : 'Add debt'),
      content: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Amount',
          prefixText: 'P ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
