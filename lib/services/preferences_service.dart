import 'package:shared_preferences/shared_preferences.dart';

/// Small wrapper around [SharedPreferences] for the handful of simple
/// flags/settings the app needs. Kept separate from [StorageService]
/// (work records) because these are lightweight key/value settings, not
/// domain data.
class PreferencesService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';

  Future<bool> isOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  Future<bool> isReminderEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReminderEnabled) ?? false;
  }

  /// Default reminder time: 7:00 PM, matching the example in the settings
  /// spec. Only used the first time a reminder is enabled.
  Future<ReminderTime> getReminderTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int hour = prefs.getInt(_keyReminderHour) ?? 19;
    final int minute = prefs.getInt(_keyReminderMinute) ?? 0;
    return ReminderTime(hour: hour, minute: minute);
  }

  Future<void> setReminder({required bool enabled, ReminderTime? time}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, enabled);
    if (time != null) {
      await prefs.setInt(_keyReminderHour, time.hour);
      await prefs.setInt(_keyReminderMinute, time.minute);
    }
  }
}

/// A simple time-of-day value, independent of Flutter's Material
/// [TimeOfDay] so this service has no UI-layer dependency.
class ReminderTime {
  const ReminderTime({required this.hour, required this.minute});

  final int hour;
  final int minute;

  String get formatted {
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final String minutePadded = minute.toString().padLeft(2, '0');
    return '$displayHour:$minutePadded $period';
  }
}
