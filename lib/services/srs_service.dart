import 'api_service.dart';

class SrsService {
  static SrsService? _instance;
  static SrsService get instance {
    _instance ??= SrsService._internal();
    return _instance!;
  }
  SrsService._internal();

  final _api = ApiService.instance;


  Future<Map<String, dynamic>> getDueReviews({
    required int userId,
    String contentType = 'Mixed',
  }) async {
    try {
      final response = await _api.get(
        '/spaced-repetition/due-reviews/$userId',
        query: {'contentType': contentType},
      );

      if (response.hasError) {
        throw Exception(response.body['error'] ?? 'Failed to get due reviews');
      }
      
      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('getDueReviews error: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getDailyStats(int userId) async {
    try {
      final response = await _api.get('/spaced-repetition/daily-stats/$userId');
      
      if (response.hasError) {
        throw Exception(response.body['error'] ?? 'Failed to get daily stats');
      }
      
      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('getDailyStats error: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> submitReview({
    required int userId,
    required String contentType, 
    required int contentId,
    required String difficulty, 
  }) async {
    try {
      final response = await _api.post('/spaced-repetition/submit-review', {
        'userId': userId,
        'contentType': contentType,
        'contentId': contentId,
        'difficulty': difficulty,
      });

      if (response.hasError) {
        throw Exception(response.body['error'] ?? 'Failed to submit review');
      }
      
      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('submitReview error: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getSettings(int userId) async {
    try {
      final response = await _api.get('/spaced-repetition/settings/$userId');
      
      if (response.hasError) {
        throw Exception(response.body['error'] ?? 'Failed to get settings');
      }
      
      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('getSettings error: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> startNewCards({
    required int userId,
    required String contentType,
    required List<int> contentIds,
  }) async {
    try {
      final response = await _api.post('/spaced-repetition/start-new-cards', {
        'userId': userId,
        'contentType': contentType,
        'contentIds': contentIds,
      });

      if (response.hasError) {
        throw Exception(response.body['error'] ?? 'Failed to start new cards');
      }
      
      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('startNewCards error: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getProgress({
    required int userId,
    String contentType = 'Mixed',
  }) async {
    try {
      final response = await _api.get(
        '/spaced-repetition/progress/$userId',
        query: {'contentType': contentType},
      );

      if (response.hasError) {
        throw Exception(response.body['error'] ?? 'Failed to get progress');
      }
      
      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('getProgress error: $e');
      rethrow;
    }
  }
}