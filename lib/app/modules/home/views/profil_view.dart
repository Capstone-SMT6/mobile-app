import 'package:smacofit/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smacofit/app/modules/home/controllers/profil_controller.dart';
import 'package:smacofit/app/modules/auth/controllers/user_controller.dart';
import 'package:smacofit/app/routes/app_routes.dart';
import 'package:smacofit/app/modules/workout/views/workout_history_view.dart';

const _bg = bgColor;
const _surface = surfaceColor;
const _border = borderColor;
const _green = accentGreen;
const _textPrimary = Color(0xFFE8EAF2);
const _textSecondary = textSecondary;

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

class ProfilView extends StatefulWidget {
  const ProfilView({super.key});

  @override
  State<ProfilView> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilView> {
  final UserController userController = Get.find<UserController>();
  final ProfilController profilController = Get.find<ProfilController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (userController.isLoading.value && userController.user.value == null) {
          return const Center(child: CircularProgressIndicator(color: _green));
        }

        final user = userController.user.value;
        final stats = userController.stats.value;
        final profile = userController.fitnessProfile.value;

        // Calculate achievements
        final totalWorkouts = (stats?.totalPushUps ?? 0) + (stats?.totalSitUps ?? 0);
        final achievements = _calculateAchievements(
          totalWorkouts: totalWorkouts,
          streakDays: stats?.currentStreak ?? 0,
        );

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => userController.refreshData(),
            color: _green,
            backgroundColor: _surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _green.withValues(alpha: 0.4), width: 2),
                        color: _green.withValues(alpha: 0.08),
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
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.onboardingGoal),
                  icon: const Icon(Icons.edit_outlined, size: 15, color: Colors.white),
                  label: const Text('Edit Profil',
                      style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: _cardDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCol('${profile?.weight ?? "-"} kg', 'Berat Badan'),
                      _divider(),
                      _statCol('${profile?.height ?? "-"} cm', 'Tinggi Badan'),
                      _divider(),
                      _statCol('${profile?.age ?? "-"}', 'Umur'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionLabel('PROFIL FISIK'),
                const SizedBox(height: 10),
                if (profile == null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_green.withValues(alpha: 0.15), _surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _green.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.fitness_center, color: _green, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Profil Belum Lengkap',
                          style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Lengkapi profil fisik Anda untuk mendapatkan rekomendasi latihan yang dipersonalisasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.onboardingGoal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('LENGKAPI PROFIL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _menuGroup([
                    _profileItem('Tujuan', profile.goalFormatted),
                    _profileItem('Intensitas', profile.intensity.capitalizeFirst ?? '-'),
                    _profileItem('Tingkat Keahlian', profile.skillLevel.capitalizeFirst ?? '-'),
                    _profileItem('Durasi', profile.durationTarget.replaceAll('_', ' ').capitalizeFirst ?? '-'),
                  ]),
                  const SizedBox(height: 28),
                  _sectionLabel('NUTRISI & KESEHATAN'),
                  const SizedBox(height: 10),
                  _menuGroup([
                    _profileItem('BMI', '${profile.bmi.toStringAsFixed(1)} (${profile.bmiStatus})'),
                    _profileItem('BMR', profile.bmr != null ? '${profile.bmr!.round()} kcal' : '-'),
                    _profileItem('TDEE', profile.tdee != null ? '${profile.tdee!.round()} kcal' : '-'),
                    _profileItem('Target Kalori', profile.targetDailyKcal != null ? '${profile.targetDailyKcal!.round()} kcal' : '-'),
                    _profileItem('Karbohidrat', '${profile.carbGrams} g'),
                    _profileItem('Protein', '${profile.proteinGrams} g'),
                    _profileItem('Lemak', '${profile.fatGrams} g'),
                  ]),
                ],

                const SizedBox(height: 28),

                // Achievements section
                if (achievements.isNotEmpty) ...[
                  _sectionLabel('PENCAPAIAN'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: achievements.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _AchievementBadge(achievement: achievements[i]),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                _sectionLabel('PERFORMA SEPANJANG MASA'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip(Icons.fitness_center, '${stats?.totalPushUps ?? 0} Push Ups', Colors.white),
                      const SizedBox(width: 8),
                      _chip(Icons.accessibility_new, '${stats?.totalSitUps ?? 0} Sit Ups', Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _sectionLabel('AKUN'),
                const SizedBox(height: 10),
                _menuGroup([
                  _menuItem(Icons.person_outline, 'Informasi Akun', () {}),
                  _menuItem(Icons.history, 'Riwayat Latihan', () => Get.to(() => const WorkoutHistoryView())),
                  _menuItem(Icons.lock_outline, 'Ganti Kata Sandi', () => profilController.showChangePasswordDialog(context)),
                ]),

                const SizedBox(height: 16),

                _sectionLabel('PENGATURAN'),
                const SizedBox(height: 10),
                _menuGroup([
                  _toggleItem(Icons.notifications_outlined, 'Notifikasi',
                      profilController.notificationsEnabled.value,
                      profilController.toggleNotifications),
                ]),

                const SizedBox(height: 16),

                _sectionLabel('SUPPORT'),
                const SizedBox(height: 10),
                _menuGroup([
                  _menuItem(Icons.help_outline, 'Hubungi Kami', () {}),
                  _menuItem(Icons.info_outline, 'Tentang Kami', () {}),
                  _menuItem(
                    Icons.logout,
                    'Keluar',
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

  // ── Achievement calculation ─────────────────────────────────

  List<_Achievement> _calculateAchievements({
    required int totalWorkouts,
    required int streakDays,
  }) {
    final results = <_Achievement>[];
    if (totalWorkouts >= 10) {
      results.add(const _Achievement('10+ Workout', Icons.fitness_center, Color(0xFFAB47BC)));
    }
    if (totalWorkouts >= 50) {
      results.add(const _Achievement('50+ Workout', Icons.whatshot, Color(0xFFFFA726)));
    }
    if (totalWorkouts >= 100) {
      results.add(const _Achievement('100+ Workout', Icons.emoji_events, Color(0xFFFFD700)));
    }
    if (streakDays >= 7) {
      results.add(const _Achievement('7 Hari Streak', Icons.local_fire_department, Color(0xFFEF5350)));
    }
    if (streakDays >= 30) {
      results.add(const _Achievement('30 Hari Streak', Icons.diamond, Color(0xFF29B6F6)));
    }
    return results;
  }

  // ── Helper widgets ───────────────────────────────────────────

  Widget _sectionLabel(String label) => Align(
        alignment: Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
      );

  Widget _statCol(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: _textPrimary,
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
      leading: Icon(icon, color: accent ?? _textSecondary, size: 20),
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
      leading: Icon(icon, color: textSecondary, size: 20),
      title: Text(title,
          style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: accentGreen,
        inactiveThumbColor: _textSecondary,
        inactiveTrackColor: _border,
      ),
    );
  }
}

class _Achievement {
  final String label;
  final IconData icon;
  final Color color;
  const _Achievement(this.label, this.icon, this.color);
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: achievement.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: achievement.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(achievement.icon, color: achievement.color, size: 24),
          const SizedBox(height: 4),
          Text(
            achievement.label,
            style: TextStyle(
              color: achievement.color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
