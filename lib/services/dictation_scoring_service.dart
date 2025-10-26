// lib/services/dictation_scoring_service.dart
import '../models/dictation.dart';

class DictationScoringService {
  /// Chấm điểm dictation và trả về kết quả chi tiết
  static DictationResult scoreText({
    required int lessonId,
    required String userInput,
    required String correctText,
    required int timeSpentSeconds,
  }) {
    // Normalize text: lowercase, trim, remove extra spaces
    final normalizedUser = _normalizeText(userInput);
    final normalizedCorrect = _normalizeText(correctText);

    // Split into words
    final userWords = normalizedUser
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    final correctWords = normalizedCorrect
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    // Compare words
    final comparisons = _compareWords(userWords, correctWords);
    final correctWordCount = comparisons.where((c) => c.isCorrect).length;

    // Character accuracy
    final userChars = normalizedUser.replaceAll(' ', '');
    final correctChars = normalizedCorrect.replaceAll(' ', '');
    final correctCharCount = _countMatchingChars(userChars, correctChars);

    return DictationResult(
      lessonId: lessonId,
      userInput: userInput,
      correctText: correctText,
      totalWords: correctWords.length,
      correctWords: correctWordCount,
      totalCharacters: correctChars.length,
      correctCharacters: correctCharCount,
      wordComparisons: comparisons,
      completedAt: DateTime.now(),
      timeSpentSeconds: timeSpentSeconds,
    );
  }

  /// Normalize text: lowercase, trim, remove punctuation
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }

  /// So sánh từng từ giữa user input và correct text
  static List<WordComparison> _compareWords(
    List<String> userWords,
    List<String> correctWords,
  ) {
    final comparisons = <WordComparison>[];
    final maxLength = userWords.length > correctWords.length
        ? userWords.length
        : correctWords.length;

    for (int i = 0; i < maxLength; i++) {
      final userWord = i < userWords.length ? userWords[i] : '';
      final correctWord = i < correctWords.length ? correctWords[i] : '';

      comparisons.add(
        WordComparison(
          userWord: userWord,
          correctWord: correctWord,
          isCorrect: userWord == correctWord,
          position: i,
        ),
      );
    }

    return comparisons;
  }

  /// Đếm số ký tự khớp (dùng Levenshtein distance để tính accuracy)
  static int _countMatchingChars(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0;

    final maxLen = s1.length > s2.length ? s1.length : s2.length;
    final distance = _levenshteinDistance(s1, s2);
    final matchingChars = maxLen - distance;

    return matchingChars > 0 ? matchingChars : 0;
  }

  /// Tính Levenshtein distance (số lượng thay đổi tối thiểu để biến s1 thành s2)
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;

    // Create matrix
    final matrix = List.generate(
      len1 + 1,
      (i) => List<int>.filled(len2 + 1, 0),
    );

    // Initialize first row and column
    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    // Fill matrix
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = _min3(
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        );
      }
    }

    return matrix[len1][len2];
  }

  static int _min3(int a, int b, int c) {
    return a < b ? (a < c ? a : c) : (b < c ? b : c);
  }

  /// Kiểm tra xem user có thể pass bài dictation không (>= 70% accuracy)
  static bool isPassed(DictationResult result) {
    return result.wordAccuracy >= 70;
  }

  /// Tính điểm từ 0-100 dựa trên accuracy
  static int calculateScore(DictationResult result) {
    return result.wordAccuracy.round();
  }

  /// Phân tích lỗi thường gặp
  static Map<String, int> analyzeErrors(DictationResult result) {
    final errors = <String, int>{
      'missing_words': 0, // Thiếu từ
      'extra_words': 0, // Thừa từ
      'wrong_words': 0, // Sai từ
      'spelling_errors': 0, // Lỗi chính tả
    };

    for (final comparison in result.wordComparisons) {
      if (comparison.isCorrect) continue;

      if (comparison.userWord.isEmpty) {
        errors['missing_words'] = errors['missing_words']! + 1;
      } else if (comparison.correctWord.isEmpty) {
        errors['extra_words'] = errors['extra_words']! + 1;
      } else if (_isSimilar(comparison.userWord, comparison.correctWord)) {
        errors['spelling_errors'] = errors['spelling_errors']! + 1;
      } else {
        errors['wrong_words'] = errors['wrong_words']! + 1;
      }
    }

    return errors;
  }

  /// Kiểm tra 2 từ có giống nhau không (cho phép 1-2 ký tự sai)
  static bool _isSimilar(String word1, String word2) {
    if (word1.length < 3 || word2.length < 3) return false;

    final distance = _levenshteinDistance(word1, word2);
    final maxLen = word1.length > word2.length ? word1.length : word2.length;

    return distance <= 2 && distance < maxLen * 0.5;
  }
}
