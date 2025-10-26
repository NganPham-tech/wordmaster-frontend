import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../data/database_helper.dart';

class FlashcardProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Flashcard> _flashcards = [];
  bool _isLoading = false;
  String? _error;

  List<Flashcard> get flashcards => _flashcards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFlashcardsByDeck(int deckId) async {
    _setLoading(true);
    _error = null;

    try {
      _flashcards = await _databaseHelper.getFlashcardsByDeck(deckId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading flashcards: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    _setLoading(true);
    _error = null;

    try {
      final flashcardId = await _databaseHelper.insertFlashcard(flashcard);
      final newFlashcard = flashcard.copyWith(flashcardID: flashcardId);
      _flashcards.add(newFlashcard);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding flashcard: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseHelper.updateFlashcard(flashcard);
      final index = _flashcards.indexWhere(
        (f) => f.flashcardID == flashcard.flashcardID,
      );
      if (index != -1) {
        _flashcards[index] = flashcard;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating flashcard: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteFlashcard(int flashcardId) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseHelper.deleteFlashcard(flashcardId);
      _flashcards.removeWhere(
        (flashcard) => flashcard.flashcardID == flashcardId,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting flashcard: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<Flashcard> getFlashcardsByStatus(CardStatus status) {
    return _flashcards.where((card) => card.status == status).toList();
  }

  List<Flashcard> getFlashcardsForReview() {
    final now = DateTime.now();
    return _flashcards.where((card) {
      return card.nextReviewDate != null && card.nextReviewDate!.isBefore(now);
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearFlashcards() {
    _flashcards.clear();
    notifyListeners();
  }
}
