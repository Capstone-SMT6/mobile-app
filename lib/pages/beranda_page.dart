import 'package:flutter/material.dart';

const _bg = Color(0xFF13151B);
const _surface = Color(0xFF232533);
const _green = Color(0xFF67C23A);
const _textPrimary = Colors.white;
const _textSecondary = Color(0xFFA1A3B0);
const _border = Color(0xFF2A2F45);

// ── Static data (swap with controller later) ──────────────────────
const bool _isRestDay = false;
const int _streakDays = 13;
const int _caloriesBurned = 0;
const int _caloriesTarget = 300;
const int _workoutsDone = 0;
const int _workoutsTotal = 6;
const int _glassesConsumed = 3;
const int _glassesTarget = 8;

class BerandaPage extends StatelessWidget {
  final ColorScheme colorScheme;
  const BerandaPage({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMissionSection(),
              _buildWorkoutListSection(),
              const SizedBox(height: 24),
              _buildHydrationSection(),
              const SizedBox(height: 24),
              _buildQuickAccessSection(),
              const SizedBox(height: 24),
              _buildNextWorkoutSection(),
              const SizedBox(height: 24),
              _buildWeeklySummarySection(),
              const SizedBox(height: 24),
              _buildWeightTrendSection(),
              const SizedBox(height: 24),
              _buildHealthTipSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Builders ───────────────────────────────────────────

  Widget _buildMissionSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _isRestDay ? _buildRestDayCard() : _buildWorkoutMissionCard(),
    );
  }

