import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/onboarding_controller.dart' as import_controller;

class OnboardingWeightPage extends StatefulWidget {
  const OnboardingWeightPage({super.key});

  @override
  State<OnboardingWeightPage> createState() => _OnboardingWeightPageState();
}

class _OnboardingWeightPageState extends State<OnboardingWeightPage> {
  static const int minWeight = 30;
  static const int maxWeight = 200;
  static const double pixelsPerKg = 24.0;

  int selectedWeight = 60;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: (selectedWeight - minWeight) * pixelsPerKg,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final newW = (minWeight + _scrollController.offset / pixelsPerKg)
        .round()
        .clamp(minWeight, maxWeight);
    if (newW != selectedWeight) setState(() => selectedWeight = newW);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Compute label positions relative to the viewport center
  List<Widget> _buildNumberLabels(double width) {
    final List<Widget> widgets = [];
    final int visibleKg = (width / 2 / pixelsPerKg).ceil() + 1;
    final int startVal = selectedWeight - visibleKg;
    final int endVal = selectedWeight + visibleKg;

    for (int v = startVal; v <= endVal; v++) {
      if (v < minWeight || v > maxWeight) continue;
      if (v % 5 != 0) continue;
      // Center the text (assume text width is around 24px)
      final double leftOffset =
          width / 2 + (v - selectedWeight) * pixelsPerKg - 12;
      if (leftOffset < -30 || leftOffset > width + 10) continue;
      widgets.add(Positioned(
        left: leftOffset,
        top: 0,
        child: SizedBox(
          width: 24,
          child: Text(
            '$v',
            style: TextStyle(
              fontSize: 13,
              fontWeight: v == selectedWeight || (v - selectedWeight).abs() <= 2
                  ? FontWeight.w500
                  : FontWeight.w400,
              color: (v - selectedWeight).abs() <= 2
                  ? Colors.white70
                  : Colors.white30,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget _buildRulerArea(double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Center: dark ruler box with tick marks
        Container(
          width: width,
          height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1C27),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / 2),
                      child: CustomPaint(
                        size: Size((maxWeight - minWeight) * pixelsPerKg, 90),
                        painter: _HorizontalRulerTicksPainter(
                          minWeight: minWeight,
                          maxWeight: maxWeight,
                          pixelsPerKg: pixelsPerKg,
                          selectedWeight: selectedWeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Fixed green center line
              Container(
                width: 2,
                color: const Color(0xFF6CC551),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Bottom: number labels and pointing triangle
        SizedBox(
          width: width,
          height: 30,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ..._buildNumberLabels(width),
              const Positioned(
                top: -12,
                child: Icon(Icons.arrow_drop_up, color: Colors.white38, size: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Sma',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'Fit',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6CC551),
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Rancang Rencana Kamu Sendiri",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Berapa berat badan kamu?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              _buildRulerArea(screenWidth),
              const SizedBox(height: 32),
              Text(
                '$selectedWeight KG',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
                  ],
                ),
              ),
            ),
            
            // Bottom section pinned
            Column(
              children: [
                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Sebelumnya",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final onboardingController = Get.find<import_controller.OnboardingController>();
                        onboardingController.beratBadan.value = selectedWeight.toDouble();
                        Get.toNamed(AppRoutes.onboardingExpertise);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Selanjutnya",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Pagination Dots (5th dot active = index 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 4 ? Colors.white : Colors.white24,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalRulerTicksPainter extends CustomPainter {
  final int minWeight;
  final int maxWeight;
  final double pixelsPerKg;
  final int selectedWeight;

  const _HorizontalRulerTicksPainter({
    required this.minWeight,
    required this.maxWeight,
    required this.pixelsPerKg,
    required this.selectedWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = minWeight; i <= maxWeight; i++) {
      final double x = (i - minWeight) * pixelsPerKg;

      double lineHeight;
      Color color;
      double strokeWidth;

      if (i % 10 == 0) {
        lineHeight = size.height * 0.85;
        color = Colors.white70;
        strokeWidth = 1.5;
      } else if (i % 5 == 0) {
        lineHeight = size.height * 0.60;
        color = Colors.white54;
        strokeWidth = 1.0;
      } else {
        lineHeight = size.height * 0.35;
        color = Colors.white24;
        strokeWidth = 0.8;
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth;

      // Draw lines from bottom edge towards top
      canvas.drawLine(
        Offset(x, size.height - lineHeight),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HorizontalRulerTicksPainter old) =>
      old.selectedWeight != selectedWeight;
}
