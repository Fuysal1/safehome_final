import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  // Flutter motorunu başlatıyoruz
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Web kimliklerimizle bağlantıyı kuruyoruz
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCx6quwMWto0AKl-UGLrQZDGNAEz_25tkY",
      appId: "1:397421928399:web:c8a341f535f1a5c6bc7cba",
      messagingSenderId: "397421928399",
      projectId: "safehome-web",
      databaseURL: "https://safehome-web-default-rtdb.firebaseio.com", 
    ),
  );
  
  runApp(const SafeHomeApp());
}

class SafeHomeApp extends StatelessWidget {
  const SafeHomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeHome Backend Test',
      home: const FallDetectionScreen(),
    );
  }
}

class FallDetectionScreen extends StatefulWidget {
  const FallDetectionScreen({Key? key}) : super(key: key);

  @override
  State<FallDetectionScreen> createState() => _FallDetectionScreenState();
}

class _FallDetectionScreenState extends State<FallDetectionScreen> {
  // Veritabanındaki 'dusmeDurumu' değişkenine bir yol (referans) açıyoruz
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('dusmeDurumu');

  // Alarmı kapatıp değeri Firebase'de tekrar false yapacak fonksiyon
  Future<void> _resetAlarm() async {
    await _dbRef.set(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // StreamBuilder: Firebase'deki değişimi saniye saniye dinleyen yapı
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          // Eğer veri henüz gelmediyse veya yükleniyorsa ekranda dönen bir çubuk göster
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Gelen veriyi boolean (true/false) olarak alıyoruz. 
          // Eğer null ise varsayılan olarak false kabul ediyoruz.
          bool isFalling = false;
          if (snapshot.data!.snapshot.value != null) {
            isFalling = snapshot.data!.snapshot.value as bool;
          }

          // Arayüz Çizimi
          return Container(
            width: double.infinity,
            color: isFalling ? Colors.red : Colors.green, // True ise Kırmızı, False ise Yeşil
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isFalling ? '🚨 DÜŞME ALGILANDI!' : 'GÜVENDE',
                  style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
                if (isFalling) // Sadece düşme anında butonu göster
                  ElevatedButton(
                    onPressed: _resetAlarm, // Butona basınca veritabanını false yap
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'ALARM KAPAT',
                      style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}