import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/quiz_topic_model.dart';
import '../data/quiz_api.dart';

class QuizController extends GetxController {
  final RxList<QuizTopic> topics = <QuizTopic>[].obs;
  final RxList<QuizQuestion> currentQuestions = <QuizQuestion>[].obs;
  final RxList<int> userAnswers = <int>[].obs;
  final RxMap<int, String> userTextAnswers =
      <int, String>{}.obs;
  final Rxn<QuizTopic> currentTopic = Rxn<QuizTopic>();
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> error = Rx<String?>(null);

  DateTime? _quizStartTime;

  QuizQuestion? get currentQuestion {
    return currentQuestions.isNotEmpty &&
            currentQuestionIndex.value < currentQuestions.length
        ? currentQuestions[currentQuestionIndex.value]
        : null;
  }

  Future<void> loadQuizTopics() async {
    isLoading.value = true;
    try {
      final fetched = await QuizAPI.getTopics();
      topics.assignAll(fetched);
      error.value = null;
    } catch (e) {
      error.value = 'Failed to load quiz topics';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startQuiz(QuizTopic topic) async {
    isLoading.value = true;
    try {
      currentTopic.value = topic;
      currentQuestionIndex.value = 0;
      userAnswers.clear();
      _quizStartTime = DateTime.now();
      final questions = await QuizAPI.getQuestions(topic.id);
      currentQuestions.assignAll(questions);
      error.value = null;
    } catch (e) {
      error.value = 'Failed to start quiz';
    } finally {
      isLoading.value = false;
    }
  }

  void answerQuestion(int answerIndex, {String? textAnswer}) {
    if (currentQuestionIndex.value < userAnswers.length) {
      userAnswers[currentQuestionIndex.value] = answerIndex;
    } else {
      userAnswers.add(answerIndex);
    }

    if (textAnswer != null) {
      userTextAnswers[currentQuestionIndex.value] = textAnswer;
    }

    userAnswers.refresh();
    userTextAnswers.refresh();
  }

  bool nextQuestion() {
    if (currentQuestionIndex.value < currentQuestions.length - 1) {
      currentQuestionIndex.value++;
      return true;
    }
    return false;
  }

  bool previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      return true;
    }
    return false;
  }

  QuizResult getQuizResult() {
    if (currentTopic.value == null || _quizStartTime == null) {
      throw Exception('No active quiz to calculate results');
    }
    int correctAnswers = 0;
    for (int i = 0; i < currentQuestions.length; i++) {
      final question = currentQuestions[i];

      // Kiểm tra theo loại câu hỏi
      if (question.questionType == 'FillInBlank') {
      
        if (userTextAnswers.containsKey(i)) {
          final userAnswer = userTextAnswers[i]!.trim().toLowerCase();
          final correctAnswer = question.correctAnswer.trim().toLowerCase();
          if (userAnswer == correctAnswer) {
            correctAnswers++;
          }
        }
      } else {
       
        if (i < userAnswers.length &&
            userAnswers[i] == question.correctAnswerIndex) {
          correctAnswers++;
        }
      }
    }
    int totalQuestions = currentQuestions.length;
    int wrongAnswers = totalQuestions - correctAnswers;
    double percentage = (correctAnswers / totalQuestions) * 100;
    int score = (percentage * 10).round();
    return QuizResult(
      topicId: currentTopic.value!.id,
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
    currentTopic.value = null;
    currentQuestions.clear();
    userAnswers.clear();
    userTextAnswers.clear();
    currentQuestionIndex.value = 0;
    _quizStartTime = null;
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
