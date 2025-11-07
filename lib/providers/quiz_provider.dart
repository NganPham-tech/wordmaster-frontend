import 'package:flutter/material.dart';
import '../data/models/quiz_topic_model.dart';
import '../data/quiz_api.dart';

class QuizProvider with ChangeNotifier {
  List<QuizTopic> _topics = [];
  List<QuizQuestion> _currentQuestions = [];
  List<int> _userAnswers = [];
  QuizTopic? _currentTopic;
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  DateTime? _quizStartTime;

  List<QuizTopic> get topics => _topics;
  List<QuizQuestion> get currentQuestions => _currentQuestions;
  List<int> get userAnswers => _userAnswers;
  QuizTopic? get currentTopic => _currentTopic;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isQuizActive =>
      _currentTopic != null && _currentQuestions.isNotEmpty;
  QuizQuestion? get currentQuestion =>
      _currentQuestions.isNotEmpty &&
          _currentQuestionIndex < _currentQuestions.length
      ? _currentQuestions[_currentQuestionIndex]
      : null;

  Future<void> loadQuizTopics() async {
    _setLoading(true);
    try {
      _topics = await QuizAPI.getTopics();
      _clearError();
    } catch (e) {
      _setError('Failed to load quiz topics: 5e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startQuiz(QuizTopic topic) async {
    _setLoading(true);
    try {
      _currentTopic = topic;
      _currentQuestionIndex = 0;
      _userAnswers = [];
      _quizStartTime = DateTime.now();
      _currentQuestions = await QuizAPI.getQuestions(topic.id);
      _clearError();
    } catch (e) {
      _setError('Failed to start quiz: 5e');
    } finally {
      _setLoading(false);
    }
  }

  void answerQuestion(int answerIndex) {
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    } else {
      _userAnswers.add(answerIndex);
    }
    notifyListeners();
  }

  bool nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
      return true;
    }
    return false;
  }

  QuizResult getQuizResult() {
    if (_currentTopic == null || _quizStartTime == null) {
      throw Exception('No active quiz to calculate results');
    }
    int correctAnswers = 0;
    for (int i = 0; i < _currentQuestions.length; i++) {
      if (i < _userAnswers.length &&
          _userAnswers[i] == _currentQuestions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }
    int totalQuestions = _currentQuestions.length;
    int wrongAnswers = totalQuestions - correctAnswers;
    double percentage = (correctAnswers / totalQuestions) * 100;
    int score = (percentage * 10).round();
    return QuizResult(
      topicId: _currentTopic!.id,
      score: score,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      timeTaken: DateTime.now().difference(_quizStartTime!),
      completedAt: DateTime.now(),
      percentage: percentage,
    );
  }

  void endQuiz() {
    _currentTopic = null;
    _currentQuestions = [];
    _userAnswers = [];
    _currentQuestionIndex = 0;
    _quizStartTime = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.star_outline;
      case 'medium':
        return Icons.star_half;
      case 'hard':
        return Icons.star;
      default:
        return Icons.help_outline;
    }
  }
}
