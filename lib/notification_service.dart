import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// ─── FCM top-level handlers ────────────────────────────────────────────────
// Must be top-level (not inside a class) because FCM calls them in a
// separate Dart isolate.

// Called when a data-only FCM message arrives while the app is in the
// background or terminated. Notification messages are displayed
// automatically by the FCM SDK in that state, so we skip them here to
// avoid showing a duplicate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) return;

  await AwesomeNotifications().initialize(null, [_acilDurumKanali()]);
  _showFcmAsAwesomeNotification(message);
}

// Shared helper used by both the foreground and background FCM handlers.
void _showFcmAsAwesomeNotification(RemoteMessage message) {
  final title = message.notification?.title ?? message.data['title'] ?? 'SafeHome';
  final body  = message.notification?.body  ?? message.data['body']  ?? '';
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: message.hashCode,
      channelKey: 'acil_durum_kanali',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.BigText,
    ),
  );
}

// ─── Shared channel definition ─────────────────────────────────────────────

NotificationChannel _acilDurumKanali() => NotificationChannel(
  channelKey: 'acil_durum_kanali',
  channelName: 'Acil Durum Bildirimleri',
  channelDescription: 'Düşme algılandığında çalan yüksek öncelikli alarm.',
  defaultColor: const Color(0xFF9D0A0E),
  ledColor: Colors.red,
  importance: NotificationImportance.Max,
  criticalAlerts: true,
);

// ─── NotificationService ───────────────────────────────────────────────────

class NotificationService {
  // 1. Bildirim Kanallarını Başlatma
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(null, [_acilDurumKanali()]);
  }

  // 2. İzin İsteme ve FCM Dinleyicilerini Kurma
  static Future<void> requestPermissionsAndSetupFCM() async {
    // POST_NOTIFICATIONS runtime permission (Android 13+ / API 33+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background / terminated handler — must be registered before runApp()
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground handler — FCM does NOT auto-display when the app is open
    FirebaseMessaging.onMessage.listen(_showFcmAsAwesomeNotification);
  }

  // 3. Arka Plan Servisini Başlatma
  static Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'acil_durum_kanali',
        initialNotificationTitle: 'SafeHome Aktif',
        initialNotificationContent: 'Arka planda koruma sağlanıyor...',
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart, onBackground: onIosBackground),
    );
  }
}

// ─── Background service entry point ───────────────────────────────────────

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCx6quwMWto0AKl-UGLrQZDGNAEz_25tkY",
        appId: "1:397421928399:web:c8a341f535f1a5c6bc7cba",
        messagingSenderId: "397421928399",
        projectId: "safehome-web",
        databaseURL: "https://safehome-web-default-rtdb.firebaseio.com",
      ),
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  final db = FirebaseDatabase.instance;

  // Listener 1: Düşme algılama
  db.ref('dusmeDurumu').onValue.listen((event) {
    if (event.snapshot.value == true) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 911,
          channelKey: 'acil_durum_kanali',
          title: '🚨 ACİL DURUM: Düşme Algılandı!',
          body: 'Yakınınız bir düşme yaşadı. Lütfen hemen kontrol edin!',
          notificationLayout: NotificationLayout.BigText,
          backgroundColor: Colors.red,
          criticalAlert: true,
        ),
      );
    }
  });

  // Listener 2: İlaç hatırlatması
  db.ref('ilacUyarisi').onValue.listen((event) {
    if (event.snapshot.value == true) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 555,
          channelKey: 'acil_durum_kanali',
          title: '⏰ SafeHome: İlaç Vakti!',
          body: 'Yakınınızın ilaç alma vakti geldi.',
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    }
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) => true;
