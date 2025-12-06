// lib/data/models/shadowing_model.dart
// Updated with STT provider information
import '../../config/env_config.dart';

class SegmentResult {
  final String segmentId;
  final double accuracyScore;
  final double pronunciationScore;
  final double fluencyScore;
  final double overallScore;
  final String recognizedText;
  final String feedback;
  final List<PronunciationHint> pronunciationHints;
  final double? confidence;
  final String? provider; 
  final bool? isMock;

  SegmentResult({
    required this.segmentId,
    required this.accuracyScore,
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.overallScore,
    required this.recognizedText,
    required this.feedback,
    this.pronunciationHints = const [],
    this.confidence,
    this.provider,
    this.isMock,
  });

  factory SegmentResult.fromJson(Map<String, dynamic> json) {
    return SegmentResult(
      segmentId: json['segmentId'].toString(),
      accuracyScore: (json['accuracyScore'] ?? 0).toDouble(),
      pronunciationScore: (json['pronunciationScore'] ?? 0).toDouble(),
      fluencyScore: (json['fluencyScore'] ?? 0).toDouble(),
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      recognizedText: json['recognizedText'] ?? '',
      feedback: json['feedback'] ?? '',
      pronunciationHints: (json['pronunciationHints'] as List?)
          ?.map((h) => PronunciationHint.fromJson(h))
          .toList() ?? [],
      confidence: json['confidence']?.toDouble(),
      provider: json['provider'],
      isMock: json['isMock'],
    );
  }
}

class PronunciationHint {
  final String word;
  final String expectedPronunciation;
  final String userPronunciation;
  final String suggestion;
  final int? similarity;

  PronunciationHint({
    required this.word,
    required this.expectedPronunciation,
    required this.userPronunciation,
    required this.suggestion,
    this.similarity,
  });

  factory PronunciationHint.fromJson(Map<String, dynamic> json) {
    return PronunciationHint(
      word: json['word'] ?? '',
      expectedPronunciation: json['expectedPronunciation'] ?? '',
      userPronunciation: json['userPronunciation'] ?? '',
      suggestion: json['suggestion'] ?? '',
      similarity: json['similarity'],
    );
  }
}

class ShadowingContent {
  final int id;
  final String title;
  final String? description;
  final String sourceType;
  final String sourceURL;
  final String? thumbnail;
  final String? audioPath;
  final String difficulty;
  final String accentType;
  final String speechRate;
  final int? duration;
  final String? tags;
  final int viewCount;
  final int? wordCount;
  final int? segmentCount;
  final DateTime createdAt;

