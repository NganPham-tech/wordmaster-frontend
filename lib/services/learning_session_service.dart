import 'package:get/get.dart';
import 'api_service.dart';

class LearningSessionService extends GetxService {
  static LearningSessionService get instance => Get.find<LearningSessionService>();
  final _apiService = ApiService.instance;
  
  int? _currentSessionId;
  String? _currentContentType;
  

  Future<int?> startSession({
    required String contentType,
    required int contentId,
    String mode = 'Learn',
    int? totalItems,
  }) async {
    try {
      print('Starting session: $contentType ($contentId)');
      
      final response = await _apiService.post('/sessions/start', {
        'contentType': contentType,
        'contentId': contentId,
        'mode': mode,
        'totalItems': totalItems,
      });
      
      if (response.isOk && response.body['success'] == true) {
        _currentSessionId = response.body['data']['id'];
        _currentContentType = contentType;
        
        print('Session started: ID $_currentSessionId');
        return _currentSessionId;
      }
      
      return null;
    } catch (e) {
      print('Start session error: $e');
      return null;
    }
  }
  
 
  Future<bool> updateProgress({
    int? sessionId,
    int? completedItems,
    double? score,
  }) async {
    try {
      final id = sessionId ?? _currentSessionId;
      if (id == null) return false;
      
      final response = await _apiService.put('/sessions/$id/progress', {
        if (completedItems != null) 'completedItems': completedItems,
        if (score != null) 'score': score,
      });
      
      if (response.isOk && response.body['success'] == true) {
        print('Progress updated: $completedItems items, score: $score');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Update progress error: $e');
      return false;
    }
  }
  
  
  Future<bool> completeSession({
    int? sessionId,
    int? completedItems,
    double? score,
  }) async {
    try {
      final id = sessionId ?? _currentSessionId;
      if (id == null) return false;
      
      print('Completing session: ID $id');
      
      final response = await _apiService.post('/sessions/$id/complete', {
        if (completedItems != null) 'completedItems': completedItems,
        if (score != null) 'score': score,
      });
      
      if (response.isOk && response.body['success'] == true) {
        print('Session completed successfully!');
        
       
        _currentSessionId = null;
        _currentContentType = null;
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Complete session error: $e');
      return false;
    }
  }
  
 
  Future<List<Map<String, dynamic>>> getUserSessions({
    String? contentType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (contentType != null) {
        queryParams['contentType'] = contentType;
      }
      
      final response = await _apiService.get(
        '/sessions/my-sessions?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
      );
      
      if (response.isOk && response.body['success'] == true) {
        return List<Map<String, dynamic>>.from(response.body['data'] ?? []);
      }
      
      return [];
    } catch (e) {
      print('Get sessions error: $e');
      return [];
    }
  }
  
 
  Future<Map<String, dynamic>?> getStatistics({String? contentType}) async {
    try {
      final url = contentType != null 
          ? '/sessions/statistics?contentType=$contentType'
          : '/sessions/statistics';
          
      final response = await _apiService.get(url);
      
      if (response.isOk && response.body['success'] == true) {
        return response.body['data'];
      }
      
      return null;
    } catch (e) {
      print('Get statistics error: $e');
      return null;
    }
  }
  
 
  int? get currentSessionId => _currentSessionId;
  String? get currentContentType => _currentContentType;
  bool get hasActiveSession => _currentSessionId != null;
}