import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key, required this.repository});

  final StoreRepository repository;

  @override
  Widget build(BuildContext context) {
    final cashSales = repository.cashSalesInflow;
    final expenses = repository.totalExpenses;
    final netCashFlow = repository.netCashFlow;

    return Scaffold(
      appBar: AppBar(title: const Text('Cash flow')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MetricCard(
            label: 'Cash sales',
            value: 'P${cashSales.toStringAsFixed(2)}',
            accent: Colors.green,
          ),
          const SizedBox(height: 12),
          _MetricCard(
            label: 'Expenses',
            value: 'P${expenses.toStringAsFixed(2)}',
            accent: Colors.orange,
          ),
          const SizedBox(height: 12),
          _MetricCard(
            label: 'Net cash flow',
            value: 'P${netCashFlow.toStringAsFixed(2)}',
            accent: netCashFlow >= 0 ? Colors.blue : Colors.red,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