  Widget _buildRestDayCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MISI HARI INI',
            style: TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('😴', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Istirahat',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tubuhmu perlu waktu untuk pulih. Nikmati istirahatmu!',
                      style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutMissionCard() {
    final calorieProgress = _caloriesBurned / _caloriesTarget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MISI HARI INI',
          style: TextStyle(
            color: _green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Otot Kaki',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '6 Latihan · 30 Menit',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 20),

        // Streak row with flame icon
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '$_streakDays Hari ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'streak aktif',
                      style: TextStyle(color: _textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Calorie progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Kalori Terbakar',
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),
            ),
            Text(
              '$_caloriesBurned / $_caloriesTarget kcal',
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: calorieProgress,
            minHeight: 7,
            backgroundColor: _border,
            valueColor: const AlwaysStoppedAnimation<Color>(_green),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: 140,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Mulai Latihan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutListSection() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latihan Hari Ini',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_workoutsDone/$_workoutsTotal selesai',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Semangat Berolahraga',
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Workout completion progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _workoutsDone / _workoutsTotal,
              minHeight: 4,
              backgroundColor: _border,
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          _workoutItem('SQUAT', '3 X 12', false),
          const Divider(color: Colors.white24, height: 1),
          _workoutItem('LUNGE', '3 X 12', false),
          const Divider(color: Colors.white24, height: 1),
          _workoutItem('STEP-UPS', '3 X 12', false),
          const Divider(color: Colors.white24, height: 1),
        ],
      ),
    );
  }

  Widget _buildNextWorkoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latihan Besok',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.purple, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Day — Dada & Bahu',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '5 Latihan · 40 Menit',
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationSection() {
    final hydrationProgress = _glassesConsumed / _glassesTarget;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Hidrasi Hari Ini',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '$_glassesConsumed/$_glassesTarget gelas',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: hydrationProgress,
                      minHeight: 7,
                      backgroundColor: _border,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Glass emoji indicators
                  Row(
                    children: List.generate(
                      _glassesTarget,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '💧',
                          style: TextStyle(
                            fontSize: 12,
                            color: i < _glassesConsumed ? Colors.blue : Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Mingguan',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Aktivitas', '4 Hari', Icons.local_fire_department),
              const SizedBox(width: 12),
              _buildStatCard('Kalori', '1,240 kcal', Icons.whatshot),
              const SizedBox(width: 12),
              _buildStatCard('Waktu', '2j 15m', Icons.timer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTrendSection() {
    const weights = [74.5, 74.0, 73.8, 73.5, 73.2, 72.9];
    const minW = 72.0;
    const maxW = 75.5;

    const String bmiCategory = 'Normal';
    const Color bmiColor = _green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Tren Berat Badan & BMI',
                  style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '↓ 1.6 kg bulan ini',
                  style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                // BMI summary row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BMI Saat Ini', style: TextStyle(color: _textSecondary, fontSize: 11)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '23.8',
                                style: TextStyle(color: _textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: bmiColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  bmiCategory,
                                  style: TextStyle(color: bmiColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('Berat Badan', style: TextStyle(color: _textSecondary, fontSize: 11)),
                        SizedBox(height: 4),
                        Text('72.9 kg', style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Tinggi: 175 cm', style: TextStyle(color: _textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // BMI scale with triangle pointer
                LayoutBuilder(
                  builder: (context, constraints) {
                    const double bmiValue = 23.8;
                    final double pos = _bmiPosition(bmiValue, constraints.maxWidth);
                    final Color indColor = _bmiColor(bmiValue);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Triangle pointer
                        SizedBox(
                          height: 10,
                          width: constraints.maxWidth,
                          child: CustomPaint(
                            painter: _BmiIndicatorPainter(x: pos, color: indColor),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Scale bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 8,
                            child: Row(
                              children: [
                                Expanded(flex: 185, child: Container(color: Colors.blue)),
                                Expanded(flex: 50, child: Container(color: _green)),
                                Expanded(flex: 50, child: Container(color: Colors.orange)),
                                Expanded(flex: 15, child: Container(color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('<18.5', style: TextStyle(color: Colors.blue, fontSize: 9)),
                            Text('18.5–24.9', style: TextStyle(color: _green, fontSize: 9)),
                            Text('25–29.9', style: TextStyle(color: Colors.orange, fontSize: 9)),
                            Text('≥30', style: TextStyle(color: Colors.red, fontSize: 9)),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const Divider(color: Colors.white12, height: 24),

                // Line chart
                SizedBox(
                  height: 80,
                  child: CustomPaint(
                    painter: _LineChartPainter(values: weights, min: minW, max: maxW, color: _green),
                    size: const Size(double.infinity, 80),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    weights.length,
                    (i) => Text('M${i + 1}', style: const TextStyle(color: _textSecondary, fontSize: 10)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Awal: ${weights.first} kg', style: const TextStyle(color: _textSecondary, fontSize: 11)),
                    Text(
                      'Sekarang: ${weights.last} kg',
                      style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akses Cepat',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickAction(Icons.water_drop_outlined, 'Air Minum', Colors.blue),
              const SizedBox(width: 12),
              _buildQuickAction(Icons.restaurant_menu, 'Nutrisi', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickAction(Icons.monitor_weight_outlined, 'Berat Badan', Colors.purple),
              const SizedBox(width: 12),
              _buildQuickAction(Icons.camera_alt_outlined, 'Foto Progress', Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tip Kesehatan',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2F45), _surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: _green, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pentingnya Pemanasan',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lakukan pemanasan dinamis 5-10 menit sebelum mulai angkat beban untuk mencegah cedera sendi.',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                          height: 1.4,
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
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _green, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(color: _textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workoutItem(String title, String reps, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: done ? _textSecondary : _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reps,
                  style: TextStyle(
                    color: done ? _textSecondary : _textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? _green : Colors.transparent,
              border: Border.all(
                color: done ? _green : Colors.white24,
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Mini Line Chart Painter ────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double min;
  final double max;
  final Color color;

  _LineChartPainter({
    required this.values,
    required this.min,
    required this.max,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final range = max - min;
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1));
      final y = size.height - ((values[i] - min) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Draw filled area under line
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()..color = color;
    final dotBorderPaint = Paint()
      ..color = _bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── BMI Triangle Indicator ─────────────────────────────────────────
double _bmiPosition(double bmi, double totalWidth) {
  const totalFlex = 300.0;
  double flexPos;
  if (bmi < 18.5) {
    flexPos = ((bmi - 10.0) / 8.5) * 185;
  } else if (bmi < 25) {
    flexPos = 185 + ((bmi - 18.5) / 6.5) * 50;
  } else if (bmi < 30) {
    flexPos = 235 + ((bmi - 25) / 5.0) * 50;
  } else {
    flexPos = 285 + ((bmi - 30) / 10.0) * 15;
  }
  return (flexPos.clamp(0, totalFlex) / totalFlex) * totalWidth;
}

Color _bmiColor(double bmi) {
  if (bmi < 18.5) return Colors.blue;
  if (bmi < 25) return _green;
  if (bmi < 30) return Colors.orange;
  return Colors.red;
}

class _BmiIndicatorPainter extends CustomPainter {
  final double x;
  final Color color;

  const _BmiIndicatorPainter({required this.x, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const halfBase = 5.0;
    final path = Path()
      ..moveTo(x - halfBase, 0)
      ..lineTo(x + halfBase, 0)
      ..lineTo(x, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
