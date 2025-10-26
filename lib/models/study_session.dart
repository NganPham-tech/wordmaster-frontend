enum StudyMode { learn, review, quiz }

class StudySession {
  final int? sessionID;
  final int userID;
  final int? deckID;
  final StudyMode mode;
  final int? score;
  final int totalCards;
  final int correctCards;
  final int duration; // in seconds
  final DateTime startedAt;
  final DateTime? completedAt;

  StudySession({
    this.sessionID,
    required this.userID,
    this.deckID,
    required this.mode,
    this.score,
    this.totalCards = 0,
    this.correctCards = 0,
    this.duration = 0,
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  Duration get sessionDuration => Duration(seconds: duration);

  double get accuracy {
    if (totalCards == 0) return 0.0;
    return (correctCards / totalCards) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'SessionID': sessionID,
      'UserID': userID,
      'DeckID': deckID,
      'Mode': mode.toString().split('.').last,
      'Score': score,
      'TotalCards': totalCards,
      'CorrectCards': correctCards,
      'Duration': duration,
      'StartedAt': startedAt.toIso8601String(),
      'CompletedAt': completedAt?.toIso8601String(),
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      sessionID: map['SessionID'],
      userID: map['UserID'],
      deckID: map['DeckID'],
      mode: StudyMode.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (map['Mode']?.toString().toLowerCase() ?? 'learn'),
        orElse: () => StudyMode.learn,
      ),
      score: map['Score'],
      totalCards: map['TotalCards'] ?? 0,
      correctCards: map['CorrectCards'] ?? 0,
      duration: map['Duration'] ?? 0,
      startedAt: DateTime.parse(map['StartedAt']),
      completedAt: map['CompletedAt'] != null
          ? DateTime.parse(map['CompletedAt'])
          : null,
    );
  }

  StudySession copyWith({
    int? sessionID,
    int? userID,
    int? deckID,
    StudyMode? mode,
    int? score,
    int? totalCards,
    int? correctCards,
    int? duration,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return StudySession(
      sessionID: sessionID ?? this.sessionID,
      userID: userID ?? this.userID,
      deckID: deckID ?? this.deckID,
      mode: mode ?? this.mode,
      score: score ?? this.score,
      totalCards: totalCards ?? this.totalCards,
      correctCards: correctCards ?? this.correctCards,
      duration: duration ?? this.duration,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

// Learning History for SRS Algorithm
enum LearningStatus { newCard, learning, mastered }

class LearningHistory {
  final int? historyID;
  final int userID;
  final int flashcardID;
  final LearningStatus status;
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime? lastReviewed;
  final DateTime? nextReviewDate;
  final DateTime createdAt;

  LearningHistory({
    this.historyID,
    required this.userID,
    required this.flashcardID,
    this.status = LearningStatus.newCard,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.lastReviewed,
    this.nextReviewDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'HistoryID': historyID,
      'UserID': userID,
      'FlashcardID': flashcardID,
      'Status': status.toString().split('.').last,
      'Repetitions': repetitions,
      'EaseFactor': easeFactor,
      'IntervalDays': intervalDays,
      'LastReviewed': lastReviewed?.toIso8601String(),
      'NextReviewDate': nextReviewDate?.toIso8601String().split('T')[0],
      'CreatedAt': createdAt.toIso8601String(),
    };
  }

  factory LearningHistory.fromMap(Map<String, dynamic> map) {
    return LearningHistory(
      historyID: map['HistoryID'],
      userID: map['UserID'],
      flashcardID: map['FlashcardID'],
      status: LearningStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (map['Status']?.toString().toLowerCase() ?? 'newcard'),
        orElse: () => LearningStatus.newCard,
      ),
      repetitions: map['Repetitions'] ?? 0,
      easeFactor: (map['EaseFactor'] ?? 2.5).toDouble(),
      intervalDays: map['IntervalDays'] ?? 1,
      lastReviewed: map['LastReviewed'] != null
          ? DateTime.parse(map['LastReviewed'])
          : null,
      nextReviewDate: map['NextReviewDate'] != null
          ? DateTime.parse(map['NextReviewDate'])
          : null,
      createdAt: DateTime.parse(map['CreatedAt']),
    );
  }
}
