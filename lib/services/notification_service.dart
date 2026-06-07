import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// サブスクの支払い通知をスケジュールする
  Future<void> scheduleSubscriptionNotification(Subscription subscription) async {
    // 次回支払日の3日前（または当日）に設定
    final scheduledDate = tz.TZDateTime.from(
      subscription.nextPaymentDate.subtract(const Duration(days: 3)),
      tz.local,
    );

    await _notificationsPlugin.zonedSchedule(
      subscription.id.hashCode,
      'お支払いリマインダー',
      '${subscription.name} の支払い予定日が近づいています。',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_channel',
          'Subscription Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
