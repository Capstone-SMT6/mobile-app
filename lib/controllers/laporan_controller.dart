import 'package:get/get.dart';

class LaporanController extends GetxController {
  final RxInt selectedExercise = 0.obs;
  final RxInt selectedTab = 0.obs;

  final List<String> exercises = [
    'Push-up',
    'Squat',
    'Pull-up',
    'Bench Press',
    'Deadlift',
  ];

  final List<Map<String, dynamic>> topEntries = [
    {'rank': 1, 'name': 'MuscleKing99', 'score': 4250, 'you': false},
    {'rank': 2, 'name': 'IronWolf', 'score': 3980, 'you': false},
    {'rank': 3, 'name': 'ZenLifter', 'score': 3710, 'you': false},
    {'rank': 4, 'name': 'You', 'score': 2840, 'you': true},
    {'rank': 5, 'name': 'PowerPulse', 'score': 2560, 'you': false},
    {'rank': 6, 'name': 'FitFreak21', 'score': 2310, 'you': false},
    {'rank': 7, 'name': 'GrindMode', 'score': 2100, 'you': false},
    {'rank': 8, 'name': 'AlphaAthlete', 'score': 1980, 'you': false},
    {'rank': 9, 'name': 'BeastMode', 'score': 1750, 'you': false},
    {'rank': 10, 'name': 'SweatEquity', 'score': 1620, 'you': false},
  ];

  void selectExercise(int index) {
    selectedExercise.value = index;
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }
}
