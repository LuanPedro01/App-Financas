import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/app/app.dart';
import 'package:financeiro/core/services/database_service.dart';
import 'package:financeiro/core/services/storage_service.dart';
import 'package:financeiro/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

  await StorageService.initialize();
  await DatabaseService.initialize();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: FinanceiroApp(),
    ),
  );
}
