import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../data/mysql_helper.dart';

class DeckProvider with ChangeNotifier {
  final MySQLHelper _mysqlHelper = MySQLHelper();
  List<Deck> _decks = [];
  List<Deck> _publicDecks = [];
  bool _isLoading = false;
  String? _error;
  int? _currentUserId;

  List<Deck> get decks => _decks;
  List<Deck> get publicDecks => _publicDecks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCurrentUser(int userId) {
    _currentUserId = userId;
  }

  Future<void> loadUserDecks(int userId) async {
    _setLoading(true);
    _error = null;

    try {
      _decks = await _mysqlHelper.getDecksByUser(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user decks: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPublicDecks() async {
    _setLoading(true);
    _error = null;

    try {
      _publicDecks = await _mysqlHelper.getPublicDecks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading public decks: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDecksByCategory(int categoryId) async {
    _setLoading(true);
    _error = null;

    try {
      _publicDecks = await _mysqlHelper.getDecksByCategory(categoryId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading decks by category: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addDeck(Deck deck) async {
    _setLoading(true);
    _error = null;

    try {
      final deckId = await _mysqlHelper.insertDeck(deck);
      final newDeck = deck.copyWith(deckID: deckId);
      _decks.add(newDeck);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding deck: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDeck(Deck deck) async {
    _setLoading(true);
    _error = null;

    try {
      await _mysqlHelper.updateDeck(deck);
      final index = _decks.indexWhere((d) => d.deckID == deck.deckID);
      if (index != -1) {
        _decks[index] = deck;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating deck: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDeck(int deckId) async {
    _setLoading(true);
    _error = null;

    try {
      await _mysqlHelper.deleteDeck(deckId);
      _decks.removeWhere((deck) => deck.deckID == deckId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting deck: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Deck>> searchDecks(String query) async {
    try {
      return await _mysqlHelper.searchDecks(query);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching decks: $e');
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
