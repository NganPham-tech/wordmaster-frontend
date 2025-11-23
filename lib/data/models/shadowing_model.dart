class ShadowingContent {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final String sourceUrl;
  final SourceType sourceType;
  final String transcript;
  final int duration; // seconds
  final Difficulty difficulty;
  final String accentType;
  final SpeechRate speechRate;
  final List<String> tags;
  final int viewCount;
  final String? createdBy;
  final bool isActive;
  final List<Segment> segments;
  final DateTime createdAt;

  ShadowingContent({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    required this.sourceUrl,
    required this.sourceType,
    required this.transcript,
    required this.duration,
    required this.difficulty,
    required this.accentType,
    required this.speechRate,
    required this.tags,
    this.viewCount = 0,
    this.createdBy,
    this.isActive = true,
    required this.segments,
    required this.createdAt,
  });
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