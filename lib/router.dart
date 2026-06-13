import 'package:go_router/go_router.dart';
import 'screens/subscription_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart'; // 仮に存在すると想定
import 'providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading) return null;
      
      final isLoggedIn = authState.value?.session != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignUp = state.matchedLocation == '/sign-up';

      if (!isLoggedIn && !isGoingToLogin && !isGoingToSignUp) return '/login';
      if (isLoggedIn && (isGoingToLogin || isGoingToSignUp)) return '/';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SubscriptionListScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
  );
});
