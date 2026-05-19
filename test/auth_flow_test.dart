import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscription_manager/main.dart';
import 'package:subscription_manager/providers/subscription_provider.dart';

import 'package:subscription_manager/providers/payment_method_provider.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => Stream.value(AuthState(AuthChangeEvent.initialSession, null)),
    );
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  testWidgets('ログイン画面が正しく表示され、新規登録へ遷移できる', (WidgetTester tester) async {
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

    // 初期ロード待ち
    await tester.pump();

    // ログイン画面の要素を確認
    expect(find.text('ログイン'), findsAtLeastNWidgets(1));
    expect(find.text('メールアドレス'), findsOneWidget);
    expect(find.text('パスワード'), findsOneWidget);

    // 新規登録ボタンをタップ
    final signUpButton = find.text('新規登録はこちら');
    expect(signUpButton, findsOneWidget);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    // 新規登録画面が表示されることを確認
    expect(find.text('新規登録'), findsAtLeastNWidgets(1));
    expect(find.text('登録'), findsOneWidget);
  });

  testWidgets('セッションがある場合、サブスク一覧画面が表示される', (WidgetTester tester) async {
    final mockUser = User(
      id: 'user_id',
      appMetadata: {},
      userMetadata: {},
      aud: 'aud',
      createdAt: DateTime.now().toIso8601String(),
    );
    final mockSession = Session(
      accessToken: 'token',
      tokenType: 'bearer',
      user: mockUser,
    );

    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => Stream.value(AuthState(AuthChangeEvent.signedIn, mockSession)),
    );
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          subscriptionsProvider.overrideWith((ref) => Stream.value([])),
          paymentMethodsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // サブスク管理（一覧画面）が表示されていることを確認
    expect(find.text('サブスク管理'), findsOneWidget);
    expect(find.text('サブスクリプションが登録されていません'), findsOneWidget);
  });
}
