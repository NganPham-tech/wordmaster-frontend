import '../data/models/feynman_note_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class FeynmanService {
  final ApiService _apiService = ApiService.instance;
  final AuthService _authService = AuthService.instance;


  Future<FeynmanNote?> saveNote({
    required String cardType,
    required int cardId,
    required String textNote,
  }) async {
    try {
      final userId = _authService.userId;
      print('Saving Feynman note for user: $userId, card: $cardType/$cardId');
      
      final response = await _apiService.post('/feynman/notes', {
        'userId': userId,
        'cardType': cardType,
        'cardId': cardId,
        'textNote': textNote,
      });

      print('Save response: ${response.statusCode}');
      print('Save body: ${response.body}');

      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          return FeynmanNote.fromJson(responseData['data']);
        }
      }
      
      throw Exception('Failed to save note: ${response.body}');
    } catch (e) {
      print('Error saving Feynman note: $e');
      return null;
    }
  }


  Future<FeynmanNote?> getNote({
    required String cardType,
    required int cardId,
  }) async {
    try {
      final userId = _authService.userId;
      print('Getting Feynman note for user: $userId, card: $cardType/$cardId');
      
      final response = await _apiService.get(
        '/feynman/notes?userId=$userId&cardType=$cardType&cardId=$cardId'
      );

      print('Get response: ${response.statusCode}');
      print('Get body: ${response.body}');

      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          return FeynmanNote.fromJson(responseData['data']);
        }
      }
      
      return null; 
    } catch (e) {
      print('Error getting Feynman note: $e');
      return null;
    }
  }

 
  Future<List<FeynmanNote>> getAllNotes({String? cardType}) async {
    try {
      final userId = _authService.userId;
      String endpoint = '/feynman/notes?userId=$userId';
      if (cardType != null) {
        endpoint += '&cardType=$cardType';
      }

      final response = await _apiService.get(endpoint);

      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => FeynmanNote.fromJson(json)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting Feynman notes: $e');
      return [];
    }
  }

  
  Future<bool> deleteNote({
    required String cardType,
    required int cardId,
  }) async {
    try {
      final userId = _authService.userId;
      final response = await _apiService.delete(
        '/feynman/notes?userId=$userId&cardType=$cardType&cardId=$cardId'
      );

      return response.isOk;
    } catch (e) {
      print('Error deleting Feynman note: $e');
      return false;
    }
  }
}