import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/workout_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
      backgroundColor: const Color(0xFF0D0F14), // Latar belakang gelap premium
      appBar: AppBar(
        title: const Text(
          "Workout Calendar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<ActiveExercisePlan>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6CC551)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Belum ada jadwal latihan. Selesaikan onboarding terlebih dahulu.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            );
          }

          final plan = snapshot.data!;
          final workouts = plan.exercisesForDate(today);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 4,
                  bottom: 12,
                ),
                padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF222434),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
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
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    weekendStyle: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                  rowHeight: 46,
                  calendarStyle: const CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.redAccent),
                    outsideTextStyle: TextStyle(color: Colors.white24),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF222434),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0xFF6CC551), width: 1.5),
                      ),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF6CC551),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Color(0xFF7C6AF7),
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF171925),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jadwal Hari Ini",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: workouts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.event_busy,
                                      size: 56,
                                      color: Colors.white24,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Hari ini adalah hari istirahat",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF222434),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF6CC551,
                                            ).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.fitness_center,
                                            color: Color(0xFF6CC551),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.targetText,
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white24,
                                          size: 28,
                                        ),
                                      ],
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
          );
        },
      ),
    );
  }
}
