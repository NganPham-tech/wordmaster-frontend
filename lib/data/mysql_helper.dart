import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/study_session.dart';
import '../models/category.dart';
import '../models/achievement.dart';
import '../models/quiz.dart';

class MySQLHelper {
  static final MySQLHelper _instance = MySQLHelper._internal();
  factory MySQLHelper() => _instance;
  MySQLHelper._internal();

  MySqlConnection? _connection;

  // Database connection settings from .env
  String get _host => dotenv.env['DB_HOST'] ?? 'localhost';
  int get _port => int.tryParse(dotenv.env['DB_PORT'] ?? '3306') ?? 3306;
  String get _user => dotenv.env['DB_USER'] ?? 'root';
  String get _password => dotenv.env['DB_PASSWORD'] ?? '';
  String get _database => dotenv.env['DB_NAME'] ?? 'wordmasterapp';

  Future<MySqlConnection> get connection async {
    if (_connection == null) {
      await _connect();
    }
    return _connection!;
  }

  Future<void> _connect() async {
    final settings = ConnectionSettings(
      host: _host,
      port: _port,
      user: _user,
      password: _password,
      db: _database,
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      print('Connected to MySQL database successfully');
    } catch (e) {
      print('Error connecting to MySQL: $e');
      rethrow;
    }
  }

  Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  // ============================================
  // USER OPERATIONS
  // ============================================

  Future<int> insertUser(User user) async {
    final conn = await connection;
    var result = await conn.query(
      'INSERT INTO User (FullName, Email, Password, Avatar) VALUES (?, ?, ?, ?)',
      [user.fullName, user.email, user.password, user.avatar],
    );
    return result.insertId!;
  }

  Future<User?> getUserByEmail(String email) async {
    final conn = await connection;
    var results = await conn.query('SELECT * FROM User WHERE Email = ?', [
      email,
    ]);

    if (results.isNotEmpty) {
      return User.fromMap(results.first.fields);
    }
    return null;
  }

  Future<User?> getUserById(int userId) async {
    final conn = await connection;
    var results = await conn.query('SELECT * FROM User WHERE UserID = ?', [
      userId,
    ]);

    if (results.isNotEmpty) {
      return User.fromMap(results.first.fields);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final conn = await connection;
    await conn.query(
      'UPDATE User SET FullName = ?, Email = ?, Avatar = ?, LastLogin = ? WHERE UserID = ?',
      [
        user.fullName,
        user.email,
        user.avatar,
        user.lastLogin?.toIso8601String(),
        user.userID,
      ],
    );
  }

  // ============================================
  // CATEGORY OPERATIONS
  // ============================================

  Future<int> insertCategory(Category category) async {
    final conn = await connection;
    var result = await conn.query(
      'INSERT INTO Categories (Name, Description, ColorCode, Icon) VALUES (?, ?, ?, ?)',
      [category.name, category.description, category.colorCode, category.icon],
    );
    return result.insertId!;
  }

  Future<List<Category>> getAllCategories() async {
    final conn = await connection;
    var results = await conn.query('SELECT * FROM Categories ORDER BY Name');

    return results.map((row) => Category.fromMap(row.fields)).toList();
  }

  // ============================================
  // DECK OPERATIONS
  // ============================================

  Future<int> insertDeck(Deck deck) async {
    final conn = await connection;
    var result = await conn.query(
      'INSERT INTO Deck (UserID, CategoryID, Name, Description, Thumbnail, IsPublic) VALUES (?, ?, ?, ?, ?, ?)',
      [
        deck.userID,
        deck.categoryID,
        deck.name,
        deck.description,
        deck.thumbnail,
        deck.isPublic,
      ],
    );
    return result.insertId!;
  }

  Future<List<Deck>> getDecksByUser(int userId) async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM Deck WHERE UserID = ? ORDER BY CreatedAt DESC',
      [userId],
    );

