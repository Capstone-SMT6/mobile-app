import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class OnboardingHeightPage extends StatefulWidget {
  const OnboardingHeightPage({super.key});

  @override
  State<OnboardingHeightPage> createState() => _OnboardingHeightPageState();
}

class _OnboardingHeightPageState extends State<OnboardingHeightPage> {
  static const int minHeight = 100;
  static const int maxHeight = 250;
  static const double pixelsPerCm = 24.0;
  static const double viewportHeight = 280.0;

  int selectedHeight = 170;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: (selectedHeight - minHeight) * pixelsPerCm,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final newH = (minHeight + _scrollController.offset / pixelsPerCm)
        .round()
        .clamp(minHeight, maxHeight);
    if (newH != selectedHeight) setState(() => selectedHeight = newH);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Compute label positions relative to the viewport center
  List<Widget> _buildNumberLabels() {
    final List<Widget> widgets = [];
    final int visibleCm = (viewportHeight / 2 / pixelsPerCm).ceil() + 1;
    final int startVal = selectedHeight - visibleCm;
    final int endVal = selectedHeight + visibleCm;

    for (int v = startVal; v <= endVal; v++) {
      if (v < minHeight || v > maxHeight) continue;
      if (v % 5 != 0) continue;
      final double topOffset =
          viewportHeight / 2 + (v - selectedHeight) * pixelsPerCm - 10;
      if (topOffset < -20 || topOffset > viewportHeight) continue;
      widgets.add(Positioned(
        top: topOffset,
        right: 0,
        child: Text(
          '$v',
          style: TextStyle(
            fontSize: 13,
            fontWeight: v == selectedHeight || (v - selectedHeight).abs() <= 2
                ? FontWeight.w500
                : FontWeight.w400,
            color: (v - selectedHeight).abs() <= 2
                ? Colors.white70
                : Colors.white30,
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget _buildRulerArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left: number labels
        SizedBox(
          width: 44,
          height: viewportHeight,
          child: Stack(children: _buildNumberLabels()),
        ),
        const SizedBox(width: 8),
        // Center: dark ruler box with tick marks
        Container(
          width: 90,
          height: viewportHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C27),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: viewportHeight / 2),
                      child: CustomPaint(
                        size: Size(90, (maxHeight - minHeight) * pixelsPerCm),
                        painter: _RulerTicksPainter(
                          minHeight: minHeight,
                          maxHeight: maxHeight,
                          pixelsPerCm: pixelsPerCm,
                          selectedHeight: selectedHeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Fixed green center line
              Container(
                height: 2,
                color: const Color(0xFF6CC551),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Right: pointing triangle
        const Icon(Icons.arrow_left, color: Colors.white38, size: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            "Berapa tinggi badan kamu?",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildRulerArea(),
                    const SizedBox(height: 32),
                    Text(
                      '$selectedHeight CM',
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
                        Get.toNamed(AppRoutes.onboardingWeight);
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

                // Pagination Dots (4th dot active = index 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(9, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 3 ? Colors.white : Colors.white24,
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

class _RulerTicksPainter extends CustomPainter {
  final int minHeight;
  final int maxHeight;
  final double pixelsPerCm;
  final int selectedHeight;

  const _RulerTicksPainter({
    required this.minHeight,
    required this.maxHeight,
    required this.pixelsPerCm,
    required this.selectedHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = minHeight; i <= maxHeight; i++) {
      final double y = (i - minHeight) * pixelsPerCm;

      double lineWidth;
      Color color;
      double strokeWidth;

      if (i % 10 == 0) {
        lineWidth = size.width * 0.85;
        color = Colors.white70;
        strokeWidth = 1.5;
      } else if (i % 5 == 0) {
        lineWidth = size.width * 0.60;
        color = Colors.white54;
        strokeWidth = 1.0;
      } else {
        lineWidth = size.width * 0.35;
        color = Colors.white24;
        strokeWidth = 0.8;
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth;

      // Draw lines from right edge towards left
      canvas.drawLine(
        Offset(size.width - lineWidth, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RulerTicksPainter old) =>
      old.selectedHeight != selectedHeight;
}
