import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dictation.dart';

class DictationService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator IP
  
  // Lấy danh sách bài dictation
  static Future<List<DictationLesson>> getAllLessons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dictation'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lessons = data['data'] as List;
        
        return lessons.map((json) => _jsonToLesson(json)).toList();
      } else {
        throw Exception('Failed to load lessons');
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }
  
  // Lấy bài dictation theo level
  static Future<List<DictationLesson>> getLessonsByLevel(DictationLevel level) async {
    try {
      final difficulty = level.toString().split('.').last;
      final response = await http.get(
        Uri.parse('$baseUrl/dictation?difficulty=$difficulty'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lessons = data['data'] as List;
        
        return lessons.map((json) => _jsonToLesson(json)).toList();
      } else {
        throw Exception('Failed to load lessons');
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }
  
  // Lấy chi tiết một bài
  static Future<DictationLesson> getLessonById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dictation/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _jsonToLesson(data['data']);
      } else {
        throw Exception('Failed to load lesson');
      }
    } catch (e) {
      throw Exception('Error fetching lesson: $e');
    }
  }
  
  // Lưu kết quả
  static Future<DictationResult> saveResult({
    required int userId,
    required int lessonId,
    required String userTranscript,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dictation?action=submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'lessonId': lessonId,
          'userTranscript': userTranscript,
        }),
      );
      
      if (response.statusCode == 201) {
        // Convert response to DictationResult
        // Implementation here
        throw UnimplementedError();
      } else {
        throw Exception('Failed to save result');
      }
    } catch (e) {
      throw Exception('Error saving result: $e');
    }
  }
  
  // Helper function để convert JSON thành DictationLesson
  static DictationLesson _jsonToLesson(Map<String, dynamic> json) {
    final segments = (json['segments'] as List).map((s) {
      return DictationSegment(
        index: s['index'],
        text: s['text'],
        startTimeMs: s['startTimeMs'],
        endTimeMs: s['endTimeMs'],
      );
    }).toList();
    
    return DictationLesson(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      level: _stringToLevel(json['difficulty']),
      thumbnailPath: 'images/timo.jpg', // Default thumbnail
      durationSeconds: json['durationSeconds'] ?? 0,
      fullTranscript: json['transcript'] ?? '',
      segments: segments,
      useTTS: json['useTTS'] ?? true, // Default to TTS if not specified
      speechRate: (json['speechRate'] ?? 0.5).toDouble(),
      voiceLanguage: json['voiceLanguage'] ?? 'en-US',
    );
  }
  
  static DictationLevel _stringToLevel(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return DictationLevel.beginner;
      case 'medium':
      case 'intermediate':
        return DictationLevel.intermediate;
      case 'hard':
      case 'advanced':
        return DictationLevel.advanced;
      default:
        return DictationLevel.beginner;
    }
  }
}