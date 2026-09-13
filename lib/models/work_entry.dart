/// A single day's work record.
///
/// [date] is always normalized to midnight, local time, with no time
/// component — the app tracks calendar days, not timestamps. Normalizing
/// on construction is what lets the storage layer reliably detect and
/// prevent duplicate entries for the same day.
class WorkEntry {
  WorkEntry({required DateTime date, required this.worked})
      : date = _normalize(date);

  final DateTime date;
  final bool worked;

  /// Strips time-of-day so two DateTimes on the same calendar day are
  /// always equal after normalization, regardless of when they were
  /// created.
  static DateTime _normalize(DateTime input) {
    return DateTime(input.year, input.month, input.day);
  }

  /// Stable, sortable, timezone-free key for this entry's day.
  /// Used both as the SQLite primary key and for equality/grouping.
  String get dateKey => WorkEntry.keyForDate(date);

  static String keyForDate(DateTime date) {
    final DateTime d = _normalize(date);
    final String y = d.year.toString().padLeft(4, '0');
    final String m = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Key identifying which month/year section this entry belongs to.
  String get monthKey =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  WorkEntry copyWith({DateTime? date, bool? worked}) {
    return WorkEntry(
      date: date ?? this.date,
      worked: worked ?? this.worked,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'date_key': dateKey,
      'worked': worked ? 1 : 0,
    };
  }

  factory WorkEntry.fromMap(Map<String, Object?> map) {
    final String key = map['date_key']! as String;
    final List<String> parts = key.split('-');
    final DateTime date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return WorkEntry(
      date: date,
      worked: (map['worked']! as int) == 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkEntry && other.dateKey == dateKey && other.worked == worked;
  }

  @override
  int get hashCode => Object.hash(dateKey, worked);

  @override
  String toString() => 'WorkEntry($dateKey, worked: $worked)';
}
