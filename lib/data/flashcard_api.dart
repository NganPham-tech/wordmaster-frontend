// // lib/data/flashcard_api.dart
// import 'package:flutter/material.dart';

// class FlashcardAPI {
//   static const String baseUrl = 'https://your-api-domain.com/api';

//   // Lấy danh sách categories theo type
//   static Future<List<Category>> getCategories({required String type}) async {
//     await Future.delayed(const Duration(milliseconds: 500));

//     if (type == 'vocabulary') {
//       return [
//         Category(
//           id: 1,
//           name: 'Động vật',
//           description: 'Học từ vựng về các loài động vật',
//           icon: Icons.pets,
//           colorCode: '#FF9800',
//           deckCount: 3,
//         ),
//         Category(
//           id: 2,
//           name: 'Đồ ăn',
//           description: 'Từ vựng về đồ ăn và thức uống',
//           icon: Icons.restaurant,
//           colorCode: '#4CAF50',
//           deckCount: 5,
//         ),
//         Category(
//           id: 3,
//           name: 'Du lịch',
//           description: 'Từ vựng thông dụng khi du lịch',
//           icon: Icons.flight,
//           colorCode: '#2196F3',
//           deckCount: 4,
//         ),
//         Category(
//           id: 4,
//           name: 'Công việc',
//           description: 'Từ vựng văn phòng và chuyên ngành',
//           icon: Icons.work,
//           colorCode: '#9C27B0',
//           deckCount: 6,
//         ),
//       ];
//     } else {
//       return [
//         Category(
//           id: 5,
//           name: 'Thì trong tiếng Anh',
//           description: 'Các thì cơ bản và nâng cao',
//           icon: Icons.schedule,
//           colorCode: '#F44336',
//           deckCount: 8,
//         ),
//         Category(
//           id: 6,
//           name: 'Câu điều kiện',
//           description: 'Các loại câu điều kiện',
//           icon: Icons.help,
//           colorCode: '#FFC107',
//           deckCount: 3,
//         ),
//         Category(
//           id: 7,
//           name: 'Mệnh đề quan hệ',
//           description: 'Relative clauses và ứng dụng',
//           icon: Icons.link,
//           colorCode: '#607D8B',
//           deckCount: 4,
//         ),
//       ];
//     }
//   }

//   // Lấy danh sách deck theo category
//   static Future<List<Deck>> getDecksByCategory(int categoryId) async {
//     await Future.delayed(const Duration(milliseconds: 300));

//     return List.generate(4, (index) => Deck(
//       id: categoryId * 10 + index,
//       categoryId: categoryId,
//       name: 'Deck ${categoryId * 10 + index}',
//       description: 'Bộ thẻ từ vựng chủ đề ${categoryId * 10 + index}',
//       thumbnail: null,
//       totalCards: 20 + index * 5,
//       learnedCards: index * 3,
//       rating: 4.5 - index * 0.1,
//       isPublic: true,
//     ));
//   }

//   // Lấy flashcard theo deck
//   static Future<List<Flashcard>> getFlashcardsByDeck(int deckId) async {
//     await Future.delayed(const Duration(milliseconds: 400));

//     return List.generate(15, (index) => Flashcard(
//       id: deckId * 100 + index,
//       deckId: deckId,
//       type: deckId < 50 ? 'vocabulary' : 'grammar',
//       question: deckId < 50 ? 'Hello $index' : 'Present Simple $index',
//       answer: deckId < 50 ? 'Xin chào $index' : 'Diễn tả hành động thường xuyên',
//       example: deckId < 50
//           ? 'Hello, how are you today? This is example $index'
//           : 'I go to school every day. Example $index',
//       phonetic: deckId < 50 ? '/həˈloʊ/' : null,
//       imagePath: null,
//       difficulty: ['Easy', 'Medium', 'Hard'][index % 3],
//       wordType: deckId < 50 ? ['Noun', 'Verb', 'Adjective'][index % 3] : null,
//     ));
//   }

//   // Cập nhật progress học
//   static Future<void> updateLearningProgress(LearningUpdate update) async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     print('Updated: ${update.toJson()}');
//   }
// }

// class Category {
//   final int id;
//   final String name;
//   final String description;
//   final IconData icon;
//   final String colorCode;
//   final int deckCount;

//   Category({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.icon,
//     required this.colorCode,
//     required this.deckCount,
//   });
// }

// class Deck {
//   final int id;
//   final int categoryId;
//   final String name;
//   final String description;
//   final String? thumbnail;
//   final int totalCards;
//   final int learnedCards;
//   final double rating;
//   final bool isPublic;

//   Deck({
//     required this.id,
//     required this.categoryId,
//     required this.name,
//     required this.description,
//     this.thumbnail,
//     required this.totalCards,
//     required this.learnedCards,
//     required this.rating,
//     required this.isPublic,
//   });

//   double get progress => totalCards > 0 ? learnedCards / totalCards : 0;
// }

// class Flashcard {
//   final int id;
//   final int deckId;
//   final String type;
//   final String question;
//   final String answer;
//   final String? example;
//   final String? phonetic;
//   final String? imagePath;
//   final String? difficulty;
//   final String? wordType;
//   bool isFlipped;
//   bool isRemembered;

//   Flashcard({
//     required this.id,
//     required this.deckId,
//     required this.type,
//     required this.question,
//     required this.answer,
//     this.example,
//     this.phonetic,
//     this.imagePath,
//     this.difficulty,
//     this.wordType,
//     this.isFlipped = false,
//     this.isRemembered = false,
//   });
// }

// class LearningUpdate {
//   final int userId;
//   final int flashcardId;
//   final String status;
//   final bool remembered;

//   LearningUpdate({
//     required this.userId,
//     required this.flashcardId,
//     required this.status,
//     required this.remembered,
//   });

//   Map<String, dynamic> toJson() => {
//     'userId': userId,
//     'flashcardId': flashcardId,
//     'status': status,
//     'remembered': remembered,
//   };
// }
import '../services/api_service.dart';
import '../models/category.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';

class FlashcardAPI {
  static Future<List<Category>> getCategories({String? type}) async {
    String endpoint = '/categories';
    if (type != null) endpoint += '?type=$type';

    final response = await ApiService.get(endpoint);
    if (response['success'] == true) {
      List<dynamic> data = response['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Deck>> getDecksByCategory(int categoryId) async {
    final response = await ApiService.get(
      '/decks/get_by_categories?categoryId=$categoryId',
    );

    if (response['success'] == true) {
      List<dynamic> data = response['data'];
      return data.map((json) => Deck.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Flashcard>> getFlashcardsByDeck(int deckId) async {
    final response = await ApiService.get('/flashcards/by_deck_$deckId');

    if (response['success'] == true) {
      List<dynamic> data = response['data'];
      return data.map((json) => Flashcard.fromJson(json)).toList();
    }
    return [];
  }
}
