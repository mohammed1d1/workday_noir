import 'package:flutter/foundation.dart';

import '../models/work_entry.dart';
import 'export_service.dart';
import 'storage_service.dart';

/// Single source of truth for work-entry state on screen.
///
/// This is intentionally a plain [ChangeNotifier] rather than a state
/// management package: the app has three screens and one piece of shared
/// state, so a package would add complexity without adding value. Widgets
/// rebuild via [AnimatedBuilder] listening to this controller.
class WorkEntriesController extends ChangeNotifier {
  WorkEntriesController({required StorageService storageService})
      : _storage = storageService;

  final StorageService _storage;

  List<WorkEntry> _entries = <WorkEntry>[];
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  /// All entries, most recent day first.
  List<WorkEntry> get entries => List<WorkEntry>.unmodifiable(_entries);

  WorkEntry? get todayEntry {
    final DateTime today = DateTime.now();
    final String todayKey = WorkEntry.keyForDate(today);
    for (final WorkEntry entry in _entries) {
      if (entry.dateKey == todayKey) return entry;
    }
    return null;
  }

  int get totalWorkedDaysOverall =>
      _entries.where((WorkEntry e) => e.worked).length;

  /// Entries grouped by month, most recent month first; each month's
  /// entries are ascending by date (oldest to newest within the month) —
  /// this matches both the History screen and the Export format.
  List<MonthGroup> get groupedByMonth {
    final Map<String, List<WorkEntry>> byMonth = <String, List<WorkEntry>>{};
    for (final WorkEntry entry in _entries) {
      byMonth.putIfAbsent(entry.monthKey, () => <WorkEntry>[]).add(entry);
    }

    final List<String> sortedKeys = byMonth.keys.toList()
      ..sort((String a, String b) => b.compareTo(a)); // newest month first

    return sortedKeys.map((String key) {
      final List<WorkEntry> monthEntries = byMonth[key]!
        ..sort((WorkEntry a, WorkEntry b) => a.date.compareTo(b.date));
      final List<String> parts = key.split('-');
      return MonthGroup(
        year: int.parse(parts[0]),
        month: int.parse(parts[1]),
        entries: monthEntries,
      );
    }).toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _storage.getAllEntries();
    _isLoading = false;
    notifyListeners();
  }

  /// Records today's status. Idempotent and duplicate-safe: calling this
  /// repeatedly, or flipping YES→NO→YES, always updates the single entry
  /// for today rather than creating new ones.
  Future<void> setToday({required bool worked}) async {
    await setDay(date: DateTime.now(), worked: worked);
  }

  /// Records or edits the status for an arbitrary day (used by the
  /// History screen to correct a past entry).
  Future<void> setDay({required DateTime date, required bool worked}) async {
    final WorkEntry entry = WorkEntry(date: date, worked: worked);
    await _storage.upsertEntry(entry);

    final String key = entry.dateKey;
    final int existingIndex =
        _entries.indexWhere((WorkEntry e) => e.dateKey == key);
    if (existingIndex == -1) {
      _entries.add(entry);
      _entries.sort((WorkEntry a, WorkEntry b) => b.date.compareTo(a.date));
    } else {
      _entries[existingIndex] = entry;
    }
    notifyListeners();
  }
}
