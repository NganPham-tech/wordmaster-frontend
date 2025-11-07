import '../services/api_service.dart';
import 'models/quiz_topic_model.dart';

class QuizAPI {
  // Mock data cho quiz topics
  static final List<QuizTopic> _mockTopics = [
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

  // Mock data cho quiz questions
  static final Map<int, List<QuizQuestion>> _mockQuestions = {
    1: [
      QuizQuestion(
        id: 1,
        question: 'What does "abundant" mean?',
        options: ['Scarce', 'Plentiful', 'Empty', 'Small'],
        correctAnswerIndex: 1,
        explanation: 'Abundant means existing in large quantities; plentiful.',
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
      QuizQuestion(
        id: 4,
        question: 'What does "benevolent" mean?',
        options: ['Evil', 'Kind', 'Angry', 'Selfish'],
        correctAnswerIndex: 1,
        explanation: 'Benevolent means well-meaning and kindly.',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 5,
        question: 'Choose the correct spelling:',
        options: ['Recieve', 'Receive', 'Receeve', 'Recive'],
        correctAnswerIndex: 1,
        explanation:
            'The correct spelling is "receive" (i before e except after c).',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 6,
        question: 'What does "eloquent" mean?',
        options: ['Silent', 'Fluent in speech', 'Confused', 'Quiet'],
        correctAnswerIndex: 1,
        explanation:
            'Eloquent means fluent or persuasive in speaking or writing.',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 7,
        question: 'Choose the synonym of "ancient"?',
        options: ['Modern', 'Old', 'New', 'Recent'],
        correctAnswerIndex: 1,
        explanation:
            'Old is a synonym of ancient, both mean from a long time ago.',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 8,
        question: 'What is "courage"?',
        options: ['Fear', 'Bravery', 'Weakness', 'Cowardice'],
        correctAnswerIndex: 1,
        explanation: 'Courage means the ability to do something brave.',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 9,
        question: 'What does "diligent" mean?',
        options: ['Lazy', 'Hardworking', 'Careless', 'Slow'],
        correctAnswerIndex: 1,
        explanation: 'Diligent means showing care and effort in work.',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 10,
        question: 'Choose the antonym of "victory"?',
        options: ['Win', 'Success', 'Defeat', 'Triumph'],
        correctAnswerIndex: 2,
        explanation: 'Defeat is the opposite of victory.',
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
      QuizQuestion(
        id: 13,
        question: 'Select the correct article: "___ apple a day"',
        options: ['A', 'An', 'The', 'No article'],
        correctAnswerIndex: 1,
        explanation: 'Use "an" before words starting with vowel sounds.',
        difficulty: 'Beginner',
      ),
    ],
  };

  // Lấy danh sách quiz topics (mock data)
  static Future<List<QuizTopic>> getTopics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTopics;

    // Uncomment below to use real API
    // final response = await ApiService.get('/quiz/topics');
    // if (response['success'] == true) {
    //   List<dynamic> data = response['data'];
    //   return data.map((json) => QuizTopic.fromMap(json)).toList();
    // }
    // return [];
  }

  // Lấy danh sách câu hỏi cho một topic (mock data)
  static Future<List<QuizQuestion>> getQuestions(int topicId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockQuestions[topicId] ?? [];

    // Uncomment below to use real API
    // final response = await ApiService.get('/quiz/questions?topicId=$topicId');
    // if (response['success'] == true) {
    //   List<dynamic> data = response['data'];
    //   return data.map((json) => QuizQuestion.fromMap(json)).toList();
    // }
    // return [];
  }
}
