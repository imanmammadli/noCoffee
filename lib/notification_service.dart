import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'motivation_messages.dart';

/// Schedules one motivational notification per day for the next 30 days.
/// The window is refreshed every time the app opens, so it never runs out
/// as long as the app is used at least once a month.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _firstId = 1000; // motivation ids: 1000..1029
  static const int _daysAhead = 30;
  static const int _hour = 11;
  static const int _minute = 0;
  static const int _testId = 1;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  String get motivationTimeLabel =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  /// Notifications only run on the phone app (not in Chrome / Windows).
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'motivation',
      'Motivation',
      channelDescription: 'Daily motivational messages',
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Call once at startup. Returns true if motivation notifications are
  /// already scheduled (and tops the schedule up for another 30 days).
  Future<bool> init() async {
    if (!supported) return false;
    try {
      tz_data.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        // Falls back to UTC if the device timezone can't be read.
      }
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings: settings);
      if (await isMotivationScheduled()) {
        await scheduleMotivation();
        return true;
      }
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
    return false;
  }

  Future<bool> requestPermission() async {
    if (!supported) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  Future<bool> isMotivationScheduled() async {
    if (!supported) return false;
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((p) => p.id >= _firstId && p.id < _firstId + _daysAhead);
  }

  Future<void> scheduleMotivation() async {
    if (!supported) return;
    await cancelMotivation();

    final now = tz.TZDateTime.now(tz.local);
    var start = tz.TZDateTime(tz.local, now.year, now.month, now.day, _hour, _minute);
    if (!start.isAfter(now)) {
      start = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, _hour, _minute);
    }

    for (var i = 0; i < _daysAhead; i++) {
      final when = tz.TZDateTime(tz.local, start.year, start.month, start.day + i, _hour, _minute);
      // 17 and 50 are coprime, so 50 consecutive days never repeat a message,
      // and a given calendar date always gets the same message.
      final dayNumber = DateTime.utc(when.year, when.month, when.day)
              .millisecondsSinceEpoch ~/
          86400000;
      final message = kMotivationMessages[(dayNumber * 17) % kMotivationMessages.length];

      await _plugin.zonedSchedule(
        id: _firstId + i,
        title: 'Taper',
        body: message,
        scheduledDate: when,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelMotivation() async {
    if (!supported) return;
    for (var i = 0; i < _daysAhead; i++) {
      await _plugin.cancel(id: _firstId + i);
    }
  }

  /// Shows a notification immediately, to verify permission/channel/icon.
  Future<void> showTest() async {
    if (!supported) return;
    final message = kMotivationMessages[DateTime.now().second % kMotivationMessages.length];
    await _plugin.show(
      id: _testId,
      title: 'Taper',
      body: message,
      notificationDetails: _details,
    );
  }
}