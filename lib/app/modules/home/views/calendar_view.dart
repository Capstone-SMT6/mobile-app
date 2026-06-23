import 'package:smacofit/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smacofit/app/data/services/workout_service.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarView> {
  DateTime today = DateTime.now();
  late final Future<ActiveExercisePlan> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = WorkoutService.getActiveExercisePlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: const Text(
          "Jadwal Latihan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<ActiveExercisePlan>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentGreen),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Belum ada jadwal latihan. Selesaikan onboarding terlebih dahulu.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            );
          }

          final plan = snapshot.data!;
          final workouts = plan.exercisesForDate(today);

          return Stack(
            children: [
              // Ambient backgrounds
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentGreen.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                left: -120,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentPurple.withValues(alpha: 0.03),
                  ),
                ),
              ),
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 4,
                      bottom: 16,
                    ),
                    padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [surfaceColor, bgColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: accentGreen.withValues(alpha: 0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      focusedDay: today,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      selectedDayPredicate: (day) => isSameDay(day, today),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          today = selectedDay;
                        });
                      },
                      sixWeekMonthsEnforced: true,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      eventLoader: (day) => plan.exercisesForDate(day),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        headerPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        weekendStyle: TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      rowHeight: 48,
                      calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        weekendTextStyle: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.w500),
                        outsideTextStyle: TextStyle(color: Colors.white24),
                        markersMaxCount: 1,
                      ),
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [accentGreen, accentGreen],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentGreen.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accentGreen.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return const SizedBox.shrink();
                          final isSelected = isSameDay(day, today);
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.white : accentGreen,
                                boxShadow: isSelected
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: accentGreen.withValues(alpha: 0.6),
                                          blurRadius: 3,
                                        ),
                                      ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                      decoration: const BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 48,
                              height: 4.5,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isSameDay(today, DateTime.now())
                                    ? "Jadwal Hari Ini"
                                    : "Jadwal ${today.day}/${today.month}/${today.year}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (workouts.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: accentGreen.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    "${workouts.length} Latihan",
                                    style: const TextStyle(
                                      color: accentGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: workouts.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(22),
                                            decoration: BoxDecoration(
                                              color: surfaceColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.05),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.25),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.spa_outlined,
                                              size: 44,
                                              color: accentGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          const Text(
                                            "Hari ini adalah hari istirahat",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 36),
                                            child: Text(
                                              "Waktunya memulihkan energi dan memperbaiki jaringan otot untuk performa maksimal berikutnya! 🔋",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 13,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    itemCount: workouts.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = workouts[index];
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: surfaceColor,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.04),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                bottom: 0,
                                                width: 4,
                                                child: Container(
                                                  color: accentGreen,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 18,
                                                  right: 16,
                                                  top: 14,
                                                  bottom: 14,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: accentGreen.withValues(alpha: 0.12),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons.fitness_center,
                                                        color: accentGreen,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            item.name,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            item.targetText,
                                                            style: const TextStyle(
                                                              color: accentGreen,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.white30,
                                                      size: 26,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
