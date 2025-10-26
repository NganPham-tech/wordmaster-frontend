import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/study_session.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create Decks table
    await db.execute('''
      CREATE TABLE ${AppConstants.decksTable} (
        deckID INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        imagePath TEXT,
        createdDate TEXT NOT NULL,
        lastStudied TEXT,
        totalCards INTEGER DEFAULT 0,
        masteredCards INTEGER DEFAULT 0
      )
    ''');

    // Create Flashcards table
    await db.execute('''
      CREATE TABLE ${AppConstants.flashcardsTable} (
        flashcardID INTEGER PRIMARY KEY AUTOINCREMENT,
        deckID INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        example TEXT,
        audioPath TEXT,
        imagePath TEXT,
        status TEXT DEFAULT 'fresh',
        nextReviewDate TEXT,
        difficulty INTEGER DEFAULT 1,
        reviewCount INTEGER DEFAULT 0,
        FOREIGN KEY (deckID) REFERENCES ${AppConstants.decksTable} (deckID) ON DELETE CASCADE
      )
    ''');

    // Create Study Sessions table
    await db.execute('''
      CREATE TABLE ${AppConstants.studySessionsTable} (
        sessionID INTEGER PRIMARY KEY AUTOINCREMENT,
        deckID INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        totalCards INTEGER DEFAULT 0,
        correctAnswers INTEGER DEFAULT 0,
        wrongAnswers INTEGER DEFAULT 0,
        score REAL DEFAULT 0.0,
        FOREIGN KEY (deckID) REFERENCES ${AppConstants.decksTable} (deckID) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_flashcards_deckid ON ${AppConstants.flashcardsTable} (deckID)
    ''');

    await db.execute('''
      CREATE INDEX idx_sessions_deckid ON ${AppConstants.studySessionsTable} (deckID)
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades here when version changes
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Deck operations
  Future<int> insertDeck(Deck deck) async {
    final db = await database;
    return await db.insert(AppConstants.decksTable, deck.toMap());
  }

  Future<List<Deck>> getAllDecks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.decksTable,
    );
    return List.generate(maps.length, (i) => Deck.fromMap(maps[i]));
  }

  Future<Deck?> getDeckById(int deckID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.decksTable,
      where: 'deckID = ?',
      whereArgs: [deckID],
    );
    if (maps.isNotEmpty) {
      return Deck.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateDeck(Deck deck) async {
    final db = await database;
    await db.update(
      AppConstants.decksTable,
      deck.toMap(),
      where: 'deckID = ?',
      whereArgs: [deck.deckID],
    );
  }

  Future<void> deleteDeck(int deckID) async {
    final db = await database;
    await db.delete(
      AppConstants.decksTable,
      where: 'deckID = ?',
      whereArgs: [deckID],
    );
  }

  // Flashcard operations
  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.insert(AppConstants.flashcardsTable, flashcard.toMap());
  }

  Future<List<Flashcard>> getFlashcardsByDeck(int deckID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.flashcardsTable,
      where: 'deckID = ?',
      whereArgs: [deckID],
    );
    return List.generate(maps.length, (i) => Flashcard.fromMap(maps[i]));
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    final db = await database;
    await db.update(
      AppConstants.flashcardsTable,
      flashcard.toMap(),
      where: 'flashcardID = ?',
      whereArgs: [flashcard.flashcardID],
    );
  }

  Future<void> deleteFlashcard(int flashcardID) async {
    final db = await database;
    await db.delete(
      AppConstants.flashcardsTable,
      where: 'flashcardID = ?',
      whereArgs: [flashcardID],
    );
  }

  // Study Session operations
  Future<int> insertStudySession(StudySession session) async {
    final db = await database;
    return await db.insert(AppConstants.studySessionsTable, session.toMap());
  }

  Future<List<StudySession>> getStudySessionsByDeck(int deckID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.studySessionsTable,
      where: 'deckID = ?',
      whereArgs: [deckID],
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => StudySession.fromMap(maps[i]));
  }

  // Utility methods
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
