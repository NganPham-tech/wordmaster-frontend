import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String username;
  final String phone;
  final String avatar;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    this.phone = '',
    this.avatar = '',
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? phone,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
    );
  }
}

class UserProgress {
  final int totalLearned;
  final int currentStreak;
  final int bestStreak;
  final int points;

  UserProgress({
    required this.totalLearned,
    required this.currentStreak,
    required this.bestStreak,
    required this.points,
  });
}

class FeaturedDeck {
  final int deckID;
  final String name;
  final String description;
  final String icon;
  final int cardCount;
  final bool isFavorite;

  FeaturedDeck({
    required this.deckID,
    required this.name,
    required this.description,
    required this.icon,
    required this.cardCount,
    this.isFavorite = false,
  });
}

class LearningActivity {
  final String action;
  final String target;
  final DateTime createdAt;

  LearningActivity({
    required this.action,
    required this.target,
    required this.createdAt,
  });
}

class DailyGoal {
  final int targetMinutes;
  final int completedMinutes;
  final int targetCards;
  final int completedCards;
  final bool isCompleted;

  DailyGoal({
    required this.targetMinutes,
    required this.completedMinutes,
    required this.targetCards,
    required this.completedCards,
    this.isCompleted = false,
  });

  double get progressPercentage => completedMinutes / targetMinutes;
  double get cardsProgressPercentage => completedCards / targetCards;
}

class QuickAction {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final int pendingItems;
  final VoidCallback? onTap;

  QuickAction({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    required this.pendingItems,
    this.onTap,
  });
}

class Deck {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final String? category;
  final int? cardCount;
  final int? totalCards;
  final int? masteredCards;
  final String? difficulty;
  final double? rating;
  final bool isFavorite;

  Deck({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.category,
    this.cardCount,
    this.totalCards,
    this.masteredCards,
    this.difficulty,
    this.rating,
    this.isFavorite = false,
  });

  double get progress {
    if (totalCards == null || masteredCards == null || totalCards == 0) {
      return 0.0;
    }
    return masteredCards! / totalCards!;
  }
}
