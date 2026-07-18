import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reminder_orchestrator.dart';

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return NotificationService();
});

abstract class ReminderScheduler {
  Future<void> schedule(int hour, int minute);
  Future<void> cancel();
}

class NotificationService implements ReminderScheduler {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = MethodChannel('com.smartgym.gym_app/timezone');

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final String? timeZoneName = await _channel.invokeMethod<String>('getLocalTimezone');
      if (timeZoneName != null) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      }
    } catch (_) {
      // Fallback to Vietnam timezone
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      } catch (_) {
        // Fallback to UTC if even Asia/Ho_Chi_Minh is not found (unlikely)
        tz.setLocalLocation(tz.UTC);
      }
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    await _configureLocalTimeZone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(
      settings: initSettings,
    );

    // Create Android channel
    const androidChannel = AndroidNotificationChannel(
      'workout_reminders',
      'Nhắc nhở tập luyện',
      description: 'Kênh nhắc nhở lịch tập hàng ngày',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await init();
    final isAndroidGranted = await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false;
    final isIosGranted = await _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
    return isAndroidGranted || isIosGranted;
  }

  @override
  Future<void> schedule(int hour, int minute) async {
    await init();
    // Cancel previous reminder first
    await cancel();

    final now = tz.TZDateTime.now(tz.local);
    final next = nextReminderOccurrence(now, hour, minute);

    const androidDetails = AndroidNotificationDetails(
      'workout_reminders',
      'Nhắc nhở tập luyện',
      channelDescription: 'Kênh nhắc nhở lịch tập hàng ngày',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Zoned schedule repeating daily
    await _plugin.zonedSchedule(
      id: 1001,
      title: 'Thời gian tập luyện!',
      body: 'Đã đến lúc bắt đầu bài tập hôm nay của bạn.',
      scheduledDate: next,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() async {
    await init();
    await _plugin.cancel(id: 1001);
  }
}
