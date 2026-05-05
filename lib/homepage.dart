import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/beranda_page.dart';
import 'pages/laporan_page.dart';
import 'pages/profil_page.dart';
import 'pages/exercise_list_page.dart';
import 'controllers/home_controller.dart';
import 'controllers/user_controller.dart';
import 'routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final UserController userController = Get.find<UserController>();

    const bgColor = Color(0xFF0D0F14);
    const surfaceColor = Color(0xFF1C2030);
    const borderColor = Color(0xFF2A2F45);
    const accentGreen = Color(0xFF67C23A);
    const accentPurple = Color(0xFF7C6AF7);
    const textSecondary = Color(0xFF6B7280);
    const textPrimary = Color(0xFFE8EAF2);

    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            BerandaPage(colorScheme: Theme.of(context).colorScheme),
            const LaporanPage(),
            const ExerciseListPage(),

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
                icon: Icon(Icons.show_chart_outlined),
                activeIcon: Icon(Icons.show_chart),
                label: 'Progres',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Latihan',
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
