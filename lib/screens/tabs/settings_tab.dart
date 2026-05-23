import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _fallAlertEnabled = true;
  bool _medicineAlertEnabled = true;
  bool _backgroundServiceEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SettingsHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const _ProfileCard(),
                const SizedBox(height: 20),
                _SettingsGroup(
                  title: 'Bildirimler',
                  children: [
                    _SettingsTile(
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFDC143C),
                      title: 'Düşme Alarmı',
                      subtitle: 'Acil durum bildirimleri',
                      trailing: Switch.adaptive(
                        value: _fallAlertEnabled,
                        activeThumbColor: const Color(0xFF0B2447),
                        activeTrackColor:
                            const Color(0xFF0B2447).withValues(alpha: 0.4),
                        onChanged: (v) =>
                            setState(() => _fallAlertEnabled = v),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.medication_rounded,
                      iconColor: const Color(0xFF1565C0),
                      title: 'İlaç Hatırlatması',
                      subtitle: 'Zamanında hatırlatma',
                      trailing: Switch.adaptive(
                        value: _medicineAlertEnabled,
                        activeThumbColor: const Color(0xFF0B2447),
                        activeTrackColor:
                            const Color(0xFF0B2447).withValues(alpha: 0.4),
                        onChanged: (v) =>
                            setState(() => _medicineAlertEnabled = v),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.sync_rounded,
                      iconColor: const Color(0xFF2E7D32),
                      title: 'Arka Plan Servisi',
                      subtitle: 'Sürekli izleme aktif',
                      trailing: Switch.adaptive(
                        value: _backgroundServiceEnabled,
                        activeThumbColor: const Color(0xFF0B2447),
                        activeTrackColor:
                            const Color(0xFF0B2447).withValues(alpha: 0.4),
                        onChanged: (v) => setState(
                            () => _backgroundServiceEnabled = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsGroup(
                  title: 'Uygulama Hakkında',
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF1565C0),
                      title: 'Versiyon',
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.cloud_rounded,
                      iconColor: const Color(0xFFE65100),
                      title: 'Firebase Projesi',
                      trailing: Text(
                        'safehome-web',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.shield_rounded,
                      iconColor: const Color(0xFF0B2447),
                      title: 'Güvenlik Protokolü',
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'SafeHome v1.0.0  ·  © 2025',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B2447),
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Text(
            'Ayarlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Profile Card
// ════════════════════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2447), Color(0xFF1A4F8A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2447).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Center(
              child: Text(
                'F',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fatih',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'SafeHome Yöneticisi',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Settings Group + Tile
// ════════════════════════════════════════════════════════════

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEF0F4)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 56, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2340),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
