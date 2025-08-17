import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routing/app_router.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'core/constants/enums.dart' as app_enums;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ProviderScope(child: EusebiaApp()));
}

class EusebiaApp extends ConsumerWidget {
  const EusebiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Eusebia',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      // Reactive theme controlled by settings
      themeMode: ref.watch(
        settingsProvider.select((s) {
          final customTheme = s.value?.themeMode ?? app_enums.ThemeMode.system;
          switch (customTheme) {
            case app_enums.ThemeMode.light:
              return ThemeMode.light;
            case app_enums.ThemeMode.dark:
              return ThemeMode.dark;
            case app_enums.ThemeMode.system:
              return ThemeMode.system;
          }
        }),
      ),
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
    );
  }

  ThemeData _buildTheme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
    ),
    useMaterial3: true,
  );
}
