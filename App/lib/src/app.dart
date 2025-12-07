import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelpop/l10n/app_localizations.dart';
import 'package:novelpop/src/app/app_theme.dart';
import 'package:novelpop/src/routing/app_router.dart';
import 'package:novelpop/src/features/settings/data/theme_provider.dart';
import 'package:novelpop/src/features/settings/data/locale_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    // 根据主题模式确定实际的亮度
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveThemeMode = themeMode.value ?? ThemeMode.system;
    final isDark = effectiveThemeMode == ThemeMode.dark ||
        (effectiveThemeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    // 根据主题动态设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.value ?? ThemeMode.system,
      locale: locale.value, // Force the selected locale
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