  ShadowingContent({
    required this.id,
    required this.title,
    this.description,
    required this.sourceType,
    required this.sourceURL,
    this.thumbnail,
    this.audioPath,
    required this.difficulty,
    required this.accentType,
    required this.speechRate,
    this.duration,
    this.tags,
    required this.viewCount,
    this.wordCount,
    this.segmentCount,
    required this.createdAt,
  });

  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((t) => t.trim()).toList();
  }

  String? get audioURL {
    if (audioPath == null || audioPath!.isEmpty) {
      return null;
    }
    
    String cleanPath = audioPath!;
    
    // If already a full URL, return as-is
    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }
    
    // Clean up duplicate /uploads/shadowing/ prefixes
    if (cleanPath.startsWith('/uploads/shadowing/')) {
      // Remove the first /uploads/shadowing/ prefix
      cleanPath = cleanPath.substring('/uploads/shadowing/'.length);
    }
    
    // Remove any additional /uploads/shadowing/ that might be embedded
    while (cleanPath.startsWith('uploads/shadowing/')) {
      cleanPath = cleanPath.substring('uploads/shadowing/'.length);
    }
    
    // Now build the final URL
    return '${EnvConfig.baseUrl.replaceAll('/api', '')}/uploads/shadowing/$cleanPath';
  }

  factory ShadowingContent.fromJson(Map<String, dynamic> json) {
    return ShadowingContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sourceType: json['sourceType'],
      sourceURL: json['sourceURL'],
      thumbnail: json['thumbnail'],
      audioPath: json['audioPath'],
      difficulty: json['difficulty'],
      accentType: json['accentType'] ?? 'American',
      speechRate: json['speechRate'] ?? 'Normal',
      duration: json['duration'],
      tags: json['tags'],
      viewCount: json['viewCount'] ?? 0,
      wordCount: json['wordCount'],
      segmentCount: json['_count']?['segments'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ShadowingContentDetail extends ShadowingContent {
  final String transcript;
  final List<ShadowingSegment> segments;

  ShadowingContentDetail({
    required super.id,
    required super.title,
    super.description,
    required super.sourceType,
    required super.sourceURL,
    super.thumbnail,
    super.audioPath,
    required super.difficulty,
    required super.accentType,
    required super.speechRate,
    super.duration,
    super.tags,
    required super.viewCount,
    super.wordCount,
    super.segmentCount,
    required super.createdAt,
    required this.transcript,
    required this.segments,
  });

  factory ShadowingContentDetail.fromJson(Map<String, dynamic> json) {
    return ShadowingContentDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sourceType: json['sourceType'],
      sourceURL: json['sourceURL'],
      thumbnail: json['thumbnail'],
      audioPath: json['audioPath'],
      difficulty: json['difficulty'],
      accentType: json['accentType'] ?? 'American',
      speechRate: json['speechRate'] ?? 'Normal',
      duration: json['duration'],
      tags: json['tags'],
      viewCount: json['viewCount'] ?? 0,
      wordCount: json['wordCount'],
      segmentCount: (json['segments'] as List?)?.length,
      createdAt: DateTime.parse(json['createdAt']),
      transcript: json['transcript'],
      segments: (json['segments'] as List?)
          ?.map((s) => ShadowingSegment.fromJson(s))
          .toList() ?? [],
    );
  }
}

class ShadowingSegment {
  final int id;
  final int orderIndex;
  final double startTime;
  final double endTime;
  final String text;

  ShadowingSegment({
    required this.id,
    required this.orderIndex,
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  double get duration => endTime - startTime;

  factory ShadowingSegment.fromJson(Map<String, dynamic> json) {
    return ShadowingSegment(
      id: json['id'],
      orderIndex: json['orderIndex'],
      startTime: (json['startTime'] ?? 0).toDouble(),
      endTime: (json['endTime'] ?? 0).toDouble(),
      text: json['text'],
    );
  }
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
  final int totalTimeSpent;
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

  factory ShadowingResult.fromJson(Map<String, dynamic> json) {
    return ShadowingResult(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      contentId: json['contentId'].toString(),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: DateTime.parse(json['completedAt']),
      totalSegments: json['totalSegments'],
      practicedSegments: json['practicedSegments'],
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      totalTimeSpent: json['totalTimeSpent'],
      segmentResults: (json['segmentResults'] as List?)
          ?.map((r) => SegmentResult.fromJson(r))
          .toList() ?? [],
    );
  }
}

enum RecordState {
  idle,
  recording,
  recorded,
  processing,
}

// STT Provider Info
class STTProviderInfo {
  final String name;
  final String mode;
  final double? totalMinutes;
  final double? monthlyLimit;
  final double? percentUsed;
  final bool isMock;

  STTProviderInfo({
    required this.name,
    required this.mode,
    this.totalMinutes,
    this.monthlyLimit,
    this.percentUsed,
    required this.isMock,
  });

  factory STTProviderInfo.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] ?? {};
    final usage = json['usage'] ?? {};
    
    return STTProviderInfo(
      name: provider['name'] ?? 'Unknown',
      mode: json['mode'] ?? 'auto',
      totalMinutes: usage['totalMinutes']?.toDouble(),
      monthlyLimit: usage['monthlyLimit']?.toDouble(),
      percentUsed: usage['percentUsed'] != null 
          ? double.parse(usage['percentUsed'].toString())
          : null,
      isMock: provider['name']?.contains('Mock') ?? false,
    );
  }
  
  String get usageText {
    if (totalMinutes == null || monthlyLimit == null) {
      return 'Mock Mode - Unlimited';
    }
    return '${totalMinutes!.toStringAsFixed(1)}/${monthlyLimit!.toInt()} min (${percentUsed!.toStringAsFixed(1)}%)';
  }
}