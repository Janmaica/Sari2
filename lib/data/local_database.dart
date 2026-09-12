import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  static const _databaseName = 'sari2.db';
  static const _databaseVersion = 1;
  static const _collections = [
    'products',
    'customers',
    'sales',
    'stockMovements',
    'debts',
    'payments',
    'expenses',
    'purchases',
  ];

  Future<Database>? _databaseFuture;

  Future<Database> get database => _databaseFuture ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final useFfi = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    if (useFfi) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final factory = useFfi ? databaseFactoryFfi : databaseFactory;
    final isFlutterTest = Platform.environment['FLUTTER_TEST'] == 'true';
    final path = isFlutterTest
        ? ':memory:'
        : join(await getDatabasesPath(), _databaseName);
    final database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: (database, version) async {
          for (final collection in _collections) {
            await database.execute(
              'CREATE TABLE $collection (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL)',
            );
          }
        },
      ),
    );
    return database;
  }

  Future<Map<String, List<Map<String, dynamic>>>?> readSnapshot() async {
    final database = await this.database;
    final snapshot = <String, List<Map<String, dynamic>>>{};

    for (final collection in _collections) {
      final rows = await database.query(collection, orderBy: 'id ASC');
      final items = <Map<String, dynamic>>[];
      for (final row in rows) {
        final decoded = jsonDecode(row['data']! as String);
        if (decoded is List) {
          items.addAll(decoded.whereType<Map<String, dynamic>>());
        } else if (decoded is Map<String, dynamic>) {
          items.add(decoded);
        }
      }
      snapshot[collection] = items;
    }

    final hasData = snapshot.values.any((items) => items.isNotEmpty);
    return hasData ? snapshot : null;
  }

  Future<void> writeSnapshot(Map<String, dynamic> snapshot) {
    return _writeSnapshot(snapshot);
  }

  Future<void> _writeSnapshot(Map<String, dynamic> snapshot) async {
    final database = await this.database;
    final batch = database.batch();
    for (final collection in _collections) {
      batch.delete(collection);
      final items = snapshot[collection] as List? ?? const [];
      batch.insert(collection, {'data': jsonEncode(items)});
    }
    await batch.commit(noResult: true);
  }
}
