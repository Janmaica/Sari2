// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sari2_app/main.dart';

void main() {
  testWidgets('shows the login form', (WidgetTester tester) async {
    await tester.pumpWidget(const Sari2App());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email or phone number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('validates empty login fields', (WidgetTester tester) async {
    await tester.pumpWidget(const Sari2App());

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter your email or phone number'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(const Sari2App());

    final passwordField = find.byType(TextField).last;
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
  });

  testWidgets('opens the dashboard with valid login fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Sari2App());

    await tester.enterText(
      find.byType(TextFormField).first,
      'owner@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret1');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Sari2 dashboard'), findsOneWidget);
    expect(find.text('Good morning, store owner'), findsOneWidget);
    expect(find.text("Today's sales"), findsOneWidget);
    expect(find.text('Record a sale'), findsOneWidget);
  });

  testWidgets('opens the record sale form', (WidgetTester tester) async {
    await tester.pumpWidget(const Sari2App());

    await tester.enterText(
      find.byType(TextFormField).first,
      'owner@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret1');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record a sale'));
    await tester.pumpAndSettle();

    expect(find.text('New sale'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Save sale'), findsOneWidget);
  });

  testWidgets('saves a valid local sale', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecordSaleScreen()));

    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.enterText(find.byType(TextFormField).last, '15.50');
    await tester.tap(find.text('Save sale'));
    await tester.pump();

    expect(find.text('Sale recorded locally.'), findsOneWidget);
    expect(find.text('P31.00'), findsOneWidget);
  });

  testWidgets('combines multiple items in one transaction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RecordSaleScreen()));

    await tester.tap(find.text('Utang'));
    await tester.tap(find.text('Add another item'));
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '2');
    await tester.enterText(fields.at(1), '10');
    await tester.enterText(fields.at(2), '1');
    await tester.enterText(fields.at(3), '5');
    await tester.pump();

    expect(find.text('P25.00'), findsOneWidget);

    await tester.ensureVisible(find.text('Save sale'));
    await tester.tap(find.text('Save sale'));
    await tester.pump();

    expect(find.text('Sale recorded locally.'), findsOneWidget);
  });
}
