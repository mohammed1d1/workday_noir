import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'preferences_service.dart';

/// Wraps `flutter_local_notifications` to provide a single daily reminder:
/// "Did you work today?" — entirely on-device, no server, no account.
///
/// Permission is only ever requested when the user explicitly turns the
/// reminder on from Settings (see requirement: don't ask for unnecessary
/// permissions during onboarding or app start).
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const int _dailyReminderId = 1001;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final String deviceTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimeZone));
    } catch (_) {
      // If the device's IANA name can't be resolved for any reason, fall
      // back to UTC rather than failing reminder setup entirely. The user
      // can still see and adjust the reminder time in Settings.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      // Permissions are requested explicitly via [requestPermission], not
      // automatically on init, so we never prompt before the user opts in.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings settings = InitializationSettings(iOS: iosSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Requests iOS notification permission. Returns true if granted.
  /// Only call this in direct response to the user enabling reminders.
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final bool? granted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }

  /// Schedules (or reschedules) the daily reminder for [time], repeating
  /// every day at that local wall-clock time.
  Future<void> scheduleDailyReminder(ReminderTime time) async {
    await _ensureInitialized();
    await _plugin.cancel(_dailyReminderId);

    final tz.TZDateTime firstFireTime = _nextInstanceOf(time);

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(iOS: iosDetails);

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Workday Noir',
      'Did you work today?',
      firstFireTime,
      details,
      // The plugin's zonedSchedule API is cross-platform and requires this
      // even though NotificationDetails above only configures iOS — there
      // is no Android build target for this app.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _ensureInitialized();
    await _plugin.cancel(_dailyReminderId);
  }

  tz.TZDateTime _nextInstanceOf(ReminderTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
