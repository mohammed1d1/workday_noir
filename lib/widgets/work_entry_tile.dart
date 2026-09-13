import 'package:flutter/material.dart';

import '../app/theme/noir_theme.dart';
import '../models/work_entry.dart';

/// A single row in the History screen: compact date on the left, status
/// indicator on the right. Tapping toggles the entry's status in place —
/// this is how requirement "Editing Existing Days" is satisfied, without
/// a separate edit screen.
class WorkEntryTile extends StatelessWidget {
  const WorkEntryTile({super.key, required this.entry, required this.onToggle});

  final WorkEntry entry;
  final ValueChanged<bool> onToggle;

  String get _compactDate => '${entry.date.day}/${entry.date.month}';

  String get _weekday {
    const List<String> names = <String>[
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return names[entry.date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = entry.worked
        ? NoirColors.workedAccent
        : NoirColors.notWorkedAccent;

    return Semantics(
      button: true,
      label:
          '${entry.worked ? 'Worked' : 'Did not work'} on $_compactDate. Double tap to change.',
      child: InkWell(
        onTap: () => onToggle(!entry.worked),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 52,
                child: Text(_compactDate, style: NoirTypography.body),
              ),
              Expanded(
                child: Text(_weekday, style: NoirTypography.caption),
              ),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.14),
                ),
                child: Icon(
                  entry.worked ? Icons.check_rounded : Icons.close_rounded,
                  size: 16,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
