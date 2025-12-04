class Achievement {
  final int id;
  final int userId;
  final String achievementType;
  final String? title;
  final String? description;
  final int progress;
  final int targetProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String? badgeIcon;
  final int points;

  Achievement({
    required this.id,
    required this.userId,
    required this.achievementType,
    this.title,
    this.description,
    required this.progress,
    required this.targetProgress,
    required this.isUnlocked,
    this.unlockedAt,
    this.badgeIcon,
    required this.points,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      userId: json['userId'],
      achievementType: json['achievementType'],
      title: json['title'],
      description: json['description'],
      progress: json['progress'] ?? 0,
      targetProgress: json['targetProgress'] ?? 1,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      badgeIcon: json['badgeIcon'],
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'achievementType': achievementType,
      'title': title,
      'description': description,
      'progress': progress,
      'targetProgress': targetProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'badgeIcon': badgeIcon,
      'points': points,
    };
  }

  double get progressPercentage {
    if (targetProgress == 0) return 0;
    return (progress / targetProgress) * 100;
  }

  bool get isCompleted => progress >= targetProgress;
}

// Achievement stats model
class AchievementStats {
  final int totalAchievements;
  final int unlockedAchievements;
  final int totalPointsFromAchievements;
  final double completionRate;
  final List<Achievement> recentUnlocks;

  AchievementStats({
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.totalPointsFromAchievements,
    required this.completionRate,
    required this.recentUnlocks,
  });

  factory AchievementStats.fromJson(Map<String, dynamic> json) {
    return AchievementStats(
      totalAchievements: json['totalAchievements'] ?? 0,
      unlockedAchievements: json['unlockedAchievements'] ?? 0,
      totalPointsFromAchievements: json['totalPointsFromAchievements'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
      recentUnlocks: json['recentUnlocks'] != null
          ? (json['recentUnlocks'] as List)
              .map((a) => Achievement.fromJson(a))
              .toList()
          : [],
    );
  }
}