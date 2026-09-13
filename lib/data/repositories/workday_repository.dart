import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/date_utils.dart';
import '../database/workday_database.dart';
import '../models/work_entry.dart';

final repositoryProvider = Provider<WorkdayRepository>((ref) => WorkdayRepository(ref.watch(databaseProvider)));
final entriesProvider = FutureProvider<List<WorkEntry>>((ref) async => ref.watch(repositoryProvider).getEntries());
final todayEntryProvider = FutureProvider<WorkEntry?>((ref) async => ref.watch(repositoryProvider).getForDate(todayLocal()));

class WorkdayRepository {
  final WorkdayDatabase db;
  WorkdayRepository(this.db);
  Future<void> record(DateTime date, WorkStatus status, {String? note}) async {
    final d = DateTime(date.year,date.month,date.day);
    if (d.isAfter(todayLocal())) throw ArgumentError('Future dates cannot be recorded');
    await db.upsert(WorkEntry(date: dateKey(d), status: status, note: note));
  }
  Future<WorkEntry?> getForDate(DateTime d) => db.byDate(dateKey(d));
  Future<List<WorkEntry>> getEntries() => db.all();
  Future<void> update(WorkEntry e) => db.upsert(e);
  Future<void> deleteAll() => db.deleteAll();
}
