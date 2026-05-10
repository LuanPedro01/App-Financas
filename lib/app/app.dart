import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:financeiro/app/router/app_router.dart';
import 'package:financeiro/features/settings/providers/settings_provider.dart';
import 'package:financeiro/core/constants/app_constants.dart';

class FinanceiroApp extends ConsumerWidget {
  const FinanceiroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeData = ref.watch(appThemeDataProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ─── Router ─────────────────────────────────────────────────────
      routerConfig: router,

      // ─── Theme ──────────────────────────────────────────────────────
      theme: themeData.light,
      darkTheme: themeData.dark,
      themeMode: themeMode,

      // ─── Localization ────────────────────────────────────────────────
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── Responsive Framework ─────────────────────────────────────────
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
        ],
      ),
    );
  }
}
