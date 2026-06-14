import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/core/theme/app_colors.dart';
import 'package:mobile_app/app/modules/nutrition/controllers/nutrition_controller.dart';
import 'package:mobile_app/app/data/models/nutrition_model.dart';

class AddFoodLogView extends StatefulWidget {
  const AddFoodLogView({super.key});

  @override
  State<AddFoodLogView> createState() => _AddFoodLogViewState();
}

class _AddFoodLogViewState extends State<AddFoodLogView> {
  final TextEditingController _searchController = TextEditingController();
  final NutritionController controller = Get.find<NutritionController>();
  String _selectedCat = ''; // '' for All
  final Map<String, FoodItem> _selectedFoods = {};
  final Map<String, double> _selectedQuantities = {};
  final Set<String> _expandedFoodIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch initial catalog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchFoodItems('', '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Tambah Makanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          _buildCategoryFilters(),
          Expanded(
            child: Obx(() {
              if (controller.searchLoading.value) {
                return const Center(child: CircularProgressIndicator(color: accentGreen));
              }

              final results = controller.searchResults;
              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search_off, size: 64, color: textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'Makanan tidak ditemukan.',
                        style: TextStyle(color: textSecondary, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Silakan cari kata kunci lain.',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final food = results[index];
                  final isExpanded = _expandedFoodIds.contains(food.id);
                  return Card(
                    color: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: borderColor),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: food.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    food.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Container(
                                      width: 48,
                                      height: 48,
                                      color: borderColor,
                                      child: const Icon(Icons.fastfood, color: textSecondary),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: borderColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.fastfood, color: textSecondary),
                                ),
                          title: Text(
                            food.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '${food.caloriesPerServing.round()} kcal per ${food.servingUnit}',
                            style: const TextStyle(fontSize: 12, color: textSecondary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if ((_selectedQuantities[food.id] ?? 0.0) > 0) ...[
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                                  onPressed: () {
                                    setState(() {
                                      final current = _selectedQuantities[food.id] ?? 0.0;
                                      if (current <= 1.0) {
                                        _selectedQuantities.remove(food.id);
                                        _selectedFoods.remove(food.id);
                                      } else {
                                        _selectedQuantities[food.id] = current - 1.0;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  (_selectedQuantities[food.id] ?? 0.0).toStringAsFixed(1).replaceAll('.0', ''),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: accentGreen),
                                onPressed: () {
                                  setState(() {
                                    _selectedFoods[food.id] = food;
                                    final current = _selectedQuantities[food.id] ?? 0.0;
                                    _selectedQuantities[food.id] = current + 1.0;
                                  });
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedFoodIds.remove(food.id);
                              } else {
                                _expandedFoodIds.add(food.id);
                              }
                            });
                          },
                        ),
                        if (isExpanded) ...[
                          const Divider(color: borderColor, height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMiniStat('Protein', '${food.proteinPerServing.round()}g', Colors.orange),
                                _buildMiniStat('Karbohidrat', '${food.carbsPerServing.round()}g', Colors.blue),
                                _buildMiniStat('Lemak', '${food.fatPerServing.round()}g', Colors.redAccent),
                                if (food.servingSizeG != null)
                                  _buildMiniStat('Berat', '${food.servingSizeG!.round()}g', Colors.teal),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _selectedQuantities.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: surfaceColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedQuantities.length} Item Terpilih',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            'Total Kalori: ${_calculateTotalCalories().round()} kcal',
                            style: const TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showMealTypeSelectionSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: bgColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Obx(() => controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: bgColor, strokeWidth: 2),
                            )
                          : const Text(
                              'Pilih Waktu Makan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari nasi goreng, ayam bakar, kopi...',
          hintStyle: const TextStyle(color: textSecondary),
          prefixIcon: const Icon(Icons.search, color: textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchFoodItems('', _selectedCat);
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: bgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentGreen),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (val) {
          controller.searchFoodItems(val, _selectedCat);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      {'label': 'Semua', 'val': ''},
      {'label': 'Makanan', 'val': 'makanan'},
      {'label': 'Minuman', 'val': 'minuman'},
      {'label': 'Camilan', 'val': 'snack'},
    ];

    return Container(
      height: 48,
      color: surfaceColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCat == cat['val'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: TextStyle(
                  color: isSelected ? bgColor : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCat = cat['val']!;
                  });
                  controller.searchFoodItems(_searchController.text, _selectedCat);
                }
              },
              selectedColor: accentGreen,
              backgroundColor: borderColor,
              checkmarkColor: bgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  double _calculateTotalCalories() {
    double total = 0.0;
    _selectedQuantities.forEach((id, qty) {
      final food = _selectedFoods[id];
      if (food != null) {
        total += food.caloriesPerServing * qty;
      }
    });
    return total;
  }

  void _showMealTypeSelectionSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Waktu Makan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Catat semua makanan terpilih ke waktu makan berikut:',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildMealTypeTile(context, 'breakfast', 'Sarapan', Icons.wb_sunny_outlined),
            _buildMealTypeTile(context, 'lunch', 'Makan Siang', Icons.wb_cloudy_outlined),
            _buildMealTypeTile(context, 'dinner', 'Makan Malam', Icons.nights_stay_outlined),
            _buildMealTypeTile(context, 'snack', 'Camilan', Icons.local_cafe_outlined),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeTile(BuildContext context, String value, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: accentGreen),
      title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: textSecondary),
      onTap: () {
        Get.back(); // Close bottom sheet
        controller.logMultipleFoodItems(
          items: _selectedQuantities,
          mealType: value,
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: textSecondary),
        ),
      ],
    );
  }
}
