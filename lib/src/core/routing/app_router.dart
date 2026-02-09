import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_controller.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import 'splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final onboardingComplete = ref.watch(onboardingControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final location = state.uri.toString();
      final isOnboarding = location == '/onboarding';
      final isLogin = location == '/login';
      final isSplash = location == '/splash';

      if (!onboardingComplete) {
        return isOnboarding ? null : '/onboarding';
      }

      if (authState.status == AuthStatus.unknown ||
          authState.status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      if (authState.status == AuthStatus.authenticated) {
        return (isLogin || isOnboarding || isSplash) ? '/home' : null;
      }

      if (authState.status == AuthStatus.unauthenticated) {
        return isLogin ? null : '/login';
      }

      return null;
    },
  );
});
