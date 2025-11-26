class DictationContent {
  final String id;
  final String title;
  final String description;
  final String sourceType;
  final String sourceURL;
  final String? thumbnail;
  final String? audioPath;
  final String transcript;
  final int duration;
  final String difficulty;
  final String? accentType;
  final List<String> tags;
  final int viewCount;
  final int? wordCount;
  final DateTime createdAt;
  final List<DictationSegment>? segments; // 🆕 THÊM SEGMENTS

  DictationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceType,
    required this.sourceURL,
    this.thumbnail,
    this.audioPath,
    required this.transcript,
    required this.duration,
    required this.difficulty,
    this.accentType,
    required this.tags,
    required this.viewCount,
    this.wordCount,
    required this.createdAt,
    this.segments, // 🆕
  });

  factory DictationContent.fromJson(Map<String, dynamic> json) {
    // Parse tags - can be string or null
    List<String> parseTags() {
      if (json['tags'] == null) return [];
      if (json['tags'] is String) {
        final tagsStr = json['tags'] as String;
        if (tagsStr.isEmpty) return [];
        return tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      }
      if (json['tags'] is List) {
        return (json['tags'] as List).map((t) => t.toString()).toList();
      }
      return [];
    }

    return DictationContent(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sourceType: json['sourceType'] ?? 'Unknown',
      sourceURL: json['sourceURL'] ?? '',
      thumbnail: json['thumbnail'],
      audioPath: json['audioPath'],
      transcript: json['transcript'] ?? '',
      duration: (json['duration'] is int) ? json['duration'] : (json['duration'] is double ? json['duration'].toInt() : 0),
      difficulty: json['difficulty'] ?? 'Intermediate',
      accentType: json['accentType'],
      tags: parseTags(),
      viewCount: json['viewCount'] ?? 0,
      wordCount: json['wordCount'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      // Parse segments
      segments: json['segments'] != null && json['segments'] is List
          ? (json['segments'] as List)
              .map((s) => DictationSegment.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
  
  // Get audio URL - fallback to YouTube if no audio file
  String? get audioURL {
    print('Debug - audioPath: $audioPath');
    print('Debug - sourceURL: $sourceURL');
    
    if (audioPath != null) {
      final url = 'http://10.0.2.2:3000/uploads/dictation/$audioPath';
      print('Debug - generated audioURL: $url');
      return url;
    }
    
    // Fallback to YouTube URL (won't work in audioplayers but shows the issue)
    if (sourceURL.contains('youtube.com') || sourceURL.contains('youtu.be')) {
      print('Debug - using YouTube URL as fallback: $sourceURL');
      return sourceURL;
    }
    
    print('Debug - no audio URL available');
    return null;
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Calculate word count from transcript if not provided
  int get effectiveWordCount {
    if (wordCount != null) return wordCount!;
    return transcript.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
  
  // 🆕 Check if has segments for mode selection
  bool get hasSegments => segments != null && segments!.isNotEmpty;
}

// 🆕 THÊM MODEL MỚI
class DictationSegment {
  final int id;
  final int orderIndex;
  final double startTime;
  final double endTime;
  final String text;

  DictationSegment({
    required this.id,
    required this.orderIndex,
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  factory DictationSegment.fromJson(Map<String, dynamic> json) {
    return DictationSegment(
      id: json['id'],
      orderIndex: json['orderIndex'],
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      text: json['text'],
    );
  }

  double get duration => endTime - startTime;
}