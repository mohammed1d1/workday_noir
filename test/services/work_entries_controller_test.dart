import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workday_noir/models/work_entry.dart';
import 'package:workday_noir/services/export_service.dart';
import 'package:workday_noir/services/storage_service.dart';
import 'package:workday_noir/services/work_entries_controller.dart';

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

  group('WorkEntriesController', () {
    test('setDay twice with the same value does not duplicate the entry', () async {
      final WorkEntriesController controller =
          WorkEntriesController(storageService: await _newInMemoryStorage());
      await controller.load();

      final DateTime date = DateTime(2026, 9, 11);
      await controller.setDay(date: date, worked: true);
      await controller.setDay(date: date, worked: true);

      expect(controller.entries.length, 1);
    });

    test('flipping a day from worked to not-worked updates it in place', () async {
      final WorkEntriesController controller =
          WorkEntriesController(storageService: await _newInMemoryStorage());
      await controller.load();

      final DateTime date = DateTime(2026, 9, 11);
      await controller.setDay(date: date, worked: true);
      await controller.setDay(date: date, worked: false);

      expect(controller.entries.length, 1);
      expect(controller.entries.single.worked, false);
    });

    test('groupedByMonth separates December and January across years', () async {
      final WorkEntriesController controller =
          WorkEntriesController(storageService: await _newInMemoryStorage());
      await controller.load();

      await controller.setDay(date: DateTime(2026, 12, 31), worked: true);
      await controller.setDay(date: DateTime(2027, 1, 1), worked: true);

      final List<MonthGroup> groups = controller.groupedByMonth;
      expect(groups.length, 2);
      // Newest month first.
      expect(groups.first.year, 2027);
      expect(groups.first.month, 1);
      expect(groups.last.year, 2026);
      expect(groups.last.month, 12);
    });

    test('a month total counts only worked (YES) days', () async {
      final WorkEntriesController controller =
          WorkEntriesController(storageService: await _newInMemoryStorage());
      await controller.load();

      await controller.setDay(date: DateTime(2026, 9, 8), worked: true);
      await controller.setDay(date: DateTime(2026, 9, 9), worked: true);
      await controller.setDay(date: DateTime(2026, 9, 10), worked: false);
      await controller.setDay(date: DateTime(2026, 9, 11), worked: true);

      final MonthGroup september = controller.groupedByMonth.single;
      expect(september.totalWorkedDays, 3);
      expect(september.entries.length, 4);
    });

    test('overall total sums worked days across all months', () async {
      final WorkEntriesController controller =
          WorkEntriesController(storageService: await _newInMemoryStorage());
      await controller.load();

      await controller.setDay(date: DateTime(2026, 9, 30), worked: true);
      await controller.setDay(date: DateTime(2026, 10, 1), worked: true);
      await controller.setDay(date: DateTime(2026, 10, 2), worked: false);

      expect(controller.totalWorkedDaysOverall, 2);
    });

    test('todayEntry reflects the most recent save for today', () async {
      final WorkEntriesController controller =
          WorkEntriesController(storageService: await _newInMemoryStorage());
      await controller.load();

      expect(controller.todayEntry, isNull);

      await controller.setToday(worked: true);
      expect(controller.todayEntry?.worked, true);

      await controller.setToday(worked: false);
      expect(controller.todayEntry?.worked, false);
      expect(controller.entries.length, 1);
    });

    test('load() populates entries from existing storage', () async {
      final StorageService storage = await _newInMemoryStorage();
      final WorkEntriesController seedController =
          WorkEntriesController(storageService: storage);
      await seedController.load();
      await seedController.setDay(date: DateTime(2026, 9, 11), worked: true);

      // A fresh controller against the same storage should see the data
      // that was already persisted — this is what "closing and reopening
      // the app must preserve all data" means in practice.
      final WorkEntriesController freshController =
          WorkEntriesController(storageService: storage);
      await freshController.load();

      expect(freshController.entries.length, 1);
      expect(freshController.todayEntry?.worked, true);
    });
  });

  group('ExportService', () {
    test('buildExportText matches the documented format', () {
      final ExportService exportService = ExportService();

      final List<MonthGroup> groups = <MonthGroup>[
        MonthGroup(
          year: 2026,
          month: 9,
          entries: <WorkEntry>[
            WorkEntry(date: DateTime(2026, 9, 8), worked: true),
            WorkEntry(date: DateTime(2026, 9, 9), worked: true),
            WorkEntry(date: DateTime(2026, 9, 10), worked: false),
            WorkEntry(date: DateTime(2026, 9, 11), worked: true),
          ],
        ),
      ];

      final String text = exportService.buildExportText(groups);
      expect(text, contains('Workday Noir'));
      expect(text, contains('September 2026'));
      expect(text, contains('8/9 ✅'));
      expect(text, contains('10/9 ❌'));
      expect(text, contains('Total worked days: 3'));
    });
  });
}
