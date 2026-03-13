// File: lib/data/models/dictation_model.dart
import '../../config/env_config.dart';

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
  final List<DictationSegment>? segments;

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
    this.segments,
  });

  factory DictationContent.fromJson(Map<String, dynamic> json) {
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

    // 🆕 Parse segments with detailed logging
    List<DictationSegment>? parseSegments() {
      if (json['segments'] == null || json['segments'] is! List) {
        print('📋 No segments for: ${json['title']}');
        return null;
      }
      
      final segmentsList = (json['segments'] as List)
          .map((s) => DictationSegment.fromJson(s as Map<String, dynamic>))
          .toList();
      
      print('📋 Parsed ${segmentsList.length} segments for: ${json['title']}');
      
      return segmentsList.isEmpty ? null : segmentsList;
    }

    return DictationContent(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sourceType: json['sourceType'] ?? 'Unknown',
      sourceURL: json['sourceURL'] ?? '',
      thumbnail: json['thumbnail'],
      audioPath: json['audioPath'],  // Just filename from DB
      transcript: json['transcript'] ?? '',
      duration: (json['duration'] is int) 
          ? json['duration'] 
          : (json['duration'] is double ? json['duration'].toInt() : 0),
      difficulty: json['difficulty'] ?? 'Intermediate',
      accentType: json['accentType'],
      tags: parseTags(),
      viewCount: json['viewCount'] ?? 0,
      wordCount: json['wordCount'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      segments: parseSegments(),
    );
  }
  
  // ✅ FIXED: Get full audio URL from backend
  String? get audioURL {
    if (audioPath == null || audioPath!.isEmpty) {
      print('🔊 audioURL: audioPath is null or empty');
      return null;
    }
    
    print('🔊 Original audioPath: "$audioPath"');
    String cleanPath = audioPath!;
    
    // If already a full URL, return as-is
    if (cleanPath.startsWith('http')) {
      print('🔊 audioURL: Already full HTTP URL');
      return cleanPath;
    }
    
    // Clean up duplicate /uploads/dictation/ prefixes
    if (cleanPath.startsWith('/uploads/dictation/')) {
      // Remove the first /uploads/dictation/ prefix
      cleanPath = cleanPath.substring('/uploads/dictation/'.length);
      print('🔊 After removing first /uploads/dictation/: "$cleanPath"');
    }
    
    // Remove any additional /uploads/dictation/ that might be embedded
    while (cleanPath.startsWith('uploads/dictation/')) {
      cleanPath = cleanPath.substring('uploads/dictation/'.length);
      print('🔊 After removing embedded uploads/dictation/: "$cleanPath"');
    }
    
    // Ensure cleanPath doesn't start with / to avoid double slash
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
      print('🔊 After removing leading slash: "$cleanPath"');
    }
    
    // Now build the final URL
    final finalURL = '${EnvConfig.baseUrl.replaceAll('/api', '')}/uploads/dictation/$cleanPath';
    print('🔊 Final audioURL: "$finalURL"');
    return finalURL;
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  int get effectiveWordCount {
    if (wordCount != null) return wordCount!;
    return transcript.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
  
  // ✅ Check if has segments
  bool get hasSegments => segments != null && segments!.isNotEmpty;
}

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
  
  String get timeFormatted {
    final start = _formatTime(startTime);
    final end = _formatTime(endTime);
    return '$start - $end';
  }
  
  String _formatTime(double seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}