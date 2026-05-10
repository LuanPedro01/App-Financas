import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:financeiro/core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    await _createChannels();
  }

  static Future<void> _createChannels() async {
    const dueDatesChannel = AndroidNotificationChannel(
      AppConstants.notifChannelDue,
      'Vencimentos',
      description: 'Lembretes de vencimento de contas e faturas',
      importance: Importance.high,
    );

    const budgetChannel = AndroidNotificationChannel(
      AppConstants.notifChannelBudget,
      'Orçamento',
      description: 'Alertas de limite de orçamento',
      importance: Importance.defaultImportance,
    );

    const goalsChannel = AndroidNotificationChannel(
      AppConstants.notifChannelGoals,
      'Metas',
      description: 'Progresso e conquistas de metas financeiras',
      importance: Importance.low,
    );

    const remindersChannel = AndroidNotificationChannel(
      AppConstants.notifChannelReminders,
      'Lembretes',
      description: 'Lembretes financeiros personalizados',
      importance: Importance.defaultImportance,
    );

    const generalChannel = AndroidNotificationChannel(
      AppConstants.notifChannelGeneral,
      'Geral',
      description: 'Notificações gerais do Financeiro',
      importance: Importance.low,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(dueDatesChannel);
      await androidPlugin.createNotificationChannel(budgetChannel);
      await androidPlugin.createNotificationChannel(goalsChannel);
      await androidPlugin.createNotificationChannel(remindersChannel);
      await androidPlugin.createNotificationChannel(generalChannel);
    }
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final result = await android?.requestNotificationsPermission();
    return result ?? false;
  }

  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String channelId = AppConstants.notifChannelGeneral,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  static Future<void> scheduleDueDate({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final scheduled = tz.TZDateTime.from(scheduledDate, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notifChannelDue,
          'Vencimentos',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);
  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() => _plugin.pendingNotificationRequests();
}
