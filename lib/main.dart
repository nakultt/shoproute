import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';

void
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ShopRouteApp(),
  );
}

/// ShopRoute - Smart Shopping Route Optimizer App
class ShopRouteApp
    extends
        StatelessWidget {
  const ShopRouteApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp.router(
      title: 'ShopRoute',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: AppRouter.router,

      // Builder for global settings
      builder:
          (
            context,
            child,
          ) {
            return MediaQuery(
              // Prevent text scaling beyond reasonable limits
              data:
                  MediaQuery.of(
                    context,
                  ).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(
                            context,
                          ).textScaler
                          .scale(
                            1.0,
                          )
                          .clamp(
                            0.8,
                            1.2,
                          ),
                    ),
                  ),
              child: child!,
            );
          },
    );
  }
}
