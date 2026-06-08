import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/models/subscription.dart';
import 'package:subscription_manager/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  test('通知スケジュールが正しく設定されること', () async {
    final mockPlugin = MockFlutterLocalNotificationsPlugin();
    
    // show が呼ばれることを確認するためのモック設定
    when(() => mockPlugin.show(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      notificationDetails: any(named: 'notificationDetails'),
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

    verify(() => mockPlugin.show(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      notificationDetails: any(named: 'notificationDetails'),
    )).called(1);
  });
}
