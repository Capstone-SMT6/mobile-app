import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';
import '../controllers/user_controller.dart';
import '../routes/app_routes.dart';
import '../services/plan_service.dart';

const _bg = Color(0xFF0A0C10);
const _surface = Color(0xFF161824);
const _border = Color(0xFF262A3D);
const _green = Color(0xFF4FFFB0);
const _purple = Color(0xFF7C6AF7);
const _textPrimary = Color(0xFFE8EAF2);
const _textSecondary = Color(0xFF8B92A5);

final _cardDecoration = BoxDecoration(
  color: _surface,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: _border, width: 1.5),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ],
);

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _analytics;
  bool _analyticsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final data = await PlanService.getAnalyticsSummary();
      if (mounted) setState(() { _analytics = data; _analyticsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _analyticsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final ProfilController profilController = Get.find<ProfilController>();

    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (userController.isLoading.value && userController.user.value == null) {
          return const Center(child: CircularProgressIndicator(color: _purple));
        }

        final user = userController.user.value;
        final stats = userController.stats.value;
        final profile = userController.fitnessProfile.value;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => userController.refreshData(),
            color: _purple,
            backgroundColor: _surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
              physics: const AlwaysScrollableScrollPhysics(),
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
                        border: Border.all(
                            color: _purple.withValues(alpha: 0.4), width: 2),
                        color: _purple.withValues(alpha: 0.08),
                      ),
                    ),
                    Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        color: _surface,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? Image.network(
                              user.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person,
                                      size: 48, color: _textSecondary),
                            )
                          : const Icon(Icons.person,
                              size: 48, color: _textSecondary),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => profilController.updateAvatar(),
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
                Text(user?.username ?? 'User',
                    style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(profile?.goalFormatted ?? 'Setting up profile...',
                    style: const TextStyle(color: _textSecondary, fontSize: 13)),
                const SizedBox(height: 16),

                // Edit button
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.onboardingGoal),
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

                // ── Stats row (Physical Metrics) ──────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: _cardDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCol('${profile?.weight ?? "-"} kg', 'Weight'),
                      _divider(),
                      _statCol('${profile?.height ?? "-"} cm', 'Height'),
                      _divider(),
                      _statCol('${profile?.age ?? "-"}', 'Age'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Fitness Profile Details ───────────────────────
                _sectionLabel('FITNESS PROFILE'),
                const SizedBox(height: 10),
                if (profile == null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_purple.withValues(alpha: 0.15), _surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _purple.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.fitness_center, color: _purple, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Profile Incomplete',
                          style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Set up your fitness profile to get personalized training recommendations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.onboardingGoal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('COMPLETE PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                else
                  _menuGroup([
                    _profileItem('Goal', profile.goalFormatted),
                    _profileItem('Intensity', profile.intensity.capitalizeFirst ?? '-'),
                    _profileItem('Skill Level', profile.skillLevel.capitalizeFirst ?? '-'),
                    _profileItem('Duration', profile.durationTarget.replaceAll('_', ' ').capitalizeFirst ?? '-'),
                  ]),

                const SizedBox(height: 28),

                // ── Performance Metrics ──────────────────────────
                _sectionLabel('LIFETIME PERFORMANCE'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip(Icons.fitness_center, '${stats?.totalPushUps ?? 0} Push Ups', _purple),
                      const SizedBox(width: 8),
                      _chip(Icons.accessibility_new, '${stats?.totalSitUps ?? 0} Sit Ups', _green),
                      if (_analytics != null) ...[  
                        const SizedBox(width: 8),
                        _chip(Icons.repeat, '${_analytics!['total_reps'] ?? 0} Total Reps', const Color(0xFFAB47BC)),
                        const SizedBox(width: 8),
                        _chip(Icons.local_fire_department, '${_analytics!['current_streak'] ?? 0} Day Streak', const Color(0xFFFFA726)),
                        const SizedBox(width: 8),
                        _chip(Icons.fitness_center, '${_analytics!['total_workouts'] ?? 0} Workouts', const Color(0xFF29B6F6)),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Achievement Badges ────────────────────────────
                _sectionLabel('ACHIEVEMENTS'),
                const SizedBox(height: 12),
                _buildAchievements(),

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
                _menuGroup([
                  _toggleItem(Icons.notifications_outlined, 'Notifications',
                      profilController.notificationsEnabled.value,
                      profilController.toggleNotifications),
                  const Divider(height: 1, color: _border),
                  _toggleItem(Icons.vibration, 'Haptic Feedback',
                      profilController.hapticEnabled.value,
                      profilController.toggleHaptic),
                ]),

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
                    () => profilController.logout(),
                    accent: Colors.redAccent,
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
      }),
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
        decoration: _cardDecoration,
        child: Column(children: children),
      );

  Widget _profileItem(String label, String value) {
    return ListTile(
      title: Text(label,
          style: const TextStyle(
              color: _textSecondary, fontWeight: FontWeight.w500, fontSize: 13)),
      trailing: Text(value,
          style: const TextStyle(
              color: _textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

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

  // ── Achievement badges ─────────────────────────────────────
  Widget _buildAchievements() {
    final streak = (_analytics?['current_streak'] as num?)?.toInt() ?? 0;
    final longestStreak = (_analytics?['longest_streak'] as num?)?.toInt() ?? 0;
    final totalReps = (_analytics?['total_reps'] as num?)?.toInt() ?? 0;
    final totalWorkouts = (_analytics?['total_workouts'] as num?)?.toInt() ?? 0;

    final achievements = <_Achievement>[
      _Achievement(
        icon: Icons.local_fire_department,
        title: '7 Day Streak',
        desc: 'Latihan 7 hari berturut-turut',
        unlocked: streak >= 7 || longestStreak >= 7,
        color: const Color(0xFFFFA726),
      ),
      _Achievement(
        icon: Icons.whatshot,
        title: '14 Day Streak',
        desc: 'Latihan 14 hari berturut-turut',
        unlocked: streak >= 14 || longestStreak >= 14,
        color: const Color(0xFFFF7043),
      ),
      _Achievement(
        icon: Icons.emoji_events,
        title: '30 Day Legend',
        desc: 'Latihan 30 hari berturut-turut',
        unlocked: streak >= 30 || longestStreak >= 30,
        color: const Color(0xFFFFD54F),
      ),
      _Achievement(
        icon: Icons.repeat,
        title: '100 Reps Club',
        desc: 'Total 100 repetisi',
        unlocked: totalReps >= 100,
        color: const Color(0xFFAB47BC),
      ),
      _Achievement(
        icon: Icons.fitness_center,
        title: '10 Workouts',
        desc: 'Selesaikan 10 sesi workout',
        unlocked: totalWorkouts >= 10,
        color: const Color(0xFF7C6AF7),
      ),
      _Achievement(
        icon: Icons.star,
        title: '50 Workouts',
        desc: 'Selesaikan 50 sesi workout',
        unlocked: totalWorkouts >= 50,
        color: const Color(0xFF6CC551),
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: achievements.map((a) => _AchievementBadge(achievement: a)).toList(),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String desc;
  final bool unlocked;
  final Color color;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.desc,
    required this.unlocked,
    required this.color,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: a.unlocked
            ? a.color.withValues(alpha: 0.12)
            : _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: a.unlocked
              ? a.color.withValues(alpha: 0.4)
              : _border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            a.icon,
            color: a.unlocked ? a.color : _textSecondary.withValues(alpha: 0.3),
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            a.title,
            style: TextStyle(
              color: a.unlocked ? _textPrimary : _textSecondary.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            a.desc,
            style: TextStyle(
              color: a.unlocked ? _textSecondary : _textSecondary.withValues(alpha: 0.2),
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
