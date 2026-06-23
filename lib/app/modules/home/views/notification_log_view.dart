import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smacofit/app/core/theme/app_colors.dart';

class NotificationLogView extends StatelessWidget {
  const NotificationLogView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy notification data for now
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Selamat Datang di SmaCoFit! 👋',
        'message': 'Mulai perjalanan fitness Anda hari ini dan capai target tubuh ideal.',
        'time': 'Baru saja',
        'icon': Icons.waving_hand,
        'color': Colors.blue,
        'isRead': false,
      },
      {
        'title': 'Waktunya Bergerak! 🏃‍♂️',
        'message': 'Jangan lupa jadwal latihan harian Anda. Konsistensi adalah kunci!',
        'time': '2 jam yang lalu',
        'icon': Icons.notifications_active,
        'color': accentGreen,
        'isRead': true,
      },
      {
        'title': 'Profil Fisik',
        'message': 'Lengkapi data berat dan tinggi badan Anda untuk rekomendasi yang lebih akurat.',
        'time': '1 hari yang lalu',
        'icon': Icons.person,
        'color': Colors.orange,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif['isRead']
                          ? Colors.transparent
                          : accentGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (notif['color'] as Color).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notif['icon'] as IconData,
                          color: notif['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif['title'] as String,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: notif['isRead']
                                          ? FontWeight.w500
                                          : FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  notif['time'] as String,
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11,
                                    fontWeight: notif['isRead']
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notif['message'] as String,
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
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
