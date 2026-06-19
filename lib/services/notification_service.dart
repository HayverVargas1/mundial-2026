import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse details) {
  if (details.actionId == 'mute_match' && details.payload != null) {
    SharedPreferences.getInstance().then((prefs) {
      final matchId = details.payload!.replaceAll('mute_', '');
      final muted = prefs.getStringList('muted_matches') ?? [];
      if (!muted.contains(matchId)) {
        muted.add(matchId);
        prefs.setStringList('muted_matches', muted);
      }
    });
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
      onDidReceiveNotificationResponse: (details) => _handleNotificationAction(details),
    );
  }

  static void _handleNotificationAction(NotificationResponse details) async {
    if (details.actionId == 'mute_match' && details.payload != null) {
      final prefs = await SharedPreferences.getInstance();
      final matchId = details.payload!.replaceAll('mute_', '');
      final muted = prefs.getStringList('muted_matches') ?? [];
      if (!muted.contains(matchId)) {
        muted.add(matchId);
        await prefs.setStringList('muted_matches', muted);
      }
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true; // Handle other platforms if needed
  }

  Future<void> showMatchNotification({required String title, required String body, String? matchId}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mundial_alerts_channel_2',
      'Alertas del Mundial',
      channelDescription: 'Canal para las alertas de partidos',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
      sound: const RawResourceAndroidNotificationSound('whistle'),
      playSound: true,
      actions: matchId != null ? [
        const AndroidNotificationAction(
          'mute_match', 
          '🔕 Silenciar Partido',
          showsUserInterface: true,
        )
      ] : null,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: matchId != null ? 'mute_$matchId' : null,
    );
  }
}

