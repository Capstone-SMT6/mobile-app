import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/modules/home/views/beranda_view.dart';
import 'package:mobile_app/app/modules/home/views/laporan_view.dart';
import 'package:mobile_app/app/modules/home/views/profil_view.dart';
import 'package:mobile_app/app/modules/workout/views/exercise_list_view.dart';
import 'package:mobile_app/app/modules/nutrition/views/nutrition_view.dart';
import 'package:mobile_app/app/modules/home/controllers/home_controller.dart';
import 'package:mobile_app/app/routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    const bgColor = Color(0xFF0D0F14);
    const surfaceColor = Color(0xFF1C2030);
    const borderColor = Color(0xFF2A2F45);
    const accentGreen = Color(0xFF67C23A);
    const accentPurple = Color(0xFF7C6AF7);
    const textSecondary = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            BerandaView(colorScheme: Theme.of(context).colorScheme),
            const LaporanView(),
            const ExerciseListView(),
            const NutritionView(),
            const ProfilView(),
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
                icon: Icon(Icons.restaurant_menu_outlined),
                activeIcon: Icon(Icons.restaurant_menu),
                label: 'Nutrisi',
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
