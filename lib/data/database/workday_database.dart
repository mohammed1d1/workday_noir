import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/work_entry.dart';

final databaseProvider = Provider<WorkdayDatabase>((ref) => throw UnimplementedError());

class WorkdayDatabase {
  final Database db;
  WorkdayDatabase._(this.db);
  static Future<WorkdayDatabase> open() async {
    final path = join(await getDatabasesPath(), 'workday_noir.db');
    final db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('CREATE TABLE work_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL UNIQUE, status TEXT NOT NULL, note TEXT)');
      await db.execute('CREATE INDEX idx_work_entries_date ON work_entries(date)');
    });
    return WorkdayDatabase._(db);
  }
  Future<void> upsert(WorkEntry e) async => db.insert('work_entries', e.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  Future<WorkEntry?> byDate(String date) async { final r = await db.query('work_entries', where: 'date = ?', whereArgs: [date], limit: 1); return r.isEmpty ? null : WorkEntry.fromMap(r.first); }
  Future<List<WorkEntry>> all() async { final r = await db.query('work_entries', orderBy: 'date DESC'); return r.map(WorkEntry.fromMap).toList(); }
  Future<List<WorkEntry>> range(String start, String end) async { final r = await db.query('work_entries', where: 'date >= ? AND date <= ?', whereArgs: [start,end], orderBy: 'date DESC'); return r.map(WorkEntry.fromMap).toList(); }
  Future<void> deleteDate(String date) => db.delete('work_entries', where: 'date = ?', whereArgs: [date]);
  Future<void> deleteAll() => db.delete('work_entries');
}
