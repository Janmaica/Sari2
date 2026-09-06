// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sari2_app/main.dart';
import 'package:sari2_app/data/store_repository.dart';
import 'package:sari2_app/models/sale.dart';
import 'package:sari2_app/models/stock_movement.dart';

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

  test('deducts stock only after validating the transaction', () {
    final repository = StoreRepository();
    final product = repository.products.first;

    final success = repository.recordTransaction(
      items: [SaleDraft(product: product, quantity: 3, unitPrice: 55)],
      saleType: SaleType.cash,
    );

    expect(success, isNull);
    expect(repository.products.first.stock, 15);
    expect(repository.sales, hasLength(1));
  });

  test('rejects a sale that would make stock negative', () {
    final repository = StoreRepository();
    final product = repository.products.first;

    final error = repository.recordTransaction(
      items: [
        SaleDraft(product: product, quantity: product.stock + 1, unitPrice: 55),
      ],
      saleType: SaleType.cash,
    );

    expect(error, contains('in stock'));
    expect(repository.products.first.stock, product.stock);
    expect(repository.sales, isEmpty);
  });

  test('records stock adjustments in movement history', () {
    final repository = StoreRepository();
    final product = repository.products.first;

    expect(
      repository.adjustStock(
        product: product,
        quantity: 5,
        type: StockMovementType.stockIn,
        reason: 'Restock',
      ),
      isNull,
    );
    expect(repository.products.first.stock, 23);
    expect(repository.stockMovements.single.quantity, 5);

    final updatedProduct = repository.products.first;
    expect(
      repository.adjustStock(
        product: updatedProduct,
        quantity: 2,
        type: StockMovementType.damaged,
        reason: 'damaged',
      ),
      isNull,
    );
    expect(repository.products.first.stock, 21);
    expect(repository.stockMovements, hasLength(2));
  });

  test('rejects stock removal beyond current quantity', () {
    final repository = StoreRepository();
    final product = repository.products.first;

    final error = repository.adjustStock(
      product: product,
      quantity: product.stock + 1,
      type: StockMovementType.lost,
      reason: 'lost',
    );

    expect(error, contains('in stock'));
    expect(repository.stockMovements, isEmpty);
  });

  testWidgets('opens inventory from the dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    await tester.tap(find.text('Add a product'));
    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Rice (1 kg)'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
  });

  testWidgets('adds a product to inventory', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));

    await tester.tap(find.byTooltip('Add product'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Product name'),
      'Coke',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Capital price'),
      '10',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Selling price'),
      '12',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Stock quantity'),
      '20',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Low-stock threshold'),
      '5',
    );
    await tester.tap(find.text('Save product'));
    await tester.pumpAndSettle();

    expect(find.text('Coke'), findsOneWidget);
    expect(find.text('20 in stock'), findsOneWidget);
  });

  testWidgets('opens stock history from inventory', (
    WidgetTester tester,
  ) async {
    final repository = StoreRepository();
    repository.adjustStock(
      product: repository.products.first,
      quantity: 2,
      type: StockMovementType.stockIn,
      reason: 'Restock',
    );
    await tester.pumpWidget(
      MaterialApp(home: InventoryScreen(repository: repository)),
    );

    await tester.tap(find.byTooltip('Stock history'));
    await tester.pumpAndSettle();

    expect(find.text('Stock history'), findsOneWidget);
    expect(find.text('Stock in: Restock'), findsOneWidget);
  });
}
