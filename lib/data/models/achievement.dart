import 'package:flutter/material.dart';

class Achievement {

  static IconData? _getIconFromString(String? iconName) {
    if (iconName == null) return null;
    switch (iconName) {
      case 'target': return Icons.track_changes;
      case 'book': return Icons.menu_book;
      case 'fire': return Icons.local_fire_department;
      case 'lightbulb': return Icons.lightbulb_outline;
      case 'trophy': return Icons.emoji_events;
      case 'mic': return Icons.mic;
      case 'speed': return Icons.speed;
      case 'diamond': return Icons.diamond;
      default: return Icons.emoji_events;
    }
  }

  static String? _getStringFromIcon(IconData? icon) {
    if (icon == null) return null;
    if (icon == Icons.track_changes) return 'target';
    if (icon == Icons.menu_book) return 'book';
    if (icon == Icons.local_fire_department) return 'fire';
    if (icon == Icons.lightbulb_outline) return 'lightbulb';
    if (icon == Icons.emoji_events) return 'trophy';
    if (icon == Icons.mic) return 'mic';
    if (icon == Icons.speed) return 'speed';
    if (icon == Icons.diamond) return 'diamond';
    return 'trophy';
  }
  final int id;
  final String? title;
  final String? description;
  final IconData? badgeIcon;
  final String? condition;
  final int targetProgress;
  final int points;
  final bool isUnlocked;
  final int progress;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    this.title,
    this.description,
    this.badgeIcon,
    this.condition,
    required this.targetProgress,
    required this.points,
    required this.isUnlocked,
    required this.progress,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      badgeIcon: _getIconFromString(json['badgeIcon'] as String?),
      condition: json['condition'] as String?,
      targetProgress: json['targetProgress'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      progress: json['progress'] as int? ?? 0,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'badgeIcon': _getStringFromIcon(badgeIcon),
      'condition': condition,
      'targetProgress': targetProgress,
      'points': points,
      'isUnlocked': isUnlocked,
      'progress': progress,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    int? id,
    String? title,
    String? description,
    IconData? badgeIcon,
    String? condition,
    int? targetProgress,
    int? points,
    bool? isUnlocked,
    int? progress,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      condition: condition ?? this.condition,
      targetProgress: targetProgress ?? this.targetProgress,
      points: points ?? this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class AchievementStats {
  final int totalAchievements;
  final int unlockedAchievements;
  final int totalPoints;
  final int currentStreak;
  final int bestStreak;
  final Map<String, int> categoryProgress;

  AchievementStats({
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.totalPoints,
    required this.currentStreak,
    required this.bestStreak,
    required this.categoryProgress,
  });

  factory AchievementStats.fromJson(Map<String, dynamic> json) {
    return AchievementStats(
      totalAchievements: json['totalAchievements'] as int? ?? 0,
      unlockedAchievements: json['unlockedAchievements'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      categoryProgress: Map<String, int>.from(
        json['categoryProgress'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAchievements': totalAchievements,
      'unlockedAchievements': unlockedAchievements,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'categoryProgress': categoryProgress,
    };
  }

  double get completionRate {
    if (totalAchievements == 0) return 0.0;
    return unlockedAchievements / totalAchievements;
  }
}