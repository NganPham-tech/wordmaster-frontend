import 'package:flutter/material.dart';
class StudySession {
  final String sessionId;
  final String deckId;
  final StudyMode mode;
  final int limit;
  final DateTime startedAt;
  DateTime? completedAt;
  final List<StudyCard> cards;
  int currentIndex;
  final SessionStats stats;

  StudySession({
    required this.sessionId,
    required this.deckId,
    required this.mode,
    required this.limit,
    required this.startedAt,
    this.completedAt,
    required this.cards,
    this.currentIndex = 0,
    required this.stats,
  });

  StudyCard get currentCard => cards[currentIndex];
  bool get isCompleted => currentIndex >= cards.length;
  double get progress => cards.isNotEmpty ? currentIndex / cards.length : 0;
}

class SessionStats {
  int reviewed;
  int correct;
  double totalRating;
  int totalTimeSpent;

  SessionStats({
    this.reviewed = 0,
    this.correct = 0,
    this.totalRating = 0,
    this.totalTimeSpent = 0,
  });

  double get accuracy => reviewed > 0 ? correct / reviewed : 0;
  double get averageRating => reviewed > 0 ? totalRating / reviewed : 0;
}

class StudyCard {
  final String id;
  final CardType type;
  final String front;
  final String back;
  final String? example;
  final String? audioUrl;
  final String? imageUrl;
  final String? phonetic;
  final String? wordType;
  final String? structure;
  final String? usage;
  final String? explanation;
  final Difficulty difficulty;
  final SRSInfo srsInfo;
  bool isRevealed;
  bool isFavorite;

  StudyCard({
    required this.id,
    required this.type,
    required this.front,
    required this.back,
    this.example,
    this.audioUrl,
    this.imageUrl,
    this.phonetic,
    this.wordType,
    this.structure,
    this.usage,
    this.explanation,
    required this.difficulty,
    required this.srsInfo,
    this.isRevealed = false,
    this.isFavorite = false,
  });
}

class SRSInfo {
  double easeFactor;
  int repetitions;
  int intervalDays;
  DateTime? lastReviewed;
  DateTime? nextReviewDate;

  SRSInfo({
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.intervalDays = 1,
    this.lastReviewed,
    this.nextReviewDate,
  });
}

enum CardType { vocabulary, grammar }
enum StudyMode { sequential, random, dueOnly }
enum Difficulty { easy, medium, hard }
enum Rating { again, hard, good, easy }

extension RatingExtension on Rating {
  int get value {
    switch (this) {
      case Rating.again: return 0;
      case Rating.hard: return 1;
      case Rating.good: return 3;
      case Rating.easy: return 5;
    }
  }

  String get displayText {
    switch (this) {
      case Rating.again: return 'Again';
      case Rating.hard: return 'Hard';
      case Rating.good: return 'Good';
      case Rating.easy: return 'Easy';
    }
  }

  Color get color {
    switch (this) {
      case Rating.again: return Colors.red;
      case Rating.hard: return Colors.orange;
      case Rating.good: return Colors.blue;
      case Rating.easy: return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case Rating.again: return Icons.replay;
      case Rating.hard: return Icons.whatshot;
      case Rating.good: return Icons.thumb_up;
      case Rating.easy: return Icons.auto_awesome;
    }
  }
}