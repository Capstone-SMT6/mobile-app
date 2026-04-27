import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class OnboardingInjuryPage extends StatefulWidget {
  const OnboardingInjuryPage({super.key});

  @override
  State<OnboardingInjuryPage> createState() => _OnboardingInjuryPageState();
}

class _OnboardingInjuryPageState extends State<OnboardingInjuryPage> {
  BodyParts _selectedParts = const BodyParts();

  // Map each BodyParts field to a user-facing Indonesian label.
  static const Map<String, String> _partLabels = {
    'head': 'Kepala',
    'neck': 'Leher',
    'leftShoulder': 'Bahu Kiri',
    'rightShoulder': 'Bahu Kanan',
    'leftUpperArm': 'Lengan Atas Kiri',
    'rightUpperArm': 'Lengan Atas Kanan',
    'leftElbow': 'Siku Kiri',
    'rightElbow': 'Siku Kanan',
    'leftLowerArm': 'Lengan Bawah Kiri',
    'rightLowerArm': 'Lengan Bawah Kanan',
    'leftHand': 'Tangan Kiri',
    'rightHand': 'Tangan Kanan',
    'upperBody': 'Punggung Atas',
    'lowerBody': 'Punggung Bawah',
    'abdomen': 'Perut',
    'vestibular': 'Pinggang',
    'leftUpperLeg': 'Paha Kiri',
    'rightUpperLeg': 'Paha Kanan',
    'leftKnee': 'Lutut Kiri',
    'rightKnee': 'Lutut Kanan',
    'leftLowerLeg': 'Betis Kiri',
    'rightLowerLeg': 'Betis Kanan',
    'leftFoot': 'Kaki Kiri',
    'rightFoot': 'Kaki Kanan',
  };

  /// Returns the Indonesian labels for every currently selected part.
  List<String> get _selectedLabels {
    final map = _selectedParts.toMap();
    return map.entries
        .where((e) => e.value)
        .map((e) => _partLabels[e.key] ?? e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable body ──
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

                          // Logo
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
                            "Apakah kamu memiliki cedera\natau rasa sakit? (opsional)",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Hint text
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222434),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.info_outline,
                                    color: Color(0xFF6CC551), size: 16),
                                SizedBox(width: 8),
                                Text(
                                  "Ketuk bagian tubuh yang cedera",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Interactive body map ──
                          // Fixed height required — BodyPartSelectorTurnable
                          // uses Expanded internally and crashes in an unbounded
                          // scroll context without explicit constraints.
                          SizedBox(
                            height: 420,
                            child: BodyPartSelectorTurnable(
                              bodyParts: _selectedParts,
                              onSelectionUpdated: (parts) {
                                setState(() {
                                  _selectedParts = parts;
                                });
                              },
                              selectedColor: Colors.redAccent,
                              unselectedColor:
                                  const Color(0xFF222434).withValues(alpha: 0.6),
                              labelData: const RotationStageLabelData(
                                front: 'Depan',
                                left: 'Kiri',
                                right: 'Kanan',
                                back: 'Balik',
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Dynamic selected-parts indicator ──
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: _selectedLabels.isEmpty
                                ? const SizedBox.shrink()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Bagian yang cedera:",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _selectedLabels
                                            .map(
                                              (label) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.redAccent
                                                        .withValues(alpha: 0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.circle,
                                                      color: Colors.redAccent,
                                                      size: 7,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      label,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.redAccent,
                                                size: 15),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                "Program akan disesuaikan agar aman untuk bagian ini",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.redAccent
                                                      .shade100,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Pinned bottom controls ──
            Column(
              children: [
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Sebelumnya",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Injury is optional, proceed to equipment
                        Get.toNamed(AppRoutes.onboardingEquipment);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Selanjutnya",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Pagination dots (9 dots now, this is 8th → index 7)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(9, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 7 ? Colors.white : Colors.white24,
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
