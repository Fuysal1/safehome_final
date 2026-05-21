import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ilac_model.dart';

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
      title: 'SafeHome Dinamik Panel',
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
  final DatabaseReference _dusmeRef = FirebaseDatabase.instance.ref('dusmeDurumu');
  final DatabaseReference _ilaclarRef = FirebaseDatabase.instance.ref('ilaclar');

  // Formdan verileri okumak için Controller'lar tanımlıyoruz
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _saatController = TextEditingController();
  final TextEditingController _dozController = TextEditingController();

  Future<void> _resetAlarm() async {
    await _dusmeRef.set(false);
  }

  Future<void> _toggleIlacDurum(IlacModel ilac) async {
    await _ilaclarRef.child(ilac.id).update({
      'alindiMi': !ilac.alindiMi,
    });
  }

  // Dinamik İlaç Ekleme
  Future<void> _addIlac() async {
    if (_isimController.text.isEmpty || _saatController.text.isEmpty) return;

    final yeniIlacRef = _ilaclarRef.push();
    await yeniIlacRef.set({
      'id': yeniIlacRef.key,
      'isim': _isimController.text,
      'saat': _saatController.text,
      'doz': _dozController.text.isEmpty ? '1 Adet' : _dozController.text,
      'alindiMi': false,
    });

    // Eklendikten sonra kutuları temizle
    _isimController.clear();
    _saatController.clear();
    _dozController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafeHome Dinamik Kontrol Paneli'), backgroundColor: Colors.blueGrey),
      body: Column(
        children: [
          // DÜŞME ALANI (FAZ 1)
          Expanded(
            flex: 2,
            child: StreamBuilder(
              stream: _dusmeRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
                        ElevatedButton(onPressed: _resetAlarm, child: const Text('ALARM KAPAT', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('💊 Bugün Alınması Gereken İlaçlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),

          // İLAÇ LİSTELEME ALANI
          Expanded(
            flex: 3,
            child: StreamBuilder(
              stream: _ilaclarRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                List<IlacModel> ilacListesi = [];
                final hamVeri = snapshot.data!.snapshot.value;

                if (hamVeri != null && hamVeri is Map) {
                  hamVeri.forEach((key, value) {
                    if (value is Map) {
                      ilacListesi.add(IlacModel.fromMap(key.toString(), value));
                    }
                  });
                }

                if (ilacListesi.isEmpty) return const Center(child: Text('Henüz ilaç eklenmemiş.'));

                return ListView.builder(
                  itemCount: ilacListesi.length,
                  itemBuilder: (context, index) {
                    final currentIlac = ilacListesi[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.medication, color: currentIlac.alindiMi ? Colors.grey : Colors.blue),
                        title: Text(currentIlac.isim, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: currentIlac.alindiMi ? TextDecoration.lineThrough : null)),
                        subtitle: Text('Saat: ${currentIlac.saat} | Doz: ${currentIlac.doz}'),
                        trailing: Checkbox(
                          value: currentIlac.alindiMi,
                          onChanged: (bool? value) => _toggleIlacDurum(currentIlac),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ================= NEW: DİNAMİK İLAÇ EKLEME FORMU =================
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(child: TextField(controller: _isimController, decoration: const InputDecoration(labelText: 'İlaç Adı', isDense: true))),
                const SizedBox(width: 5),
                Expanded(child: TextField(controller: _saatController, decoration: const InputDecoration(labelText: 'Saat (Örn 14:00)', isDense: true))),
                const SizedBox(width: 5),
                Expanded(child: TextField(controller: _dozController, decoration: const InputDecoration(labelText: 'Doz', isDense: true))),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueGrey, size: 35),
                  onPressed: _addIlac, // Butona basınca Firebase'e ekler
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}