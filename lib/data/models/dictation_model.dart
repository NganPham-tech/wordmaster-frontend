class DictationContent {
  final String id;
  final String title;
  final String description;
  final String sourceType; // YouTube, Audio, Video
  final String sourceURL;
  final String? thumbnail;
  final String transcript;
  final int duration; // seconds
  final String difficulty;
  final String? accentType;
  final List<String> tags;
  final int viewCount;
  final bool isActive;
  final DateTime createdAt;

  DictationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceType,
    required this.sourceURL,
    this.thumbnail,
    required this.transcript,
    required this.duration,
    required this.difficulty,
    this.accentType,
    required this.tags,
    this.viewCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}m ${seconds}s';
  }

  String get difficultyLevel {
    switch (difficulty) {
      case 'Beginner':
        return 'A1-A2';
      case 'Intermediate':
        return 'B1-B2';
      case 'Advanced':
        return 'C1-C2';
      default:
        return 'A1';
    }
  }
}

class DictationResult {
  final String id;
  final String userId;
  final String contentId;
  final String userTranscript;
  final double accuracy;
  final int totalWords;
  final int correctWords;
  final int missingWords;
  final int extraWords;
  final int timeSpent;
  final DateTime completedAt;

  DictationResult({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.userTranscript,
    required this.accuracy,
    required this.totalWords,
    required this.correctWords,
    required this.missingWords,
    required this.extraWords,
    required this.timeSpent,
    required this.completedAt,
  });
}

class DictationSentence {
  final int index;
  final String text;
  final int startTime;
  final int endTime;
  
  DictationSentence({
    required this.index,
    required this.text,
    required this.startTime,
    required this.endTime,
  });
}