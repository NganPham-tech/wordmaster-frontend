
class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime joinDate;
  final String level;
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final int totalCardsLearned;
  final int totalQuizzesCompleted;
  final double averageAccuracy;
  final String? bio;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.joinDate,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.totalCardsLearned,
    required this.totalQuizzesCompleted,
    required this.averageAccuracy,
    this.bio,
  });

  String get fullName => '$firstName $lastName';
  int get levelNumber => int.tryParse(level) ?? 1;
}

class StudyStat {
  final DateTime date;
  final int minutesStudied;
  final int cardsLearned;
  final int quizzesCompleted;

  StudyStat({
    required this.date,
    required this.minutesStudied,
    required this.cardsLearned,
    required this.quizzesCompleted,
  });
}

class RecentActivity {
  final String id;
  final String type; 
  final String title;
  final String description;
  final DateTime timestamp;
  final String? score;
  final String? deckName;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.score,
    this.deckName,
  });
}