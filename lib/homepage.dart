import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/beranda_page.dart';
import 'pages/laporan_page.dart';
import 'pages/profil_page.dart';
import 'controllers/home_controller.dart';
import 'routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    const bgColor = Color(0xFF0D0F14);
    const surfaceColor = Color(0xFF1C2030);
    const borderColor = Color(0xFF2A2F45);
    const accentGreen = Color(0xFF4FFFB0);
    const accentPurple = Color(0xFF7C6AF7);
    const textSecondary = Color(0xFF6B7280);
    const textPrimary = Color(0xFFE8EAF2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: surfaceColor,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GOOD MORNING',
                style: TextStyle(
                    color: accentGreen,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold)),
            Text('Athlete',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              BerandaPage(colorScheme: Theme.of(context).colorScheme),
              const LaporanPage(),
              const ProfilPage(),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.chatbot),
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: const Icon(Icons.smart_toy_outlined),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: Obx(() => BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard_outlined),
                  activeIcon: Icon(Icons.leaderboard),
                  label: 'Leaderboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: controller.selectedIndex.value,
              selectedItemColor: accentGreen,
              unselectedItemColor: textSecondary,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
            )),
      ),
    );
  }
}
