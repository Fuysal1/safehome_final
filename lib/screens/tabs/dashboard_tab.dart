import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _dusmeRef = FirebaseDatabase.instance.ref('dusmeDurumu');

  Future<void> _resetAlarm() async {
    await _dusmeRef.set(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DashboardHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                _SecurityStatusCard(
                  dusmeStream: _dusmeRef.onValue,
                  onResetAlarm: _resetAlarm,
                ),
                const SizedBox(height: 16),
                const _BatteryCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// Dashboard Header  (replaces SliverAppBar — no overlap)
// ════════════════════════════════════════════════════════════

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Günaydın' : hour < 18 ? 'Merhaba' : 'İyi Akşamlar';

    final today = DateTime.now();
    final months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    final dateStr = '${today.day} ${months[today.month]} ${today.year}';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2447), Color(0xFF1A4F8A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Icon(Icons.shield_rounded, color: Colors.white54, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'SAFEHOME',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ]),
                  Row(children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white70,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border:
                            Border.all(color: Colors.white24, width: 1),
                      ),
                      child: const Center(
                        child: Text(
                          'F',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '$greeting, Fatih 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                dateStr,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Security Status Card
// ════════════════════════════════════════════════════════════

class _SecurityStatusCard extends StatelessWidget {
  final Stream<DatabaseEvent> dusmeStream;
  final VoidCallback onResetAlarm;

  const _SecurityStatusCard({
    required this.dusmeStream,
    required this.onResetAlarm,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: dusmeStream,
      builder: (context, snapshot) {
        final isFalling =
            snapshot.hasData && snapshot.data!.snapshot.value == true;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFalling
                  ? const [Color(0xFF7B0014), Color(0xFFDC143C)]
                  : const [Color(0xFF0B2447), Color(0xFF1565C0)],
            ),
            boxShadow: [
              BoxShadow(
                color: isFalling
                    ? const Color(0xFFDC143C).withValues(alpha: 0.45)
                    : const Color(0xFF0B2447).withValues(alpha: 0.30),
                blurRadius: 24,
                spreadRadius: isFalling ? 3 : 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        isFalling
                            ? Icons.warning_amber_rounded
                            : Icons.shield_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isFalling
                                ? '🚨 DÜŞME ALGILANDI!'
                                : '🛡️ Yakınınız Güvende',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isFalling
                                ? 'Lütfen hemen kontrol edin!'
                                : 'Sistem aktif olarak izleniyor',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Live dot
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFalling
                            ? Colors.yellowAccent
                            : Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(
                            color: (isFalling
                                    ? Colors.yellowAccent
                                    : Colors.greenAccent)
                                .withValues(alpha: 0.7),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isFalling) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onResetAlarm,
                      icon: const Icon(Icons.check_circle_outline,
                          size: 18),
                      label: const Text('Alarmı Kapat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC143C),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
                if (!isFalling) ...[
                  const SizedBox(height: 16),
                  const Row(children: [
                    _StatusPill(label: 'Düşme Sensörü'),
                    SizedBox(width: 8),
                    _StatusPill(label: 'Bildirimler'),
                    SizedBox(width: 8),
                    _StatusPill(label: 'Canlı İzleme'),
                  ]),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Colors.greenAccent),
        ),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Battery Card  — live IoT device battery from Firebase
// ════════════════════════════════════════════════════════════

class _BatteryCard extends StatelessWidget {
  const _BatteryCard();

  static Color _colorFor(int level) {
    if (level > 50) return const Color(0xFF2E7D32);
    if (level > 20) return const Color(0xFFE65100);
    return const Color(0xFFDC143C);
  }

  static String _labelFor(int level) {
    if (level > 50) return 'İyi';
    if (level > 20) return 'Orta';
    return 'Kritik';
  }

  static IconData _iconFor(int level) {
    if (level > 90) return Icons.battery_full_rounded;
    if (level > 50) return Icons.battery_5_bar_rounded;
    if (level > 20) return Icons.battery_3_bar_rounded;
    return Icons.battery_1_bar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('cihaz/bataryaSeviyesi').onValue,
      builder: (context, snapshot) {
        // ── Loading ──────────────────────────────────────────
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
              ),
              const SizedBox(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 140,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ]),
            ]),
          );
        }

        // ── Live data ─────────────────────────────────────────
        final raw = snapshot.data!.snapshot.value;
        final level = (raw is int ? raw : int.tryParse(raw.toString()) ?? 0)
            .clamp(0, 100);

        final color = _colorFor(level);
        final isLow = level < 20;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isLow
                    ? const Color(0xFFDC143C).withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isLow ? 22 : 12,
                spreadRadius: isLow ? 2 : 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Track
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.withValues(alpha: 0.12),
                      ),
                    ),
                    // Fill
                    CircularProgressIndicator(
                      value: level / 100,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    // Centre label
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$level',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2340),
                            height: 1,
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: color),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _labelFor(level),
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    const Text(
                      'IoT Cihaz Bataryası',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2340),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'cihaz/bataryaSeviyesi',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 12),
                    // Linear bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: level / 100,
                        minHeight: 6,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(_iconFor(level), size: 36, color: color),
            ],
          ),
        );
      },
    );
  }
}
