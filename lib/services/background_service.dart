import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'polling_service.dart';
import 'notification_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Create notification channel for foreground service
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'mundial_foreground_min', 
    'Servicio Interno', 
    description: 'Proceso interno de sincronización',
    importance: Importance.min, 
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'mundial_foreground_min',
      initialNotificationTitle: 'Sincronizando datos',
      initialNotificationContent: 'Actualizando resultados...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await NotificationService().init();
  
  // Initialize PollingService in this isolate
  // Since we don't have a UI ProviderContainer, we create a new one
  final container = ProviderContainer();
  final pollingService = PollingService();
  await pollingService.start(container);
}
