import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/noir_theme.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';
import '../../services/preferences_service.dart';
import '../../services/work_entries_controller.dart';

/// Minimal settings: Reminders, Export, About. No unnecessary options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.preferencesService,
    required this.notificationService,
  });

  final WorkEntriesController controller;
  final PreferencesService preferencesService;
  final NotificationService notificationService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = false;
  ReminderTime _reminderTime = const ReminderTime(hour: 19, minute: 0);
  bool _loaded = false;
  String? _errorMessage;

  final ExportService _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    final bool enabled = await widget.preferencesService.isReminderEnabled();
    final ReminderTime time = await widget.preferencesService.getReminderTime();
    if (!mounted) return;
    setState(() {
      _reminderEnabled = enabled;
      _reminderTime = time;
      _loaded = true;
    });
  }

  Future<void> _handleReminderToggle(bool value) async {
    if (value) {
      // Permission is requested only now — the moment the user opts in —
      // never during onboarding or app startup.
      final bool granted = await widget.notificationService.requestPermission();
      if (!granted) {
        setState(() {
          _errorMessage = 'Enable notifications for Workday Noir in iOS Settings to use reminders.';
        });
        return;
      }
      await widget.notificationService.scheduleDailyReminder(_reminderTime);
    } else {
      await widget.notificationService.cancelDailyReminder();
    }
    await widget.preferencesService.setReminder(enabled: value);
    if (!mounted) return;
    setState(() {
      _reminderEnabled = value;
      _errorMessage = null;
    });
  }

  Future<void> _pickReminderTime() async {
    final DateTime initial = DateTime(2000, 1, 1, _reminderTime.hour, _reminderTime.minute);
    DateTime selected = initial;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 260,
          color: NoirColors.surfaceRaised,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CupertinoButton(
                    child: Text('Done', style: NoirTypography.body),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initial,
                    onDateTimeChanged: (DateTime value) => selected = value,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    final ReminderTime newTime =
        ReminderTime(hour: selected.hour, minute: selected.minute);
    setState(() => _reminderTime = newTime);
    await widget.preferencesService.setReminder(enabled: _reminderEnabled, time: newTime);
    if (_reminderEnabled) {
      await widget.notificationService.scheduleDailyReminder(newTime);
    }
  }

  Future<void> _handleExport() async {
    try {
      await _exportService.shareExport(widget.controller.groupedByMonth);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar(
          pinned: false,
          floating: true,
          title: Text('Settings'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              const _SectionLabel('REMINDERS'),
              _SettingsCard(
                children: <Widget>[
                  _SettingsRow(
                    label: 'Daily Reminder',
                    trailing: Switch.adaptive(
                      value: _reminderEnabled,
                      onChanged: _handleReminderToggle,
                    ),
                  ),
                  if (_reminderEnabled) ...<Widget>[
                    const _Divider(),
                    _SettingsRow(
                      label: 'Reminder Time',
                      trailing: Text(_reminderTime.formatted, style: NoirTypography.secondary),
                      onTap: _pickReminderTime,
                    ),
                  ],
                ],
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: NoirTypography.caption.copyWith(color: NoirColors.notWorkedAccent),
                ),
              ],
              const SizedBox(height: 28),
              const _SectionLabel('DATA'),
              _SettingsCard(
                children: <Widget>[
                  _SettingsRow(
                    label: 'Export History',
                    trailing: const Icon(Icons.ios_share_rounded, size: 18, color: NoirColors.textSecondary),
                    onTap: _handleExport,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _SectionLabel('ABOUT'),
              _SettingsCard(
                children: <Widget>[
                  _SettingsRow(label: 'Version', trailing: Text('1.0.0', style: NoirTypography.secondary)),
                  const _Divider(),
                  _SettingsRow(
                    label: 'Privacy',
                    trailing: Text('On-device only', style: NoirTypography.secondary),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: NoirTypography.caption.copyWith(letterSpacing: 1)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NoirColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NoirColors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.trailing, this.onTap});
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: NoirTypography.body)),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: NoirColors.hairline);
}
