import 'package:share_plus/share_plus.dart';

import '../models/work_entry.dart';

const List<String> _monthNames = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Builds the plain-text export of the user's work history and hands it
/// off to the native iOS Share Sheet.
class ExportService {
  /// Renders [entriesByMonth] (already grouped, most-recent-month-first,
  /// each list ascending by date) into the app's export text format.
  String buildExportText(List<MonthGroup> entriesByMonth) {
    final StringBuffer buffer = StringBuffer('Workday Noir\n\n');

    for (int i = 0; i < entriesByMonth.length; i++) {
      final MonthGroup group = entriesByMonth[i];
      buffer.writeln('${_monthNames[group.month - 1]} ${group.year}');
      buffer.writeln();
      for (final WorkEntry entry in group.entries) {
        final String compactDate = '${entry.date.day}/${entry.date.month}';
        final String mark = entry.worked ? '✅' : '❌';
        buffer.writeln('$compactDate $mark');
      }
      buffer.writeln();
      final int total = group.entries.where((WorkEntry e) => e.worked).length;
      buffer.writeln('Total worked days: $total');
      if (i != entriesByMonth.length - 1) {
        buffer.writeln();
        buffer.writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  /// Opens the native iOS Share Sheet with the exported history text.
  Future<void> shareExport(List<MonthGroup> entriesByMonth) async {
    final String text = buildExportText(entriesByMonth);
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Workday Noir — Work History'),
    );
  }
}

/// A single month's entries, ready for display or export.
class MonthGroup {
  MonthGroup({required this.year, required this.month, required this.entries});

  final int year;
  final int month;

  /// Ascending by date within the month.
  final List<WorkEntry> entries;

  int get totalWorkedDays => entries.where((WorkEntry e) => e.worked).length;

  String get title => '${_monthNames[month - 1]} $year';
}
