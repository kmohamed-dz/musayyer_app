import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/inventory/presentation/screens/add_edit_product_screen.dart';
import '../../features/inventory/presentation/screens/product_detail_screen.dart';
import '../../features/inventory/presentation/screens/product_list_screen.dart';
import '../../features/invoice/presentation/screens/invoice_detail_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/scanner/presentation/screens/barcode_scan_screen.dart';
import '../di/providers.dart';
import '../storage/storage_keys.dart';
import 'splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(localStorageProvider);

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
      GoRoute(
        path: '/inventory',
        builder: (_, __) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/inventory/add',
        builder: (_, __) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: '/inventory/edit/:id',
        builder: (_, state) => AddEditProductScreen(
          productId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/inventory/:id',
        builder: (_, state) => ProductDetailScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/pos',
        builder: (_, __) => const PosScreen(),
      ),
      GoRoute(
        path: '/invoices/:id',
        builder: (_, state) => InvoiceDetailScreen(
          invoiceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/scanner',
        builder: (_, __) => const BarcodeScanScreen(),
      ),
    ],
    redirect: (_, state) {
      final path = state.matchedLocation;
      final onboardingDone = storage.getBool(StorageKeys.onboardingDone);
      final authToken = storage.getString(StorageKeys.authToken);
      final isAuthenticated = authToken != null && authToken.isNotEmpty;

      if (!onboardingDone) {
        return path == '/onboarding' ? null : '/onboarding';
      }

      if (!isAuthenticated) {
        return path == '/login' ? null : '/login';
      }

      if (path == '/splash' || path == '/onboarding' || path == '/login') {
        return '/home';
      }

      return null;
    },
  );
});
