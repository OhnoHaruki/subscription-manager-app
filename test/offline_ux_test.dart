import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscription_manager/providers/subscription_provider.dart';
import 'package:subscription_manager/repositories/subscription_repository.dart';
import 'package:subscription_manager/widgets/common_views.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  testWidgets('ネットワークエラー時にErrorViewが表示され、再試行が可能', (WidgetTester tester) async {
    final mockRepo = MockSubscriptionRepository();
    
    // エラーを投げるように設定
    when(() => mockRepo.watchSubscriptions()).thenAnswer(
      (_) => Stream.error(Exception('Network Error')),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(builder: (context, ref, _) {
              final asyncValue = ref.watch(subscriptionsProvider);
              return asyncValue.when(
                data: (_) => const Text('Success'),
                loading: () => const LoadingView(),
                error: (e, _) => ErrorView(
                  message: '読み込みに失敗しました',
                  onRetry: () => ref.invalidate(subscriptionsProvider),
                ),
              );
            }),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // エラー表示の確認
    expect(find.text('読み込みに失敗しました'), findsOneWidget);
    expect(find.text('再試行'), findsOneWidget);

    // 再試行の設定を成功に変更
    when(() => mockRepo.watchSubscriptions()).thenAnswer(
      (_) => Stream.value([]),
    );

    // 再試行ボタンをタップ
    await tester.tap(find.text('再試行'));
    await tester.pumpAndSettle();

    // 成功状態（EmptyViewになる）の確認
    expect(find.text('読み込みに失敗しました'), findsNothing);
  });
}
