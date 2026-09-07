import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

export 'screens/cash_flow_screen.dart';
export 'screens/dashboard_screen.dart';
export 'screens/inventory_screen.dart';
export 'screens/login_screen.dart';
export 'screens/notifications_screen.dart';
export 'screens/purchases_screen.dart';
export 'screens/record_sale_screen.dart';
export 'screens/reports_screen.dart';
export 'screens/sales_history_screen.dart';
export 'screens/stock_history_screen.dart';
export 'screens/utang_screen.dart';

void main() {
  runApp(const Sari2App());
}

class Sari2App extends StatelessWidget {
  const Sari2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sari2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF156B4B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F5EF),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE4E6DE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF156B4B), width: 2),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
