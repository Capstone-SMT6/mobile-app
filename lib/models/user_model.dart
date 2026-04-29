class User {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;
  final bool notificationEnabled;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.notificationEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
    );
  }
}

class UserStats {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int totalPushUps;
  final int totalSitUps;

  UserStats({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPushUps,
    required this.totalSitUps,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalPushUps: json['totalPushUps'] as int? ?? 0,
      totalSitUps: json['totalSitUps'] as int? ?? 0,
    );
  }
}

class UserFitnessProfile {
  final String id;
  final String userId;
  final String goal;
  final String durationTarget;
  final int age;
  final double height;
  final double weight;
  final String skillLevel;
  final String intensity;

  UserFitnessProfile({
    required this.id,
    required this.userId,
    required this.goal,
    required this.durationTarget,
    required this.age,
    required this.height,
    required this.weight,
    required this.skillLevel,
    required this.intensity,
  });

  factory UserFitnessProfile.fromJson(Map<String, dynamic> json) {
    return UserFitnessProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      goal: json['goal'] as String,
      durationTarget: json['durationTarget'] as String,
      age: json['age'] as int,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      skillLevel: json['skillLevel'] as String,
      intensity: json['intensity'] as String,
    );
  }

  String get goalFormatted {
    switch (goal) {
      case 'weight_loss': return 'Weight Loss';
      case 'muscle_gain': return 'Muscle Gain';
      case 'maintain': return 'Maintain Weight';
      default: return goal;
    }
  }
}
