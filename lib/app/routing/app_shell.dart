import 'package:flutter/material.dart';

import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../services/notification_service.dart';
import '../../services/preferences_service.dart';
import '../../services/work_entries_controller.dart';
import '../theme/noir_theme.dart';

/// Root three-tab shell: Home, History, Settings. A single bottom
/// navigation bar, styled minimally — no large nav bars, no extra chrome.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.controller,
    required this.preferencesService,
    required this.notificationService,
  });

  final WorkEntriesController controller;
  final PreferencesService preferencesService;
  final NotificationService notificationService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      HomeScreen(controller: widget.controller),
      HistoryScreen(controller: widget.controller),
      SettingsScreen(
        controller: widget.controller,
        preferencesService: widget.preferencesService,
        notificationService: widget.notificationService,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: screens)),
      bottomNavigationBar: _NoirTabBar(
        currentIndex: _index,
        onTap: (int i) => setState(() => _index = i),
      ),
    );
  }
}

class _NoirTabBar extends StatelessWidget {
  const _NoirTabBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<(IconData, String)> _items = <(IconData, String)>[
    (Icons.circle_outlined, 'Home'),
    (Icons.event_note_outlined, 'History'),
    (Icons.tune_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: NoirColors.background,
        border: Border(top: BorderSide(color: NoirColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List<Widget>.generate(_items.length, (int i) {
              final bool selected = i == currentIndex;
              final (IconData icon, String label) = _items[i];
              final Color color =
                  selected ? NoirColors.textPrimary : NoirColors.textTertiary;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: label,
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(icon, size: 22, color: color),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: NoirTypography.caption.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
