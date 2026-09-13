import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workday_noir/models/work_entry.dart';
import 'package:workday_noir/services/storage_service.dart';

/// These tests exercise [StorageService] against a real (in-memory) SQLite
/// database via `sqflite_common_ffi`, rather than mocking the database —
/// duplicate-prevention and update-in-place behavior depends on actual
/// SQL conflict resolution, which is exactly what needs verifying.
Future<StorageService> _newInMemoryStorage() async {
  final Database db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('''
    CREATE TABLE work_entries (
      date_key TEXT PRIMARY KEY,
      worked INTEGER NOT NULL
    )
  ''');
  return StorageService(database: db);
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('StorageService', () {
    test('saving a new entry makes it retrievable', () async {
      final StorageService storage = await _newInMemoryStorage();
      final DateTime date = DateTime(2026, 9, 11);
      await storage.upsertEntry(WorkEntry(date: date, worked: true));

      final WorkEntry? fetched = await storage.getEntry(date);
      expect(fetched, isNotNull);
      expect(fetched!.worked, true);
    });

    test('saving the same date twice does not create a duplicate', () async {
      final StorageService storage = await _newInMemoryStorage();
      final DateTime date = DateTime(2026, 9, 11);

      await storage.upsertEntry(WorkEntry(date: date, worked: true));
      await storage.upsertEntry(WorkEntry(date: date, worked: true));

      final List<WorkEntry> all = await storage.getAllEntries();
      expect(all.length, 1);
    });

    test('changing YES to NO updates the existing record in place', () async {
      final StorageService storage = await _newInMemoryStorage();
      final DateTime date = DateTime(2026, 9, 11);

      await storage.upsertEntry(WorkEntry(date: date, worked: true));
      await storage.upsertEntry(WorkEntry(date: date, worked: false));

      final List<WorkEntry> all = await storage.getAllEntries();
      expect(all.length, 1);
      expect(all.single.worked, false);
    });

    test('entries on different days are stored separately', () async {
      final StorageService storage = await _newInMemoryStorage();
      await storage.upsertEntry(WorkEntry(date: DateTime(2026, 9, 10), worked: true));
      await storage.upsertEntry(WorkEntry(date: DateTime(2026, 9, 11), worked: false));

      final List<WorkEntry> all = await storage.getAllEntries();
      expect(all.length, 2);
    });

    test('getAllEntries returns most-recent day first', () async {
      final StorageService storage = await _newInMemoryStorage();
      await storage.upsertEntry(WorkEntry(date: DateTime(2026, 9, 1), worked: true));
      await storage.upsertEntry(WorkEntry(date: DateTime(2026, 9, 30), worked: true));
      await storage.upsertEntry(WorkEntry(date: DateTime(2026, 9, 15), worked: false));

      final List<WorkEntry> all = await storage.getAllEntries();
      expect(all.map((WorkEntry e) => e.date.day).toList(), <int>[30, 15, 1]);
    });

    test('a record with no saved entry returns null', () async {
      final StorageService storage = await _newInMemoryStorage();
      final WorkEntry? fetched = await storage.getEntry(DateTime(2026, 9, 11));
      expect(fetched, isNull);
    });

    test('deleteEntry removes a saved record', () async {
      final StorageService storage = await _newInMemoryStorage();
      final DateTime date = DateTime(2026, 9, 11);
      await storage.upsertEntry(WorkEntry(date: date, worked: true));

      await storage.deleteEntry(date);

      expect(await storage.getEntry(date), isNull);
    });
  });
}
