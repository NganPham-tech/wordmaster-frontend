enum AchievementCategory { learning, streak, quiz, mastery, special }

enum RequirementType {
  cardsLearned,
  cardsMastered,
  streakDays,
  quizPerfect,
  totalPoints,
}

class Achievement {
  final int? achievementID;
  final String name;
  final String? description;
  final String? iconPath;
  final AchievementCategory category;
  final RequirementType requirementType;
  final int requirementValue;
  final int points;
  final int sortOrder;

  Achievement({
    this.achievementID,
    required this.name,
    this.description,
    this.iconPath,
    this.category = AchievementCategory.learning,
    required this.requirementType,
    required this.requirementValue,
    this.points = 10,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'AchievementID': achievementID,
      'Name': name,
      'Description': description,
      'IconPath': iconPath,
      'Category': category.toString().split('.').last,
      'RequirementType': requirementType
          .toString()
          .split('.')
          .last
          .toLowerCase(),
      'RequirementValue': requirementValue,
      'Points': points,
      'SortOrder': sortOrder,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      achievementID: map['AchievementID'],
      name: map['Name'],
      description: map['Description'],
      iconPath: map['IconPath'],
      category: AchievementCategory.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (map['Category']?.toString().toLowerCase() ?? 'learning'),
        orElse: () => AchievementCategory.learning,
      ),
      requirementType: RequirementType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (map['RequirementType']?.toString().toLowerCase() ??
                'cardslearned'),
        orElse: () => RequirementType.cardsLearned,
      ),
      requirementValue: map['RequirementValue'] ?? 0,
      points: map['Points'] ?? 10,
      sortOrder: map['SortOrder'] ?? 0,
    );
  }
}

class UserAchievement {
  final int? userAchievementID;
  final int userID;
  final int achievementID;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserAchievement({
    this.userAchievementID,
    required this.userID,
    required this.achievementID,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserAchievementID': userAchievementID,
      'UserID': userID,
      'AchievementID': achievementID,
      'Progress': progress,
      'IsUnlocked': isUnlocked,
      'UnlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      userAchievementID: map['UserAchievementID'],
      userID: map['UserID'],
      achievementID: map['AchievementID'],
      progress: map['Progress'] ?? 0,
      isUnlocked: map['IsUnlocked'] == 1 || map['IsUnlocked'] == true,
      unlockedAt: map['UnlockedAt'] != null
          ? DateTime.parse(map['UnlockedAt'])
          : null,
    );
  }
}

class UserProgress {
  final int? progressID;
  final int userID;
  final int totalLearned;
  final int totalMastered;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActiveDate;
  final int totalPoints;
  final int level;
  final int perfectQuizCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProgress({
    this.progressID,
    required this.userID,
    this.totalLearned = 0,
    this.totalMastered = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate,
    this.totalPoints = 0,
    this.level = 1,
    this.perfectQuizCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ProgressID': progressID,
      'UserID': userID,
      'TotalLearned': totalLearned,
      'TotalMastered': totalMastered,
      'CurrentStreak': currentStreak,
      'BestStreak': bestStreak,
      'LastActiveDate': lastActiveDate?.toIso8601String().split('T')[0],
      'TotalPoints': totalPoints,
      'Level': level,
      'PerfectQuizCount': perfectQuizCount,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      progressID: map['ProgressID'],
      userID: map['UserID'],
      totalLearned: map['TotalLearned'] ?? 0,
      totalMastered: map['TotalMastered'] ?? 0,
      currentStreak: map['CurrentStreak'] ?? 0,
      bestStreak: map['BestStreak'] ?? 0,
      lastActiveDate: map['LastActiveDate'] != null
          ? DateTime.parse(map['LastActiveDate'])
          : null,
      totalPoints: map['TotalPoints'] ?? 0,
      level: map['Level'] ?? 1,
      perfectQuizCount: map['PerfectQuizCount'] ?? 0,
      createdAt: DateTime.parse(map['CreatedAt']),
      updatedAt: DateTime.parse(map['UpdatedAt']),
    );
  }
}
