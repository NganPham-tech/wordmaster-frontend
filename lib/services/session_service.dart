// lib/services/session_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../data/models/study_session_model.dart';

class SessionService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  final _storage = GetStorage();
  
  // Get auth token
  String? _getToken() {
    return _storage.read('auth_token');
  }
  
  Map<String, String> _getHeaders() {
    final token = _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  

  Future<StudySession?> startSession({
    required String contentType,
    required int contentId,
    String mode = 'Learn',
    int? totalItems,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/start'),
        headers: _getHeaders(),
        body: jsonEncode({
          'contentType': contentType,
          'contentId': contentId,
          'mode': mode,
          'totalItems': totalItems,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StudySession.fromJson(data['data']);
      } else {
        print('Start session error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Start session exception: $e');
      return null;
    }
  }
  

  Future<bool> updateProgress({
    required int sessionId,
    int? completedItems,
    double? score,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sessions/$sessionId/progress'),
        headers: _getHeaders(),
        body: jsonEncode({
          if (completedItems != null) 'completedItems': completedItems,
          if (score != null) 'score': score,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Update progress exception: $e');
      return false;
    }
  }
  

  Future<Map<String, dynamic>?> completeSession({
    required int sessionId,
    int? completedItems,
    double? score,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/$sessionId/complete'),
        headers: _getHeaders(),
        body: jsonEncode({
          if (completedItems != null) 'completedItems': completedItems,
          if (score != null) 'score': score,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
       
        return {
          'session': StudySession.fromJson(data['data']['session']),
          'unlockedAchievements': data['data']['unlockedAchievements'] ?? [],
        };
      } else {
        print('Complete session error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Complete session exception: $e');
      return null;
    }
  }
  
  
  Future<List<StudySession>> getMySessions({
    String? contentType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (contentType != null) 'contentType': contentType,
      };
      
      final uri = Uri.parse('$baseUrl/sessions/my-sessions')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _getHeaders());
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> sessionsData = data['data'];
        return sessionsData
            .map((json) => StudySession.fromJson(json))
            .toList();
      } else {
        print('Get sessions error: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get sessions exception: $e');
      return [];
    }
  }
  
  
  Future<SessionStatistics?> getStatistics({String? contentType}) async {
    try {
      final queryParams = {
        if (contentType != null) 'contentType': contentType,
      };
      
      final uri = Uri.parse('$baseUrl/sessions/statistics')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _getHeaders());
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SessionStatistics.fromJson(data['data']);
      } else {
        print('Get statistics error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get statistics exception: $e');
      return null;
    }
  }
}