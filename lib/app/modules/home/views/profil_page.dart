import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

const _bg = Color(0xFF0D0F14);
const _surface = Color(0xFF1C2030);
const _border = Color(0xFF2A2F45);
const _green = Color(0xFF4FFFB0);
const _purple = Color(0xFF7C6AF7);
const _textPrimary = Color(0xFFE8EAF2);
const _textSecondary = Color(0xFF6B7280);

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfilController controller = Get.find<ProfilController>();

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _purple.withValues(alpha: 0.4), width: 2),
                    color: _purple.withValues(alpha: 0.08),
                  ),
                ),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: _surface,
                  child: const Icon(Icons.person, size: 56, color: _purple),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bg, width: 2),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: _bg),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text('John Doe',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Fitness Enthusiast · Level 12',
                style: TextStyle(color: _textSecondary, fontSize: 13)),
            const SizedBox(height: 10),

            // Rank badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _green.withValues(alpha: 0.3)),
              ),
              child: const Text('🏆 Top 50 Global',
                  style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),

            const SizedBox(height: 20),

            // Edit button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 15, color: _purple),
              label: const Text('EDIT PROFILE',
                  style: TextStyle(
                      color: _purple,
                      letterSpacing: 1,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _purple.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),

            const SizedBox(height: 28),

            // ── Stats row ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCol('148', 'Workouts'),
                  _divider(),
                  _statCol('42 kg', 'Total Volume'),
                  _divider(),
                  _statCol('#42', 'Global Rank'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Achievements ─────────────────────────────────
            _sectionLabel('ACHIEVEMENTS'),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip(Icons.local_fire_department, '7-Day Streak',
                      const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _chip(Icons.bolt, 'Early Adopter', _purple),
                  const SizedBox(width: 8),
                  _chip(Icons.verified_outlined, 'PR Breaker', _green),
                  const SizedBox(width: 8),
                  _chip(Icons.emoji_events_outlined, 'Top 50', const Color(0xFFEC4899)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Account section ──────────────────────────────
            _sectionLabel('ACCOUNT'),
            const SizedBox(height: 10),
            _menuGroup([
              _menuItem(Icons.person_outline, 'Account Information', () {}),
              _menuItem(Icons.history, 'Workout History', () {}),
              _menuItem(Icons.lock_outline, 'Privacy & Security', () {}),
            ]),

            const SizedBox(height: 16),

            // ── Preferences section ──────────────────────────
            _sectionLabel('PREFERENCES'),
            const SizedBox(height: 10),
            Obx(() => _menuGroup([
                  _toggleItem(Icons.notifications_outlined, 'Notifications',
                      controller.notificationsEnabled.value,
                      controller.toggleNotifications),
                  const Divider(height: 1, color: _border),
                  _toggleItem(Icons.vibration, 'Haptic Feedback',
                      controller.hapticEnabled.value,
                      controller.toggleHaptic),
                ])),

            const SizedBox(height: 16),

            // ── Support section ──────────────────────────────
            _sectionLabel('SUPPORT'),
            const SizedBox(height: 10),
            _menuGroup([
              _menuItem(Icons.help_outline, 'Help Center', () {}),
              _menuItem(Icons.info_outline, 'About App', () {}),
              _menuItem(
                Icons.logout,
                'Log Out',
                () => controller.logout(),
                accent: Colors.redAccent,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ───────────────────────────────────────────

  Widget _sectionLabel(String label) => Align(
        alignment: Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(
                color: _green,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
      );

  Widget _statCol(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: _purple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: _textSecondary, fontSize: 12)),
        ],
      );

  Widget _divider() =>
      Container(width: 1, height: 36, color: _border);

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _menuGroup(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(children: children),
      );

  Widget _menuItem(IconData icon, String title, VoidCallback onTap,
      {Color? accent}) {
    final col = accent ?? _textPrimary;
    return ListTile(
      leading: Icon(icon, color: accent ?? _purple, size: 20),
      title: Text(title,
          style: TextStyle(
              color: col, fontWeight: FontWeight.w500, fontSize: 14)),
      trailing:
          Icon(Icons.chevron_right, color: _textSecondary, size: 18),
      onTap: onTap,
    );
  }

  Widget _toggleItem(IconData icon, String title, bool value,
      ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: _purple, size: 20),
      title: Text(title,
          style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: _green,
        inactiveThumbColor: _textSecondary,
        inactiveTrackColor: _border,
      ),
    );
  }
}
