import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

Future<Database> initDatabase() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = '${documentsDirectory.path}/math_expressions.db';
  Database database = await openDatabase(
    path,
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS expressions (id INTEGER PRIMARY KEY, expression TEXT)',
      );
      await db.execute(
        'CREATE TABLE IF NOT EXISTS favorites (id INTEGER PRIMARY KEY, expression TEXT)',
      );
    },
  );

  return database;
}

Future<void> deleteExpression(String expr) async {
  final db = await initDatabase();
  await db.delete('expressions', where: 'expression = ?', whereArgs: [expr]);
}

Future<void> clearHistory() async {
  final db = await initDatabase();
  await db.delete('expressions');
}

Future<List<String>> getHistory() async {
  final db = await initDatabase();
  final rows = await db.query(
    'expressions',
    columns: ['expression'],
    orderBy: 'id DESC',
  );
  return rows.map((r) => r['expression'] as String).toList();
}

Future<int> saveExpression(String expression) async {
  Database db = await initDatabase();
  return await db.insert('expressions', {'expression': expression});
}

// ── Favorites ──────────────────────────────────────────────

Future<List<String>> getFavorites() async {
  final db = await initDatabase();
  final rows = await db.query(
    'favorites',
    columns: ['expression'],
    orderBy: 'id DESC',
  );
  return rows.map((r) => r['expression'] as String).toList();
}

Future<bool> isFavorite(String expression) async {
  final db = await initDatabase();
  final rows = await db.query(
    'favorites',
    where: 'expression = ?',
    whereArgs: [expression],
  );
  return rows.isNotEmpty;
}

Future<int> saveFavorite(String expression) async {
  final db = await initDatabase();
  // Avoid duplicates
  final existing = await db.query(
    'favorites',
    where: 'expression = ?',
    whereArgs: [expression],
  );
  if (existing.isNotEmpty) return 0;
  return await db.insert('favorites', {'expression': expression});
}

Future<void> deleteFavorite(String expression) async {
  final db = await initDatabase();
  await db.delete(
    'favorites',
    where: 'expression = ?',
    whereArgs: [expression],
  );
}

Future<void> clearFavorites() async {
  final db = await initDatabase();
  await db.delete('favorites');
}
