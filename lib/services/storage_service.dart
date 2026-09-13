import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/work_entry.dart';

/// Owns all local persistence for work entries.
///
/// Backed by SQLite (via `sqflite`) with `date_key` as the primary key,
/// which is what makes "one record per calendar day" a guarantee enforced
/// by the database itself, not just app logic: every write is an
/// upsert (`INSERT ... ON CONFLICT ... UPDATE`), so saving the same day
/// twice — or flipping it from YES to NO — always updates the single
/// existing row instead of creating a new one.
class StorageService {
  StorageService({Database? database}) : _injectedDatabase = database;

  final Database? _injectedDatabase;
  Database? _database;

  static const String _tableName = 'work_entries';

  Future<Database> get _db async {
    if (_injectedDatabase != null) return _injectedDatabase;
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final String dbPath = await getDatabasesPath();
    final String path = p.join(dbPath, 'workday_noir.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            date_key TEXT PRIMARY KEY,
            worked INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /// Creates a new entry for [entry.date] or updates the existing one for
  /// that day. Never produces a duplicate row for the same calendar day.
  Future<void> upsertEntry(WorkEntry entry) async {
    final Database db = await _db;
    await db.insert(
      _tableName,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WorkEntry?> getEntry(DateTime date) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      where: 'date_key = ?',
      whereArgs: <String>[WorkEntry.keyForDate(date)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkEntry.fromMap(rows.first);
  }

  /// All saved entries, most recent day first.
  Future<List<WorkEntry>> getAllEntries() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      orderBy: 'date_key DESC',
    );
    return rows.map(WorkEntry.fromMap).toList(growable: false);
  }

  Future<void> deleteEntry(DateTime date) async {
    final Database db = await _db;
    await db.delete(
      _tableName,
      where: 'date_key = ?',
      whereArgs: <String>[WorkEntry.keyForDate(date)],
    );
  }

  Future<void> close() async {
    final Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
