import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/models/subscription.dart';
import 'package:subscription_manager/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  test('通知スケジュールが正しく設定されること', () async {
    final mockPlugin = MockFlutterLocalNotificationsPlugin();
    
    // zonedSchedule が呼ばれることを確認するためのモック設定
    when(() => mockPlugin.zonedSchedule(
      any(), any(), any(), any(), any(),
      uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
      androidScheduleMode: any(named: 'androidScheduleMode'),
    )).thenAnswer((_) => Future.value());

    final service = NotificationService(plugin: mockPlugin);
    final subscription = Subscription(
      id: '1',
      name: 'Test Sub',
      amount: 1000,
      cycle: BillingCycle.monthly,
      nextPaymentDate: DateTime.now().add(const Duration(days: 10)),
      tags: [],
    );

    await service.scheduleSubscriptionNotification(subscription);

    verify(() => mockPlugin.zonedSchedule(
      any(), any(), any(), any(), any(),
      uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
      androidScheduleMode: any(named: 'androidScheduleMode'),
    )).called(1);
  });
}
