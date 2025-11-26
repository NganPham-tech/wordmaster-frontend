import 'models/quiz_topic_model.dart';
import '../services/api_service.dart';

class QuizAPI {
  static final _apiService = ApiService.instance;

  // Lấy danh sách quiz topics từ backend
  static Future<List<QuizTopic>> getTopics() async {
    try {
      final response = await _apiService.get('/quiz');

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> quizzes = data['data'];
          return quizzes.map((json) => QuizTopic.fromMap(json)).toList();
        }
      }

      // Fallback to mock data if API fails
      print('Failed to fetch quizzes from API, using mock data');
      return _getMockTopics();
    } catch (e) {
      print('Error fetching quiz topics: $e');
      return _getMockTopics();
    }
  }

  // Lấy danh sách câu hỏi cho một topic từ backend
  static Future<List<QuizQuestion>> getQuestions(int topicId) async {
    try {
      final response = await _apiService.get('/quiz/$topicId');

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        if (data['success'] == true && data['data'] != null) {
          final quiz = data['data'];
          if (quiz['questions'] != null) {
            List<dynamic> questions = quiz['questions'];
            return questions.map((json) => QuizQuestion.fromMap(json)).toList();
          }
        }
      }

      // Fallback to mock data if API fails
      print('Failed to fetch questions from API, using mock data');
      return _getMockQuestions(topicId);
    } catch (e) {
      print('Error fetching quiz questions: $e');
      return _getMockQuestions(topicId);
    }
  }

  // Submit kết quả quiz
  static Future<Map<String, dynamic>> submitQuizResult({
    required int quizId,
    required List<int> answers,
    required int timeSpent,
  }) async {
    try {
      final response = await _apiService.post('/quiz/$quizId/submit', {
        'answers': answers,
        'timeSpent': timeSpent,
      });

      if (response.statusCode == 200 && response.body != null) {
        return response.body;
      }

      return {'success': false, 'message': 'Failed to submit quiz'};
    } catch (e) {
      print('Error submitting quiz result: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Mock data cho quiz topics (fallback)
  static List<QuizTopic> _getMockTopics() {
    return [
      QuizTopic(
        id: 1,
        name: 'Basic Vocabulary',
        description: 'Test your knowledge of common English words',
        difficulty: 'Beginner',
        questionCount: 10,
        estimatedTime: const Duration(minutes: 5),
        tags: ['Vocabulary', '📚'],
      ),
      QuizTopic(
        id: 2,
        name: 'Grammar Basics',
        description: 'Practice essential grammar rules',
        difficulty: 'Beginner',
        questionCount: 15,
        estimatedTime: const Duration(minutes: 8),
        tags: ['Grammar', '✏️'],
      ),
      QuizTopic(
        id: 3,
        name: 'Business English',
        description: 'Professional vocabulary and phrases',
        difficulty: 'Intermediate',
        questionCount: 20,
        estimatedTime: const Duration(minutes: 10),
        tags: ['Vocabulary', '💼'],
      ),
      QuizTopic(
        id: 4,
        name: 'Idioms & Phrases',
        description: 'Common English idioms and expressions',
        difficulty: 'Advanced',
        questionCount: 12,
        estimatedTime: const Duration(minutes: 7),
        tags: ['Vocabulary', '💬'],
      ),
      QuizTopic(
        id: 5,
        name: 'Tenses Quiz',
        description: 'Master English verb tenses',
        difficulty: 'Intermediate',
        questionCount: 18,
        estimatedTime: const Duration(minutes: 9),
        tags: ['Grammar', '⏰'],
      ),
    ];
  }

  // Mock data cho quiz questions (fallback)
  static List<QuizQuestion> _getMockQuestions(int topicId) {
    final Map<int, List<QuizQuestion>> mockQuestions = {
      1: [
        QuizQuestion(
          id: 1,
          question: 'What does "abundant" mean?',
          options: ['Scarce', 'Plentiful', 'Empty', 'Small'],
          correctAnswerIndex: 1,
          explanation:
              'Abundant means existing in large quantities; plentiful.',
          difficulty: 'Beginner',
        ),
        QuizQuestion(
          id: 2,
          question: 'Choose the synonym of "happy"?',
          options: ['Sad', 'Joyful', 'Angry', 'Tired'],
          correctAnswerIndex: 1,
          explanation:
              'Joyful is a synonym of happy, both mean feeling pleasure.',
          difficulty: 'Beginner',
        ),
        QuizQuestion(
          id: 3,
          question: 'What is the opposite of "difficult"?',
          options: ['Hard', 'Easy', 'Complex', 'Tough'],
          correctAnswerIndex: 1,
          explanation: 'Easy is the opposite of difficult.',
          difficulty: 'Beginner',
        ),
      ],
      2: [
        QuizQuestion(
          id: 11,
          question: 'Choose the correct form: She ___ to school yesterday.',
          options: ['go', 'went', 'goes', 'going'],
          correctAnswerIndex: 1,
          explanation:
              'Use "went" (past simple) for completed actions in the past.',
          difficulty: 'Beginner',
        ),
        QuizQuestion(
          id: 12,
          question: 'Which is correct: "He ___ a book now"?',
          options: ['read', 'reads', 'is reading', 'has read'],
          correctAnswerIndex: 2,
          explanation:
              'Use "is reading" (present continuous) for actions happening now.',
          difficulty: 'Beginner',
        ),
      ],
    };

    return mockQuestions[topicId] ?? [];
  }
}
