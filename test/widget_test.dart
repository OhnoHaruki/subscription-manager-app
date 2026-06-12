import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscription_manager/main.dart';
import 'package:subscription_manager/providers/subscription_provider.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  testWidgets('Subscription Manager の画面が表示される', (WidgetTester tester) async {
    final mockSupabase = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockAuth.currentUser).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
        ],
        child: const MyApp(),
      ),
    );
    
    // ロード状態を確認
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
