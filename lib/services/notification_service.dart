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
    // TODO: zonedScheduleのAPIが変更されたため、適切な実装を再調査する
    // 現在は通知機能の実装基盤のみとする
  }
}
