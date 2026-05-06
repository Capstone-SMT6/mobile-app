import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime today = DateTime.now();

  final Map<DateTime, List<String>> workoutData = {
    DateTime.utc(2026, 5, 5): ["Push Up", "Sit Up", "Plank"],
    DateTime.utc(2026, 5, 6): ["Pull Up", "Squat", "Lunges"],
  };

  List<String> getWorkoutForDay(DateTime date) {
    return workoutData[DateTime.utc(date.year, date.month, date.day)] ?? [];
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CALENDAR
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
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
              sixWeekMonthsEnforced: true, // Mencegah kalender melompat-lompat saat ganti bulan
              availableGestures: AvailableGestures.horizontalSwipe, // Mencegah format berantakan
              eventLoader: (day) => getWorkoutForDay(day),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                headerPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white70, fontSize: 13),
                weekendStyle: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              rowHeight: 46, // Sedikit mengecilkan tinggi sel agar tidak makan tempat
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
                outsideTextStyle: TextStyle(color: Colors.white24),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF222434),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Color(0xFF6CC551), width: 1.5)),
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF6CC551),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Color(0xFF7C6AF7), // Marker ungu untuk hari yang ada latihannya
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
              ),
            ),
          ),

          // LIST LATIHAN
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF171925),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: getWorkoutForDay(today).isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.event_busy, size: 56, color: Colors.white24),
                                SizedBox(height: 16),
                                Text(
                                  "Tidak ada latihan untuk hari ini",
                                  style: TextStyle(color: Colors.white54, fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: getWorkoutForDay(today).length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = getWorkoutForDay(today)[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                        color: const Color(0xFF6CC551).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.fitness_center, color: Color(0xFF6CC551), size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.play_circle_fill, color: Colors.white24, size: 28),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
