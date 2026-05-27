import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:subscription_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Integration Test', () {
    testWidgets('Verify login screen and navigation to sign up',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ログイン画面が表示されていることを確認
      expect(find.text('ログイン'), findsAtLeastNWidgets(1));
      expect(find.text('メールアドレス'), findsOneWidget);
      expect(find.text('パスワード'), findsOneWidget);

      // 新規登録画面への遷移を確認
      final signUpButton = find.text('新規登録はこちら');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(find.text('新規登録'), findsAtLeastNWidgets(1));
      expect(find.text('登録'), findsOneWidget);
    });
  });
}
