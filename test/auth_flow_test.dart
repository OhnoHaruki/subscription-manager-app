import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscription_manager/screens/sign_up_screen.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  testWidgets('新規登録画面が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignUpScreen()),
      ),
    );

    // 新規登録画面が表示されることを確認
    expect(find.text('アカウント作成'), findsOneWidget);
  });
}
