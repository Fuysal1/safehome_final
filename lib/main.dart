import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ilac_model.dart'; // Az önce oluşturduğumuz modeli içeri alıyoruz

void main() async {
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
  
  runApp(const SafeHomeApp());
}

class SafeHomeApp extends StatelessWidget {
  const SafeHomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeHome Backend Test',
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // Veritabanı referans yollarını açıyoruz
  final DatabaseReference _dusmeRef = FirebaseDatabase.instance.ref('dusmeDurumu');
  final DatabaseReference _ilaclarRef = FirebaseDatabase.instance.ref('ilaclar');

  // Alarm durumunu sıfırlayan fonksiyon
  Future<void> _resetAlarm() async {
    await _dusmeRef.set(false);
  }

  // İlacın alındı/alınmadı durumunu Firebase'de güncelleyen fonksiyon
  Future<void> _toggleIlacDurum(IlacModel ilac) async {
    await _ilaclarRef.child(ilac.id).update({
      'alindiMi': !ilac.alindiMi,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeHome Backend Kontrol Paneli'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          // ================= FAZ 1: DÜŞME DURUMU ALANI =================
          Expanded(
            flex: 2,
            child: StreamBuilder(
              stream: _dusmeRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                bool isFalling = false;
                if (snapshot.data!.snapshot.value != null) {
                  isFalling = snapshot.data!.snapshot.value as bool;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  color: isFalling ? Colors.red : Colors.green,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isFalling ? '🚨 DÜŞME ALGILANDI!' : '🛡️ YAŞLI YAKINI GÜVENDE',
                        style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      if (isFalling) const SizedBox(height: 20),
                      if (isFalling)
                        ElevatedButton(
                          onPressed: _resetAlarm,
                          child: const Text('ALARM KAPAT', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ================= FAZ 2: İLAÇ TAKİP ALANI =================
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '💊 Bugün Alınması Gereken İlaçlar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            flex: 3,
            child: StreamBuilder(
              stream: _ilaclarRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<IlacModel> ilacListesi = [];
                final hamVeri = snapshot.data!.snapshot.value;

                if (hamVeri != null && hamVeri is Map) {
                  hamVeri.forEach((key, value) {
                    if (value is Map) {
                      ilacListesi.add(IlacModel.fromMap(key.toString(), value));
                    }
                  });
                }

                if (ilacListesi.isEmpty) {
                  return const Center(child: Text('Henüz ilaç eklenmemiş.'));
                }

                return ListView.builder(
                  itemCount: ilacListesi.length,
                  itemBuilder: (context, index) {
                    final currentIlac = ilacListesi[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(
                          Icons.medication,
                          color: currentIlac.alindiMi ? Colors.grey : Colors.blue,
                          size: 35,
                        ),
                        title: Text(
                          currentIlac.isim,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: currentIlac.alindiMi ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text('Saat: ${currentIlac.saat} | Doz: ${currentIlac.doz}'),
                        trailing: Checkbox(
                          value: currentIlac.alindiMi,
                          onChanged: (bool? value) {
                            _toggleIlacDurum(currentIlac); // Tik atınca Firebase'i anlık günceller
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}