import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onTapNotification,
    );
  }

  void _onTapNotification(NotificationResponse response) {
    print('📢 Notification tapped! ${response.payload}');
  }

  /// **📌 جدولة إشعار واحد بناءً على التاريخ والوقت المحددين**
  Future<void> scheduleNotification(
    int id,
    DateTime scheduledDate,
    String title,
    String note,
  ) async {
    tz.initializeTimeZones();

    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    if (scheduledTZDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print("❌ التاريخ المحدد قديم، سيتم تخطيه.");
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notification',
          channelDescription:
              'This channel is used for scheduled notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // استخدم ID مختلف لكل إشعار
      title,
      note,
      scheduledTZDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'item_x',
    );

    print("✅ تم جدولة الإشعار رقم $id في ${scheduledDate.toString()}");
  }

  /// **📌 جدولة إشعارات متعددة بناءً على قائمة من التواريخ والأوقات**
  Future<void> scheduleMultipleNotifications(List<DateTime> dates) async {
    tz.initializeTimeZones();

    for (int i = 0; i < dates.length; i++) {
      final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
        dates[i],
        tz.local,
      );

      if (scheduledTZDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        print("❌ التاريخ المحدد رقم ${i + 1} قديم، سيتم تخطيه.");
        continue;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        i + 1, // ID مختلف لكل إشعار
        'إشعار رقم ${i + 1}',
        'هذا هو الإشعار المجدول ليوم ${dates[i]}',
        scheduledTZDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_channel',
            'Scheduled Notification',
            channelDescription:
                'This channel is used for scheduled notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'item_x',
      );

      print("✅ تم جدولة الإشعار رقم ${i + 1} في ${dates[i]}");
    }
  }
}
