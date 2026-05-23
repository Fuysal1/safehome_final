import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../ilac_model.dart';

class MedicationsTab extends StatefulWidget {
  const MedicationsTab({super.key});

  @override
  State<MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends State<MedicationsTab> {
  final _ilaclarRef = FirebaseDatabase.instance.ref('ilaclar');

  final _isimController = TextEditingController();
  final _saatController = TextEditingController();
  final _dozController = TextEditingController();

  @override
  void dispose() {
    _isimController.dispose();
    _saatController.dispose();
    _dozController.dispose();
    super.dispose();
  }

  Future<void> _toggleIlacDurum(IlacModel ilac) async {
    await _ilaclarRef.child(ilac.id).update({'alindiMi': !ilac.alindiMi});
  }

  Future<void> _addIlac() async {
    if (_isimController.text.trim().isEmpty ||
        _saatController.text.trim().isEmpty) {
      return;
    }
    final ref = _ilaclarRef.push();
    await ref.set({
      'id': ref.key,
      'isim': _isimController.text.trim(),
      'saat': _saatController.text.trim(),
      'doz': _dozController.text.trim().isEmpty
          ? '1 Adet'
          : _dozController.text.trim(),
      'alindiMi': false,
    });
    _isimController.clear();
    _saatController.clear();
    _dozController.clear();
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedicationSheet(
        isimController: _isimController,
        saatController: _saatController,
        dozController: _dozController,
        onAdd: () {
          _addIlac();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MedicationsHeader(onAdd: _showAddSheet),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: _MedicationsList(
              stream: _ilaclarRef.onValue,
              onToggle: _toggleIlacDurum,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// Header
// ════════════════════════════════════════════════════════════

class _MedicationsHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _MedicationsHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B2447),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Günlük İlaçlar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Bugün alınması gerekenler',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Ekle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Medications List (StreamBuilder)
// ════════════════════════════════════════════════════════════

class _MedicationsList extends StatelessWidget {
  final Stream<DatabaseEvent> stream;
  final void Function(IlacModel) onToggle;

  const _MedicationsList({required this.stream, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final rawData = snapshot.data!.snapshot.value;
        final ilaclar = <IlacModel>[];

        if (rawData is Map) {
          rawData.forEach((key, value) {
            if (value is Map) {
              ilaclar.add(IlacModel.fromMap(key.toString(), value));
            }
          });
        }

        if (ilaclar.isEmpty) {
          return const _EmptyMedicationsState();
        }

        ilaclar.sort((a, b) {
          if (a.alindiMi != b.alindiMi) return a.alindiMi ? 1 : -1;
          return a.saat.compareTo(b.saat);
        });

        final takenCount = ilaclar.where((i) => i.alindiMi).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressSummary(taken: takenCount, total: ilaclar.length),
            const SizedBox(height: 16),
            for (final ilac in ilaclar)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MedicationCard(
                  ilac: ilac,
                  onToggle: () => onToggle(ilac),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
// Progress Summary
// ════════════════════════════════════════════════════════════

class _ProgressSummary extends StatelessWidget {
  final int taken;
  final int total;

  const _ProgressSummary({required this.taken, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : taken / total;
    final primary = Theme.of(context).colorScheme.primary;
    final color =
        ratio == 1.0 ? const Color(0xFF2E7D32) : primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Row(
        children: [
          Icon(
            ratio == 1.0
                ? Icons.check_circle_rounded
                : Icons.medication_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$taken / $total ilaç alındı',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Medication Card
// ════════════════════════════════════════════════════════════

class _MedicationCard extends StatelessWidget {
  final IlacModel ilac;
  final VoidCallback onToggle;

  const _MedicationCard({required this.ilac, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final taken = ilac.alindiMi;
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: taken ? const Color(0xFFF9FAFB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: taken
              ? const Color(0xFFE8EBF0)
              : const Color(0xFFDCE8F5),
        ),
        boxShadow: taken
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: taken
                    ? const Color(0xFFF0F0F0)
                    : primary.withValues(alpha: 0.10),
              ),
              child: Icon(
                Icons.medication_rounded,
                color: taken ? Colors.grey.shade400 : primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ilac.isim,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: taken
                          ? Colors.grey.shade400
                          : const Color(0xFF1A2340),
                      decoration:
                          taken ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    Icon(Icons.schedule_rounded,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(ilac.saat,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500)),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Icon(Icons.colorize_rounded,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(ilac.doz,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500)),
                  ]),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: taken
                      ? const Color(0xFFE6F7EE)
                      : const Color(0xFFF2F4F8),
                  border: Border.all(
                    color: taken
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  taken
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  color: taken
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade400,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Empty State
// ════════════════════════════════════════════════════════════

class _EmptyMedicationsState extends StatelessWidget {
  const _EmptyMedicationsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 52),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Henüz ilaç eklenmemiş',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"+ Ekle" butonuna dokunarak başlayın',
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Add Medication Bottom Sheet
// ════════════════════════════════════════════════════════════

class _AddMedicationSheet extends StatelessWidget {
  final TextEditingController isimController;
  final TextEditingController saatController;
  final TextEditingController dozController;
  final VoidCallback onAdd;

  const _AddMedicationSheet({
    required this.isimController,
    required this.saatController,
    required this.dozController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Yeni İlaç Ekle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'İlaç bilgilerini doldurun.',
            style:
                TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          _SheetField(
            controller: isimController,
            hint: 'İlaç Adı (ör: Arveles)',
            icon: Icons.medication_rounded,
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: saatController,
            hint: 'Saat (ör: 14:00)',
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: dozController,
            hint: 'Doz (ör: 1 Adet)',
            icon: Icons.numbers_rounded,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              child: const Text('İlacı Ekle'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
      ),
    );
  }
}
