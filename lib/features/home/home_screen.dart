import 'package:flutter/material.dart';

import '../../app/theme/noir_theme.dart';
import '../../models/work_entry.dart';
import '../../services/work_entries_controller.dart';
import '../../widgets/work_status_button.dart';

/// The main screen: "Did you work today?" with YES/NO. Shows today's
/// current status immediately if it's already been recorded, and lets the
/// user change their mind without ever creating a duplicate entry.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final WorkEntriesController controller;

  static const List<String> _weekdayNames = <String>[
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _monthNames = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String get _todayLabel {
    final DateTime now = DateTime.now();
    return '${_weekdayNames[now.weekday - 1]}, ${_monthNames[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final WorkEntry? today = controller.todayEntry;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _todayLabel,
                style: NoirTypography.caption,
              ),
              const SizedBox(height: 20),
              const Text(
                'Did you work today?',
                textAlign: TextAlign.center,
                style: NoirTypography.largeTitle,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  WorkStatusButton(
                    choice: WorkStatusChoice.yes,
                    selected: today?.worked == true,
                    onTap: () => controller.setToday(worked: true),
                  ),
                  const SizedBox(width: 16),
                  WorkStatusButton(
                    choice: WorkStatusChoice.no,
                    selected: today != null && !today.worked,
                    onTap: () => controller.setToday(worked: false),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: today == null
                    ? const SizedBox(key: ValueKey<String>('empty'), height: 20)
                    : Text(
                        'Saved',
                        key: const ValueKey<String>('saved'),
                        style: NoirTypography.secondary,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
