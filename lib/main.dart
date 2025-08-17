import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/enums.dart' as app_enums;
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const ProviderScope(child: EusebiaApp()));
}

class EusebiaApp extends ConsumerWidget {
  const EusebiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      themeMode: _getFlutterThemeMode(themeMode),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeMode _getFlutterThemeMode(dynamic themeMode) {
    switch (themeMode) {
      case app_enums.ThemeMode.light:
        return ThemeMode.light;
      case app_enums.ThemeMode.dark:
        return ThemeMode.dark;
      case app_enums.ThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}
