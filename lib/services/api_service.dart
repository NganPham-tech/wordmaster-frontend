import 'package:get/get.dart';
import '../data/models/deck_model.dart';
import '../data/models/flashcard_model.dart';
import '../data/models/grammar_card_model.dart';

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
      print('🚀 REQUEST: ${request.method} ${request.url}');
      return request;
    });
    
    httpClient.addResponseModifier((request, response) {
      print('📥 RESPONSE: ${response.statusCode} ${request.url}');
      return response;
    });

    super.onInit();
  }

  // ==================== VOCABULARY DECKS ====================
  
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

  // ==================== GRAMMAR DECKS ====================
  
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

  // ==================== ALL DECKS ====================
  
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

  // ==================== FLASHCARDS ====================
  
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

  // ==================== GRAMMAR CARDS ====================
  
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

  // ==================== ERROR HANDLING ====================
  
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