    return results.map((row) => Deck.fromMap(row.fields)).toList();
  }

  Future<List<Deck>> getPublicDecks() async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM Deck WHERE IsPublic = TRUE ORDER BY Rating DESC, ViewCount DESC',
    );

    return results.map((row) => Deck.fromMap(row.fields)).toList();
  }

  Future<List<Deck>> getDecksByCategory(int categoryId) async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM Deck WHERE CategoryID = ? AND IsPublic = TRUE ORDER BY Rating DESC',
      [categoryId],
    );

    return results.map((row) => Deck.fromMap(row.fields)).toList();
  }

  Future<void> updateDeck(Deck deck) async {
    final conn = await connection;
    await conn.query(
      'UPDATE Deck SET Name = ?, Description = ?, Thumbnail = ?, IsPublic = ? WHERE DeckID = ?',
      [deck.name, deck.description, deck.thumbnail, deck.isPublic, deck.deckID],
    );
  }

  Future<void> deleteDeck(int deckId) async {
    final conn = await connection;
    await conn.query('DELETE FROM Deck WHERE DeckID = ?', [deckId]);
  }

  // ============================================
  // FLASHCARD OPERATIONS
  // ============================================

  Future<int> insertFlashcard(Flashcard flashcard) async {
    final conn = await connection;
    var result = await conn.query(
      'INSERT INTO Flashcard (DeckID, CardType, Question, Answer, Example, Phonetic, ImagePath, Difficulty, WordType) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        flashcard.deckID,
        flashcard.cardType.toString().split('.').last,
        flashcard.question,
        flashcard.answer,
        flashcard.example,
        flashcard.phonetic,
        flashcard.imagePath,
        flashcard.difficulty.toString().split('.').last,
        flashcard.wordType,
      ],
    );
    return result.insertId!;
  }

  Future<List<Flashcard>> getFlashcardsByDeck(int deckId) async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM Flashcard WHERE DeckID = ? ORDER BY CreatedAt',
      [deckId],
    );

    return results.map((row) => Flashcard.fromMap(row.fields)).toList();
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    final conn = await connection;
    await conn.query(
      'UPDATE Flashcard SET Question = ?, Answer = ?, Example = ?, Phonetic = ?, ImagePath = ?, Difficulty = ?, WordType = ? WHERE FlashcardID = ?',
      [
        flashcard.question,
        flashcard.answer,
        flashcard.example,
        flashcard.phonetic,
        flashcard.imagePath,
        flashcard.difficulty.toString().split('.').last,
        flashcard.wordType,
        flashcard.flashcardID,
      ],
    );
  }

  Future<void> deleteFlashcard(int flashcardId) async {
    final conn = await connection;
    await conn.query('DELETE FROM Flashcard WHERE FlashcardID = ?', [
      flashcardId,
    ]);
  }

  // ============================================
  // LEARNING HISTORY OPERATIONS (SRS Algorithm)
  // ============================================

  Future<void> updateLearningProgress(
    int userId,
    int flashcardId,
    String status,
    int repetitions,
    double easeFactor,
    int intervalDays,
    DateTime nextReviewDate,
  ) async {
    final conn = await connection;

    // Check if record exists
    var existing = await conn.query(
      'SELECT * FROM LearningHistory WHERE UserID = ? AND FlashcardID = ?',
      [userId, flashcardId],
    );

    if (existing.isEmpty) {
      // Insert new record
      await conn.query(
        'INSERT INTO LearningHistory (UserID, FlashcardID, Status, Repetitions, EaseFactor, IntervalDays, LastReviewed, NextReviewDate) VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)',
        [
          userId,
          flashcardId,
          status,
          repetitions,
          easeFactor,
          intervalDays,
          nextReviewDate.toIso8601String().split('T')[0],
        ],
      );
    } else {
      // Update existing record
      await conn.query(
        'UPDATE LearningHistory SET Status = ?, Repetitions = ?, EaseFactor = ?, IntervalDays = ?, LastReviewed = NOW(), NextReviewDate = ? WHERE UserID = ? AND FlashcardID = ?',
        [
          status,
          repetitions,
          easeFactor,
          intervalDays,
          nextReviewDate.toIso8601String().split('T')[0],
          userId,
          flashcardId,
        ],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCardsForReview(int userId) async {
    final conn = await connection;
    var results = await conn.query(
      '''
      SELECT f.*, lh.Status, lh.NextReviewDate, lh.EaseFactor, lh.IntervalDays, lh.Repetitions
      FROM Flashcard f
      INNER JOIN LearningHistory lh ON f.FlashcardID = lh.FlashcardID
      WHERE lh.UserID = ? AND lh.NextReviewDate <= CURDATE()
      ORDER BY lh.NextReviewDate
    ''',
      [userId],
    );

    return results.map((row) => row.fields).toList();
  }

  // ============================================
  // STUDY SESSION OPERATIONS
  // ============================================

  Future<int> insertStudySession(StudySession session) async {
    final conn = await connection;
    var result = await conn.query(
      'INSERT INTO StudySession (UserID, DeckID, Mode, Score, TotalCards, CorrectCards, Duration, StartedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        session.userID,
        session.deckID,
        session.mode.toString().split('.').last,
        session.score,
        session.totalCards,
        session.correctCards,
        session.duration,
        session.startedAt.toIso8601String(),
      ],
    );
    return result.insertId!;
  }

  Future<void> completeStudySession(
    int sessionId,
    int score,
    int correctCards,
    Duration duration,
  ) async {
    final conn = await connection;
    await conn.query(
      'UPDATE StudySession SET Score = ?, CorrectCards = ?, Duration = ?, CompletedAt = NOW() WHERE SessionID = ?',
      [score, correctCards, duration.inSeconds, sessionId],
    );
  }

  Future<List<StudySession>> getStudySessionsByUser(
    int userId, {
    int limit = 10,
  }) async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM StudySession WHERE UserID = ? ORDER BY StartedAt DESC LIMIT ?',
      [userId, limit],
    );

    return results.map((row) => StudySession.fromMap(row.fields)).toList();
  }

  // ============================================
  // QUIZ OPERATIONS
  // ============================================

  Future<List<Quiz>> getQuizzesByDeck(int deckId) async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM Quiz WHERE DeckID = ? ORDER BY CreatedAt DESC',
      [deckId],
    );

    return results.map((row) => Quiz.fromMap(row.fields)).toList();
  }

  // ============================================
  // ACHIEVEMENT OPERATIONS
  // ============================================

  Future<List<Achievement>> getAllAchievements() async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM Achievement ORDER BY SortOrder, Category',
    );

    return results.map((row) => Achievement.fromMap(row.fields)).toList();
  }

  Future<List<Map<String, dynamic>>> getUserAchievements(int userId) async {
    final conn = await connection;
    var results = await conn.query(
      '''
      SELECT a.*, ua.Progress, ua.IsUnlocked, ua.UnlockedAt
      FROM Achievement a
      LEFT JOIN UserAchievement ua ON a.AchievementID = ua.AchievementID AND ua.UserID = ?
      ORDER BY a.SortOrder, a.Category
    ''',
      [userId],
    );

    return results.map((row) => row.fields).toList();
  }

  // ============================================
  // STATISTICS
  // ============================================

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final conn = await connection;

    // Get basic user progress
    var progressResult = await conn.query(
      'SELECT * FROM UserProgress WHERE UserID = ?',
      [userId],
    );

    Map<String, dynamic> stats = {};

    if (progressResult.isNotEmpty) {
      stats = Map<String, dynamic>.from(progressResult.first.fields);
    }

    // Get additional statistics
    var deckCount = await conn.query(
      'SELECT COUNT(*) as count FROM Deck WHERE UserID = ?',
      [userId],
    );
    stats['deckCount'] = deckCount.first.fields['count'];

    var sessionCount = await conn.query(
      'SELECT COUNT(*) as count FROM StudySession WHERE UserID = ? AND CompletedAt IS NOT NULL',
      [userId],
    );
    stats['completedSessions'] = sessionCount.first.fields['count'];

    return stats;
  }

  // ============================================
  // SEARCH OPERATIONS
  // ============================================

  Future<List<Deck>> searchDecks(String query) async {
    final conn = await connection;
    var results = await conn.query(
      'SELECT * FROM Deck WHERE IsPublic = TRUE AND (Name LIKE ? OR Description LIKE ?) ORDER BY Rating DESC',
      ['%$query%', '%$query%'],
    );

    return results.map((row) => Deck.fromMap(row.fields)).toList();
  }
}
