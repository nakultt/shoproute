import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Import pages (will be created)
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/product/presentation/pages/category_products_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../features/saved/presentation/pages/saved_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/pantry/presentation/pages/pantry_page.dart';
import '../../core/widgets/main_scaffold.dart';

/// Route names for navigation
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String aiAssistant = '/ai';
  static const String saved = '/saved';
  static const String map = '/map';
  static const String settings = '/settings';
  static const String pantry = '/pantry';

  static const String profile = '/profile';
  static const String productDetail = '/product/:id';
  static const String categoryProducts = '/category/:id';
  static const String storeDetail = '/store/:id';
  static const String cart = '/cart';
  static const String search = '/search';
}

/// App Router Configuration
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey =
      GlobalKey<
        NavigatorState
      >();
  static final _shellNavigatorKey =
      GlobalKey<
        NavigatorState
      >();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder:
            (
              context,
              state,
            ) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder:
            (
              context,
              state,
            ) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder:
            (
              context,
              state,
            ) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder:
            (
              context,
              state,
            ) {
              final email =
                  state.extra
                      as String? ??
                  '';
              return VerifyEmailPage(
                email: email,
              );
            },
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder:
            (
              context,
              state,
              child,
            ) => MainScaffold(
              child: child,
            ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder:
                (
                  context,
                  state,
                ) => const NoTransitionPage(
                  child: HomePage(),
                ),
          ),
          GoRoute(
            path: AppRoutes.aiAssistant,
            pageBuilder:
                (
                  context,
                  state,
                ) => const NoTransitionPage(
                  child: AiAssistantPage(),
                ),
          ),
          GoRoute(
            path: AppRoutes.saved,
            pageBuilder:
                (
                  context,
                  state,
                ) => const NoTransitionPage(
                  child: SavedPage(),
                ),
          ),
          GoRoute(
            path: AppRoutes.map,
            pageBuilder:
                (
                  context,
                  state,
                ) => const NoTransitionPage(
                  child: MapPage(),
                ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder:
                (
                  context,
                  state,
                ) => const NoTransitionPage(
                  child: SettingsPage(),
                ),
          ),
        ],
      ),

      // Detail Routes (outside shell for full screen)
      GoRoute(
        path: AppRoutes.productDetail,
        builder:
            (
              context,
              state,
            ) {
              final id =
                  int.tryParse(
                    state.pathParameters['id'] ??
                        '',
                  ) ??
                  0;
              return ProductDetailPage(
                productId: id,
              );
            },
      ),
      GoRoute(
        path: AppRoutes.categoryProducts,
        builder:
            (
              context,
              state,
            ) {
              final id =
                  int.tryParse(
                    state.pathParameters['id'] ??
                        '',
                  ) ??
                  0;
              final name =
                  state.extra
                      as String? ??
                  'Products';
              return CategoryProductsPage(
                categoryId: id,
                categoryName: name,
              );
            },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder:
            (
              context,
              state,
            ) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder:
            (
              context,
              state,
            ) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder:
            (
              context,
              state,
            ) {
              final query =
                  state.extra
                      as String?;
              return SearchPage(
                initialQuery: query,
              );
            },
      ),
      GoRoute(
        path: AppRoutes.pantry,
        builder:
            (
              context,
              state,
            ) => const PantryPage(),
      ),
    ],
    errorBuilder:
        (
          context,
          state,
        ) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Page not found: ${state.uri.path}',
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () => context.go(
                    AppRoutes.home,
                  ),
                  child: const Text(
                    'Go Home',
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}
