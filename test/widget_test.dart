import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/main.dart';
import 'package:subscription_manager/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscription_manager/providers/subscription_provider.dart';
import 'package:subscription_manager/providers/payment_method_provider.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  testWidgets('ログイン画面が表示される', (WidgetTester tester) async {
    final mockSupabase = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => Stream.value(AuthState(AuthChangeEvent.initialSession, null)),
    );
    when(() => mockAuth.currentUser).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          subscriptionsProvider.overrideWith((ref) => const Stream.empty()),
          paymentMethodsProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MyApp(),
      ),
    );
    
    await tester.pump();
    expect(find.text('ログイン'), findsAtLeastNWidgets(1));
  });

  testWidgets('ログイン画面のバリデーションエラーチェック', (WidgetTester tester) async {
    final mockSupabase = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
        ],
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // 空の状態でログインボタンを押す
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // バリデーションエラーが表示されることを確認
    expect(find.text('メールアドレスを入力してください'), findsOneWidget);
    expect(find.text('パスワードを入力してください'), findsOneWidget);
  });
}
