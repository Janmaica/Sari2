import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, this.repository});

  final StoreRepository? repository;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  StoreRepository get _repository =>
      widget.repository ?? StoreRepository.instance;

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final error = _repository.addExpense(
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      category: _categoryController.text,
    );

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    _nameController.clear();
    _amountController.clear();
    _categoryController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense saved.')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Expense name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter an expense name.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: 'P ',
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Enter an amount greater than zero';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category (optional)',
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _saveExpense,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save expense'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Expense log',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (_repository.expenses.isEmpty)
                  const Expanded(child: Center(child: Text('No expenses yet.')))
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _repository.expenses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final expense = _repository.expenses.reversed
                            .toList()[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(expense.name),
                            subtitle: Text(expense.category),
                            trailing: Text(
                              'P${expense.amount.toStringAsFixed(2)}',
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
          );
        },
      ),
    );
  }
}
