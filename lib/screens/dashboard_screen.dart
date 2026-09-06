import 'package:flutter/material.dart';

import '../data/store_repository.dart';
import 'inventory_screen.dart';
import 'record_sale_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.repository});

  final StoreRepository? repository;

  StoreRepository get _repository => repository ?? StoreRepository.instance;

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sari2 dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showComingSoon(
              context,
              'Notifications will be added with store data.',
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _repository,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Good morning, store owner',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF17372D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Here is how your store is doing today.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF68736D),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: "Today's sales",
                        value:
                            'P${_repository.todaySalesTotal.toStringAsFixed(2)}',
                        icon: Icons.trending_up_rounded,
                        color: Color(0xFF156B4B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Low-stock items',
                        value: '${_repository.lowStockCount}',
                        icon: Icons.inventory_2_outlined,
                        color: Color(0xFFC46A16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF17372D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.point_of_sale_rounded,
                  label: 'Record a sale',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RecordSaleScreen(repository: _repository),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  icon: Icons.add_box_outlined,
                  label: 'Add a product',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => InventoryScreen(repository: _repository),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'View sales report',
                  onPressed: () => _showComingSoon(
                    context,
                    'Reports will be added after sales data.',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF17372D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Color(0xFF68736D))),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Align(alignment: Alignment.centerLeft, child: Text(label)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        alignment: Alignment.centerLeft,
        foregroundColor: const Color(0xFF156B4B),
        side: const BorderSide(color: Color(0xFFD3DCD5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
