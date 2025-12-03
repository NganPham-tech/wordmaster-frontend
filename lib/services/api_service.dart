import 'package:get/get.dart';
import '../data/models/deck_model.dart';
import '../data/models/flashcard_model.dart';
import '../data/models/grammar_card_model.dart';
import 'auth_service.dart';
//D:\DemoDACN\wordmaster_dacn\lib\services\api_service.dart
class ApiService extends GetConnect {
  static ApiService? _instance;
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  ApiService._internal();

  @override
  void onInit() {
    httpClient.baseUrl = 'http://10.0.2.2:3000/api';
    httpClient.timeout = const Duration(seconds: 10);
    httpClient.defaultContentType = 'application/json';
    
    httpClient.addRequestModifier<dynamic>((request) {
      // Add authorization header if user is logged in
      if (Get.isRegistered<AuthService>()) {
        final authService = AuthService.instance;
        final token = authService.token.value;
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      
      print('REQUEST: ${request.method} ${request.url}');
      return request;
    });
    
    httpClient.addResponseModifier((request, response) {
      print('RESPONSE: ${response.statusCode} ${request.url}');
      return response;
    });

    super.onInit();
  }

  
  
  Future<List<Deck>> getVocabularyDecks() async {
    try {
      final response = await get('/decks/vocabulary');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      final List<dynamic> data = response.body;
      return data.map((json) => Deck.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }


  
  Future<List<Deck>> getGrammarDecks() async {
    try {
      final response = await get('/decks/grammar');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      final List<dynamic> data = response.body;
      return data.map((json) => Deck.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

 
  
  Future<List<Deck>> getDecks() async {
    try {
      final response = await get('/decks');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      final List<dynamic> data = response.body;
      return data.map((json) => Deck.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Deck> getDeckById(int id) async {
    try {
      final response = await get('/decks/$id');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      return Deck.fromJson(response.body);
    } catch (e) {
      rethrow;
    }
  }


  
  Future<List<Flashcard>> getFlashcardsByDeck(int deckId) async {
    try {
      final response = await get('/flashcards/deck/$deckId');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      final List<dynamic> data = response.body;
      return data.map((json) => Flashcard.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Flashcard> getFlashcardById(int id) async {
    try {
      final response = await get('/flashcards/$id');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      return Flashcard.fromJson(response.body);
    } catch (e) {
      rethrow;
    }
  }


  
  Future<List<GrammarCard>> getGrammarCardsByDeck(int deckId) async {
    try {
      final response = await get('/grammar/deck/$deckId');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      final List<dynamic> data = response.body;
      return data.map((json) => GrammarCard.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<GrammarCard> getGrammarCardById(int id) async {
    try {
      final response = await get('/grammar/$id');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      return GrammarCard.fromJson(response.body);
    } catch (e) {
      rethrow;
    }
  }

  
  
  Future<List<dynamic>> getDictationContent(Map<String, String> queryParams) async {
    try {
      String queryString = '';
      if (queryParams.isNotEmpty) {
        queryString = '?' + queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }
      
      final response = await get('/dictation$queryString');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      final responseData = response.body;
      if (responseData['success'] == true) {
        return responseData['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDictationById(int id) async {
    try {
      final response = await get('/dictation/$id');
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      final responseData = response.body;
      if (responseData['success'] == true) {
        return responseData['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addYouTubeVideo({
    required int userId,
    required String sourceURL,
    required String difficulty,
  }) async {
    try {
      final response = await post('/dictation/user-add-youtube', {
        'userId': userId,
        'sourceURL': sourceURL,
        'difficulty': difficulty,
      });
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitDictationResult({
    required int contentId,
    required int userId,
    required String userTranscript,
    int? timeSpent,
  }) async {
    try {
      final response = await post('/dictation/$contentId/submit', {
        'userId': userId,
        'userTranscript': userTranscript,
        'timeSpent': timeSpent,
      });
      
      if (response.hasError) {
        throw _handleError(response);
      }
      
      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  
  String _handleError(Response response) {
    switch (response.statusCode) {
      case 400:
        return response.body['message'] ?? 'Yêu cầu không hợp lệ';
      case 401:
        return 'Unauthorized';
      case 404:
        return response.body['message'] ?? 'Không tìm thấy dữ liệu';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau';
      default:
        return 'Không thể kết nối đến server';
    }
  }
}