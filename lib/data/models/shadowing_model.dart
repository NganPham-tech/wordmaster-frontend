class ShadowingContent {
  final int id;
  final String title;
  final String? description;
  final String? thumbnail;
  final String sourceURL;
  final String sourceType;
  final String? audioPath;
  final String transcript;
  final int? duration; // seconds
  final String difficulty;
  final String accentType;
  final String speechRate;
  final String? tags;
  final int viewCount;
  final int wordCount;
  final bool isActive;
  final DateTime createdAt;
  final int? segmentCount; // From _count in API

  ShadowingContent({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    required this.sourceURL,
    required this.sourceType,
    this.audioPath,
    required this.transcript,
    this.duration,
    required this.difficulty,
    required this.accentType,
    required this.speechRate,
    this.tags,
    this.viewCount = 0,
    this.wordCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.segmentCount,
  });

  factory ShadowingContent.fromJson(Map<String, dynamic> json) {
    return ShadowingContent(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'],
      sourceURL: json['sourceURL'] ?? '',
      sourceType: json['sourceType'] ?? 'Audio',
      audioPath: json['audioPath'],
      transcript: json['transcript'] ?? '',
      duration: json['duration'],
      difficulty: json['difficulty'] ?? 'Intermediate',
      accentType: json['accentType'] ?? 'American',
      speechRate: json['speechRate'] ?? 'Normal',
      tags: json['tags'],
      viewCount: json['viewCount'] ?? 0,
      wordCount: json['wordCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      segmentCount: json['_count']?['segments'],
    );
  }

  // Get audio URL
  String? get audioURL {
    if (audioPath != null && audioPath!.isNotEmpty) {
      return 'http://10.0.2.2:3000/uploads/shadowing/$audioPath';
    }
    return null;
  }

  // Duration formatted as MM:SS
  String get durationFormatted {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Parse tags to list
  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}

class ShadowingSegment {
  final int id;
  final int contentId;
  final int orderIndex;
  final double startTime;
  final double endTime;
  final String text;
  final DateTime createdAt;

  ShadowingSegment({
    required this.id,
    required this.contentId,
    required this.orderIndex,
    required this.startTime,
    required this.endTime,
    required this.text,
    required this.createdAt,
  });

  factory ShadowingSegment.fromJson(Map<String, dynamic> json) {
    return ShadowingSegment(
      id: json['id'],
      contentId: json['contentId'],
      orderIndex: json['orderIndex'],
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  double get duration => endTime - startTime;

  String get durationFormatted {
    return '${duration.toStringAsFixed(1)}s';
  }
}

class ShadowingContentDetail {
  final int id;
  final String title;
  final String? description;
  final String? thumbnail;
  final String sourceURL;
  final String sourceType;
  final String? audioPath;
  final String transcript;
  final int? duration;
  final String difficulty;
  final String accentType;
  final String speechRate;
  final String? tags;
  final int viewCount;
  final int wordCount;
  final bool isActive;
  final DateTime createdAt;
  final List<ShadowingSegment> segments;

  ShadowingContentDetail({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    required this.sourceURL,
    required this.sourceType,
    this.audioPath,
    required this.transcript,
    this.duration,
    required this.difficulty,
    required this.accentType,
    required this.speechRate,
    this.tags,
    this.viewCount = 0,
    this.wordCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.segments,
  });

  factory ShadowingContentDetail.fromJson(Map<String, dynamic> json) {
    return ShadowingContentDetail(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'],
      sourceURL: json['sourceURL'] ?? '',
      sourceType: json['sourceType'] ?? 'Audio',
      audioPath: json['audioPath'],
      transcript: json['transcript'] ?? '',
      duration: json['duration'],
      difficulty: json['difficulty'] ?? 'Intermediate',
      accentType: json['accentType'] ?? 'American',
      speechRate: json['speechRate'] ?? 'Normal',
      tags: json['tags'],
      viewCount: json['viewCount'] ?? 0,
      wordCount: json['wordCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      segments: (json['segments'] as List)
          .map((s) => ShadowingSegment.fromJson(s))
          .toList(),
    );
  }

  String? get audioURL {
    if (audioPath != null && audioPath!.isNotEmpty) {
      return 'http://10.0.2.2:3000/uploads/shadowing/$audioPath';
    }
    return null;
  }

  String get durationFormatted {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}

class Segment {
  final String id;
  final int index;
  final String text;
  final int startTime; // milliseconds
  final int endTime; // milliseconds
  final double? userScore;
  final String? userAudioPath;
  final String? recognizedText;
  final DateTime? practicedAt;

  Segment({
    required this.id,
    required this.index,
    required this.text,
    required this.startTime,
    required this.endTime,
    this.userScore,
    this.userAudioPath,
    this.recognizedText,
    this.practicedAt,
  });

  bool get isPracticed => userScore != null;
  int get duration => endTime - startTime;
}

class ShadowingResult {
  final String id;
  final String userId;
  final String contentId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int totalSegments;
  final int practicedSegments;
  final double averageScore;
  final int totalTimeSpent; // seconds
  final List<SegmentResult> segmentResults;

  ShadowingResult({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.startedAt,
    required this.completedAt,
    required this.totalSegments,
    required this.practicedSegments,
    required this.averageScore,
    required this.totalTimeSpent,
    required this.segmentResults,
  });
}

class SegmentResult {
  final String segmentId;
  final double accuracyScore;
  final double pronunciationScore;
  final double fluencyScore;
  final double overallScore;
  final String recognizedText;
  final String feedback;
  final List<PronunciationHint> pronunciationHints;

  SegmentResult({
    required this.segmentId,
    required this.accuracyScore,
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.overallScore,
    required this.recognizedText,
    required this.feedback,
    required this.pronunciationHints,
  });
}

class PronunciationHint {
  final String word;
  final String expectedPronunciation;
  final String userPronunciation;
  final String suggestion;

  PronunciationHint({
    required this.word,
    required this.expectedPronunciation,
    required this.userPronunciation,
    required this.suggestion,
  });
}

enum SourceType { youtube, audio, video }

enum Difficulty { beginner, intermediate, advanced }

enum SpeechRate { slow, normal, fast }

enum RecordState { idle, recording, recorded, processing }
