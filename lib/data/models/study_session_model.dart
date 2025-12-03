class StudySession {
  final int id;
  final int userId;
  final String contentType;
  final int contentId;
  final String mode;
  final double? score;
  final int? totalItems;
  final int? completedItems;
  final int? duration; // seconds
  final DateTime startedAt;
  final DateTime? completedAt;

  StudySession({
    required this.id,
    required this.userId,
    required this.contentType,
    required this.contentId,
    required this.mode,
    this.score,
    this.totalItems,
    this.completedItems,
    this.duration,
    required this.startedAt,
    this.completedAt,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      userId: json['userId'],
      contentType: json['contentType'],
      contentId: json['contentId'],
      mode: json['mode'],
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      totalItems: json['totalItems'],
      completedItems: json['completedItems'],
      duration: json['duration'],
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contentType': contentType,
      'contentId': contentId,
      'mode': mode,
      'score': score,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'duration': duration,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  bool get isCompleted => completedAt != null;
  
  double get progress {
    if (totalItems == null || totalItems == 0) return 0.0;
    return (completedItems ?? 0) / totalItems!;
  }
  
  String get formattedDuration {
    if (duration == null) return '0:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Session statistics model
class SessionStatistics {
  final int totalSessions;
  final double averageScore;
  final int totalTimeSpent; // seconds
  final double completionRate;

  SessionStatistics({
    required this.totalSessions,
    required this.averageScore,
    required this.totalTimeSpent,
    required this.completionRate,
  });

  factory SessionStatistics.fromJson(Map<String, dynamic> json) {
    return SessionStatistics(
      totalSessions: json['totalSessions'] ?? 0,
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
    );
  }

  String get formattedTotalTime {
    final hours = totalTimeSpent ~/ 3600;
    final minutes = (totalTimeSpent % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}