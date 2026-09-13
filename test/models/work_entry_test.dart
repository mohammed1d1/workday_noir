import 'package:flutter_test/flutter_test.dart';
import 'package:workday_noir/models/work_entry.dart';

void main() {
  group('WorkEntry', () {
    test('normalizes date to midnight, stripping time-of-day', () {
      final WorkEntry entry = WorkEntry(
        date: DateTime(2026, 9, 11, 23, 45, 12),
        worked: true,
      );
      expect(entry.date, DateTime(2026, 9, 11));
    });

    test('dateKey is stable and zero-padded', () {
      final WorkEntry entry = WorkEntry(date: DateTime(2026, 1, 5), worked: false);
      expect(entry.dateKey, '2026-01-05');
    });

    test('two entries on the same day produce the same dateKey', () {
      final WorkEntry morning = WorkEntry(date: DateTime(2026, 9, 11, 8), worked: true);
      final WorkEntry night = WorkEntry(date: DateTime(2026, 9, 11, 23), worked: false);
      expect(morning.dateKey, night.dateKey);
    });

    test('monthKey groups by year and month', () {
      final WorkEntry entry = WorkEntry(date: DateTime(2026, 12, 31), worked: true);
      expect(entry.monthKey, '2026-12');
    });

    test('December and January of different years have different monthKeys', () {
      final WorkEntry dec = WorkEntry(date: DateTime(2026, 12, 31), worked: true);
      final WorkEntry jan = WorkEntry(date: DateTime(2027, 1, 1), worked: true);
      expect(dec.monthKey, isNot(jan.monthKey));
    });

    test('round-trips through toMap/fromMap', () {
      final WorkEntry original = WorkEntry(date: DateTime(2026, 3, 7), worked: true);
      final WorkEntry restored = WorkEntry.fromMap(original.toMap());
      expect(restored, original);
    });

    test('copyWith overrides only the given fields', () {
      final WorkEntry original = WorkEntry(date: DateTime(2026, 3, 7), worked: true);
      final WorkEntry updated = original.copyWith(worked: false);
      expect(updated.date, original.date);
      expect(updated.worked, false);
    });
  });
}
