import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class NotificationService {
  // 1. Bildirim Kanallarını Başlatma
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // Varsayılan ikon kullanır
      [
        NotificationChannel(
          channelKey: 'acil_durum_kanali',
          channelName: 'Acil Durum Bildirimleri',
          channelDescription: 'Düşme algılandığında çalan yüksek öncelikli alarm.',
          defaultColor: const Color(0xFF9D0A0E),
          ledColor: Colors.red,
          importance: NotificationImportance.Max, // Ekrana şak diye düşmesi için
          criticalAlerts: true, // Telefon sessizde olsa bile çalabilmesi için
        )
      ],
    );
  }

  // 2. Arka Plan Servisini Başlatma
  static Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // Arka planda çalışacak ana fonksiyon
        autoStart: true,
        isForegroundMode: true, // Android'e "ben önemli bir iş yapıyorum" diyoruz
        notificationChannelId: 'acil_durum_kanali',
        initialNotificationTitle: 'SafeHome Aktif',
        initialNotificationContent: 'Arka planda koruma sağlanıyor...',
      ),
      iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart, onBackground: onIosBackground),
    );
  }
}

// 🚀 Uygulama Kapalıyken Arka Planda Çalışacak Olan Bağımsız Fonksiyon
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Arka planda Firebase'i tekrar ayağa kaldırıyoruz (Ayrı thread olduğu için şart!)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCx6quwMWto0AKl-UGLrQZDGNAEz_25tkY",
      appId: "1:397421928399:web:c8a341f535f1a5c6bc7cba",
      messagingSenderId: "397421928399",
      projectId: "safehome-web",
      databaseURL: "https://safehome-web-default-rtdb.firebaseio.com",
    ),
  );

  final DatabaseReference dusmeRef = FirebaseDatabase.instance.ref('dusmeDurumu');

  // Firebase'i arkadan saniye saniye dinlemeye başlıyoruz
  dusmeRef.onValue.listen((event) {
    final dynamic value = event.snapshot.value;
    if (value == true) {
      // Donanımdan TRUE geldiği an üst bar bildirimini patlatıyoruz!
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'acil_durum_kanali',
          title: '🚨 ACİL DURUM: DÜŞME ALGILANDI!',
          body: 'Yakınınız bir düşme anomalisi yaşadı. Lütfen hemen kontrol edin!',
          notificationLayout: NotificationLayout.BigText,
          backgroundColor: Colors.red,
        ),
      );
    }
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) => true;