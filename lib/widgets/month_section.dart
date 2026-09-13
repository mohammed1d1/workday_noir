import 'package:flutter/material.dart';

import '../app/theme/noir_theme.dart';
import '../models/work_entry.dart';
import '../services/export_service.dart';
import 'work_entry_tile.dart';

/// Renders one month's header, entries (most recent day first for
/// on-screen scanning), and total-worked-days summary.
class MonthSection extends StatelessWidget {
  const MonthSection({
    super.key,
    required this.group,
    required this.onToggleEntry,
  });

  final MonthGroup group;
  final void Function(DateTime date, bool worked) onToggleEntry;

  @override
  Widget build(BuildContext context) {
    // Show newest-first on screen, even though the underlying group is
    // stored ascending (which export uses).
    final List<WorkEntry> reversedEntries = group.entries.reversed.toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(group.title, style: NoirTypography.title),
          const SizedBox(height: 12),
          ...reversedEntries.map((WorkEntry entry) {
            return WorkEntryTile(
              entry: entry,
              onToggle: (bool worked) => onToggleEntry(entry.date, worked),
            );
          }),
          const SizedBox(height: 8),
          Container(height: 1, color: NoirColors.hairline),
          const SizedBox(height: 12),
          Text(
            'Total worked days: ${group.totalWorkedDays}',
            style: NoirTypography.secondary,
          ),
        ],
      ),
    );
  }
}
