import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/main.dart';

void main() {
  testWidgets('Subscription Manager の画面が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Subscription Manager'), findsOneWidget);
  });
}
