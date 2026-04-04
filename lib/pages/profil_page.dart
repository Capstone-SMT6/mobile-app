import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.purple,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit, size: 16, color: Colors.purple.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Product Designer @ Acme Corp',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Premium Member',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple.shade700,
              side: BorderSide(color: Colors.purple.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Achievements',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade700, fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAchievementChip(Icons.star, 'Top Contributor', Colors.amber),
                const SizedBox(width: 8),
                _buildAchievementChip(Icons.bolt, 'Early Adopter', Colors.blue),
                const SizedBox(width: 8),
                _buildAchievementChip(Icons.verified_outlined, 'Verified Pro', Colors.green),
                const SizedBox(width: 8),
                _buildAchievementChip(Icons.local_fire_department_outlined, '30-Day Streak', Colors.deepOrange),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatDetail('48', 'Tasks Done'),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildStatDetail('12', 'Reports'),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildStatDetail('Level 4', 'Rank'),
            ],
          ),
          const SizedBox(height: 32),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildMenuRow(Icons.person_outline, 'Account Information', onTap: () {}),
                const Divider(height: 1),
                _buildMenuRow(Icons.history, 'Activity History', onTap: () {}),
                const Divider(height: 1),
                _buildMenuRow(Icons.lock_outline, 'Privacy & Security', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildToggleRow(
                  Icons.notifications_outlined,
                  'Notifications',
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
                const Divider(height: 1),
                _buildToggleRow(
                  Icons.dark_mode_outlined,
                  'Dark Mode',
                  _darkModeEnabled,
                  (value) => setState(() => _darkModeEnabled = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildMenuRow(Icons.help_outline, 'Help Center', onTap: () {}),
                const Divider(height: 1),
                _buildMenuRow(Icons.info_outline, 'About App', onTap: () {}),
                const Divider(height: 1),
                _buildMenuRow(
                  Icons.logout,
                  'Log Out',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () async {
                    await AuthService().deleteToken();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget _buildAchievementChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.purple),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildMenuRow(
    IconData icon,
    String title, {
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.purple.shade700),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildToggleRow(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.purple.shade700,
      ),
    );
  }
}
