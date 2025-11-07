import 'package:flutter/material.dart';

class DailyGoal {
  final int targetMinutes;
  final int completedMinutes;
  final int targetCards;
  final int completedCards;

  DailyGoal({
    required this.targetMinutes,
    required this.completedMinutes,
    required this.targetCards,
    required this.completedCards,
  });

  double get progressPercentage =>
      (completedMinutes / targetMinutes).clamp(0.0, 1.0);
}

class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final int pendingItems;

  QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.pendingItems = 0,
  });
}

class Deck {
  final String id;
  final String name;
  final String description;
  final String category;
  final int totalCards;
  final int masteredCards;
  final String difficulty;
  final String? thumbnailUrl;
  final double rating;

  Deck({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.totalCards,
    required this.masteredCards,
    required this.difficulty,
    this.thumbnailUrl,
    required this.rating,
  });

  double get progress => totalCards > 0 ? masteredCards / totalCards : 0;
}
