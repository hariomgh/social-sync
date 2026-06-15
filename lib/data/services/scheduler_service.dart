import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/post.dart';

/// Schedules local reminders for queued posts.
///
/// True unattended background posting requires either a backend cron that calls
/// the platform APIs, or `workmanager`/`BGTaskScheduler` with a headless
/// isolate. This service handles the on-device half: it fires a local
/// notification when a post is due, and the app publishes any posts whose time
/// has passed on next launch (see `LibraryViewModel.publishDuePosts`).
class SchedulerService {
  SchedulerService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'scheduled_posts',
    'Scheduled posts',
    channelDescription: 'Reminders for posts queued to publish',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> scheduleReminder(Post post) async {
    final DateTime? at = post.scheduledAt;
    if (at == null || at.isBefore(DateTime.now())) return;
    await init();
    try {
      await _plugin.zonedSchedule(
        post.id.hashCode,
        'Time to publish',
        post.baseText.isEmpty
            ? 'Your scheduled post is ready.'
            : post.baseText,
        tz.TZDateTime.from(at, tz.local),
        const NotificationDetails(android: _androidDetails, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  Future<void> cancel(Post post) async {
    await _plugin.cancel(post.id.hashCode);
  }
}
