import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/services/widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('WidgetService.updateWidgetData が正しいメソッドを呼ぶこと', () async {
    final List<MethodCall> log = <MethodCall>[];
    
    // Channel をモック化
    const MethodChannel('home_widget').setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });

    await WidgetService.updateWidgetData(
      totalAmount: 5000,
      nextPaymentName: 'Netflix',
      nextPaymentDate: '2026-07-01',
    );

    // saveWidgetData と updateWidget が呼ばれたか確認（正確にはそれぞれ複数回呼ばれる）
    expect(log.any((call) => call.method == 'saveWidgetData'), isTrue);
    expect(log.any((call) => call.method == 'updateWidget'), isTrue);
  });
}
