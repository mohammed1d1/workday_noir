import 'dart:async';

import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../services/notification_service.dart';
import '../services/preferences_service.dart';
import '../services/storage_service.dart';
import '../services/work_entries_controller.dart';
import 'routing/app_shell.dart';
import 'theme/noir_theme.dart';

/// Root widget. Decides once, at launch, whether to show onboarding or go
/// straight to the app shell — matching requirement: onboarding only
/// appears the first time, gated by a locally stored flag.
class WorkdayNoirApp extends StatefulWidget {
  const WorkdayNoirApp({super.key});

  @override
  State<WorkdayNoirApp> createState() => _WorkdayNoirAppState();
}

class _WorkdayNoirAppState extends State<WorkdayNoirApp> {
  late final StorageService _storageService = StorageService();
  late final PreferencesService _preferencesService = PreferencesService();
  late final NotificationService _notificationService = NotificationService();
  late final WorkEntriesController _controller =
      WorkEntriesController(storageService: _storageService);

  /// null while we haven't yet checked the stored flag, true/false after.
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    // The work-entries load and the onboarding-flag read both run without
    // blocking the first frame — each screen renders its own empty/loading
    // state instead of the whole app waiting behind a splash screen.
    unawaited(_controller.load());
    unawaited(_loadOnboardingFlag());
  }

  Future<void> _loadOnboardingFlag() async {
    final bool complete = await _preferencesService.isOnboardingComplete();
    if (!mounted) return;
    setState(() => _onboardingComplete = complete);
  }

  Future<void> _completeOnboarding() async {
    await _preferencesService.setOnboardingComplete();
    if (!mounted) return;
    setState(() => _onboardingComplete = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(_storageService.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget home;
    if (_onboardingComplete == null) {
      home = const ColoredBox(color: NoirColors.background);
    } else if (_onboardingComplete == false) {
      home = OnboardingScreen(onComplete: _completeOnboarding);
    } else {
      home = AppShell(
        controller: _controller,
        preferencesService: _preferencesService,
        notificationService: _notificationService,
      );
    }

    return MaterialApp(
      title: 'Workday Noir',
      debugShowCheckedModeBanner: false,
      theme: buildNoirTheme(),
      darkTheme: buildNoirTheme(),
      themeMode: ThemeMode.dark,
      home: home,
    );
  }
}
