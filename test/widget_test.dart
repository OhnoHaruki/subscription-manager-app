import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_manager/main.dart';

void main() {
  testWidgets('Subscription Manager の画面が表示される', (WidgetTester tester) async {
    // ProviderScope でラップしてウィジェットをビルド
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    
    // MaterialApp が存在することを確認
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
