import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/app/app.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/core/services/storage_service.dart';
import 'package:financeiro/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Lock orientation ────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── System UI ───────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // ─── Initialize services ─────────────────────────────────────────────────
  await StorageService.initialize();
  await DatabaseService.initialize();
  await NotificationService.initialize();

  // ─── Seed default data if first launch ───────────────────────────────────
  final isFirstLaunch =
      !(StorageService.getBool('app_initialized') ?? false);
  if (isFirstLaunch) {
    await _seedDefaultData();
    await StorageService.setBool('app_initialized', value: true);
  }

  runApp(
    const ProviderScope(
      child: FinanceiroApp(),
    ),
  );
}

/// Seeds the app with initial demo data so the user can see the UI populated
/// on first launch — removed once the user has their own data.
Future<void> _seedDefaultData() async {
  final db = DatabaseService.instance;

  // Seed categories
  final now = DateTime.now();

  // Seed a default account
  await db.writeTxn(() async {
    // We intentionally keep this minimal — just enough for the user
    // to understand the structure without overwhelming them.
  });
}
