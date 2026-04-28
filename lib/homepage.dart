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
    const accentGreen = Color(0xFF67C23A);
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
            Text(
              'SELAMAT PAGI',
              style: TextStyle(
                color: accentGreen,
                fontSize: 12,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Piresabil Panji Wistyorafi',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: borderColor,
              child: Icon(Icons.person, color: textSecondary),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            BerandaPage(colorScheme: Theme.of(context).colorScheme),
            const LaporanPage(),
            const Scaffold(
              body: Center(
                child: Text('Latihan', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Scaffold(
              body: Center(
                child: Text('Sejarah', style: TextStyle(color: Colors.white)),
              ),
            ),
            const ProfilPage(),
          ],
        ),
      ),
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
        child: Obx(
          () => BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard_outlined),
                activeIcon: Icon(Icons.leaderboard),
                label: 'Peringkat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Latihan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history),
                label: 'Sejarah',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: controller.selectedIndex.value,
            selectedItemColor: accentGreen,
            unselectedItemColor: textSecondary,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
