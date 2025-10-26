import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // App Information
  static const String appName = 'WordMaster';
  static const String appVersion = '1.0.0';

  // Environment-based configuration
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static String get defaultLanguage =>
      dotenv.env['DEFAULT_LANGUAGE'] ?? 'en-US';
  static int get maxSessionSize =>
      int.tryParse(dotenv.env['MAX_SESSION_SIZE'] ?? '50') ?? 50;
  static String get defaultDifficulty =>
      dotenv.env['DEFAULT_DIFFICULTY'] ?? 'Medium';

  // Database Configuration
  static String get databaseName => dotenv.env['DB_NAME'] ?? 'wordmaster.db';
  static int get databaseVersion => 1;

  // API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.wordmaster.com';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Table Names (MySQL)
  static const String usersTable = 'User';
  static const String categoriesTable = 'Categories';
  static const String decksTable = 'Deck';
  static const String flashcardsTable = 'Flashcard';
  static const String studySessionsTable = 'StudySession';
  static const String learningHistoryTable = 'LearningHistory';
  static const String quizTable = 'Quiz';
  static const String quizQuestionTable = 'QuizQuestion';
  static const String quizOptionsTable = 'QuizOptions';
  static const String achievementTable = 'Achievement';
  static const String userAchievementTable = 'UserAchievement';
  static const String userProgressTable = 'UserProgress';
  static const String deckRatingsTable = 'DeckRatings';

  // SharedPreferences Keys
  static const String firstLaunchKey = 'first_launch';
  static const String userStatsKey = 'user_stats';
  static const String settingsKey = 'app_settings';

  // Study Settings
  static const int defaultStudySessionSize = 10;
  static const int maxStudySessionSize = 50;
  static const double defaultSpeechRate = 0.5;
  static const double defaultVolume = 1.0;
  static const double defaultPitch = 1.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // File Paths
  static const String audioFolder = 'audio';
  static const String imageFolder = 'images';

  // API Endpoints (if needed in future)
  static const String baseUrl = 'https://api.wordmaster.com';

  // Error Messages
  static const String networkError = 'Lỗi kết nối mạng';
  static const String databaseError = 'Lỗi cơ sở dữ liệu';
  static const String fileError = 'Lỗi tệp tin';
  static const String permissionError = 'Không có quyền truy cập';
}
