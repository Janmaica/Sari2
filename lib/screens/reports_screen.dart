import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, this.repository});

  final StoreRepository? repository;

  StoreRepository get _repository => repository ?? StoreRepository.instance;

  @override
  Widget build(BuildContext context) {
    final salesRevenue = _repository.totalSalesRevenue;
    final costOfGoodsSold = _repository.totalCostOfGoodsSold;
    final grossProfit = _repository.grossProfit;
    final totalExpenses = _repository.totalExpenses;
    final netProfit = grossProfit - totalExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Sales report')),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MetricCard(
                label: 'Sales revenue',
                value: 'P${salesRevenue.toStringAsFixed(2)}',
                color: const Color(0xFF156B4B),
              ),
              const SizedBox(height: 12),
              _MetricCard(
                label: 'Cost of goods sold',
                value: 'P${costOfGoodsSold.toStringAsFixed(2)}',
                color: const Color(0xFFC46A16),
              ),
              const SizedBox(height: 12),
              _MetricCard(
                label: 'Gross profit',
                value: 'P${grossProfit.toStringAsFixed(2)}',
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 12),
              _MetricCard(
                label: 'Expenses',
                value: 'P${totalExpenses.toStringAsFixed(2)}',
                color: const Color(0xFF7A3D18),
              ),
              const SizedBox(height: 12),
              _MetricCard(
                label: 'Net profit',
                value: 'P${netProfit.toStringAsFixed(2)}',
                color: const Color(0xFF0F766E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF68736D))),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
