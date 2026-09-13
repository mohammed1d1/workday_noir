enum WorkStatus { worked, didNotWork }

class WorkEntry {
  final int? id;
  final String date; // YYYY-MM-DD local calendar date
  final WorkStatus status;
  final String? note;
  WorkEntry({this.id, required this.date, required this.status, this.note});
  WorkEntry copyWith({int? id, String? date, WorkStatus? status, String? note}) => WorkEntry(id: id ?? this.id, date: date ?? this.date, status: status ?? this.status, note: note ?? this.note);
  Map<String, Object?> toMap() => {'id': id, 'date': date, 'status': status.name, 'note': note};
  factory WorkEntry.fromMap(Map<String,Object?> m) => WorkEntry(id: m['id'] as int?, date: m['date'] as String, status: WorkStatus.values.byName(m['status'] as String), note: m['note'] as String?);
}
