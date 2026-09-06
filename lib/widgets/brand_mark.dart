import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC857),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Color(0xFF17372D),
            size: 29,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Sari2',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF17372D),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
