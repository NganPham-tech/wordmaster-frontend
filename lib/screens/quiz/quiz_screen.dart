import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/quiz_controller.dart';
import '../../data/models/quiz_topic_model.dart';
import '../../services/tts_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizTopic topic;

  const QuizScreen({super.key, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedAnswer;
  bool _showExplanation = false;
  final TextEditingController _fillInBlankController = TextEditingController();
  bool _isTtsPlaying = false;

  @override
  void initState() {
    super.initState();
    TtsService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Get.isRegistered<QuizController>()
          ? Get.find<QuizController>()
          : Get.put(QuizController());
      ctrl.startQuiz(widget.topic);
    });
  }

  @override
  void dispose() {
    _fillInBlankController.dispose();
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.topic.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          IconButton(
            onPressed: () => _showQuitDialog(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Obx(() {
        final ctrl = Get.find<QuizController>();
        if (ctrl.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading quiz...'),
              ],
            ),
          );
        }

        if (ctrl.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading quiz',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(ctrl.error.value!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        final currentQuestion = ctrl.currentQuestion;
        if (currentQuestion == null) {
          return const Center(child: Text('No questions available'));
        }

        final progress =
            (ctrl.currentQuestionIndex.value + 1) /
            ctrl.currentQuestions.length;

        return Column(
          children: [
            // Progress bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${ctrl.currentQuestionIndex.value + 1} of ${ctrl.currentQuestions.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 6,
                  ),
                ],
              ),
            ),

            // Question content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(
                                      currentQuestion.difficulty,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentQuestion.difficulty,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentQuestion.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            
                            // TTS Audio Controls
                            if (currentQuestion.useTts) ...[
                              const SizedBox(height: 16),
                              _buildTtsControls(currentQuestion),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Answer options - Kiểm tra questionType
                    if (currentQuestion.questionType == 'FillInBlank')
                      // Fill in the blank input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your answer:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _fillInBlankController,
                              enabled: !_showExplanation,
                              decoration: InputDecoration(
                                hintText: 'Type your answer here...',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAnswer = value.isNotEmpty ? 0 : null;
                                });
                                final ctrl = Get.find<QuizController>();
                                ctrl.answerQuestion(0, textAnswer: value);
                              },
                            ),
                            if (_showExplanation) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _fillInBlankController.text.trim().toLowerCase() ==
                                          currentQuestion.correctAnswer.trim().toLowerCase()
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _fillInBlankController.text.trim().toLowerCase() ==
                                            currentQuestion.correctAnswer.trim().toLowerCase()
                                        ? Colors.green
                                        : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _fillInBlankController.text.trim().toLowerCase() ==
                                              currentQuestion.correctAnswer.trim().toLowerCase()
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: _fillInBlankController.text.trim().toLowerCase() ==
                                              currentQuestion.correctAnswer.trim().toLowerCase()
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _fillInBlankController.text.trim().toLowerCase() ==
                                                currentQuestion.correctAnswer.trim().toLowerCase()
                                            ? 'Correct!'
                                            : 'Correct answer: ${currentQuestion.correctAnswer}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _fillInBlankController.text.trim().toLowerCase() ==
                                                  currentQuestion.correctAnswer.trim().toLowerCase()
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      // Multiple choice options
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentQuestion.options.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedAnswer == index;
                            final isCorrect =
                                index == currentQuestion.correctAnswerIndex;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnswerOption(
                                text: currentQuestion.options[index],
                                isSelected: isSelected,
                                isCorrect: _showExplanation ? isCorrect : null,
                                onTap: _showExplanation
                                    ? null
                                    : () => _selectAnswer(index),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Explanation (if shown)
                    if (_showExplanation) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Explanation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentQuestion.explanation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF475569),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (ctrl.currentQuestionIndex.value > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showExplanation
                            ? null
                            : () {
                                ctrl.previousQuestion();
                                _resetAnswerState();
                              },
                        child: const Text('Previous'),
                      ),
                    ),
                  if (ctrl.currentQuestionIndex.value > 0)
                    const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedAnswer == null ? null : _handleNext,
                      child: Text(_getNextButtonText(ctrl)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
    });
    final ctrl = Get.find<QuizController>();
    ctrl.answerQuestion(index);
  }

  void _handleNext() {
    if (!_showExplanation) {
      setState(() {
        _showExplanation = true;
      });
    } else {
      final ctrl = Get.find<QuizController>();
      final hasNext = ctrl.nextQuestion();

      if (hasNext) {
        _resetAnswerState();
      } else {
        _finishQuiz();
      }
    }
  }

  void _resetAnswerState() {
    setState(() {
      _selectedAnswer = null;
      _showExplanation = false;
      _fillInBlankController.clear();
    });
  }

  void _finishQuiz() {
    final ctrl = Get.find<QuizController>();
    final result = ctrl.getQuizResult();
    Get.off(() => QuizResultScreen(result: result));
  }

  String _getNextButtonText(QuizController quizController) {
    if (!_showExplanation) {
      return 'Submit Answer';
    }

    final isLast =
        quizController.currentQuestionIndex.value ==
        quizController.currentQuestions.length - 1;
    return isLast ? 'Finish Quiz' : 'Next Question';
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Widget _buildTtsControls(QuizQuestion question) {
    final textToSpeak = question.audioText.isNotEmpty 
        ? question.audioText 
        : question.question;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volume_up,
            color: Color(0xFF6366F1),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Listening Question',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          // Play button
          IconButton(
            onPressed: () async {
              setState(() => _isTtsPlaying = true);
              await TtsService.speak(textToSpeak);
              setState(() => _isTtsPlaying = false);
            },
            icon: Icon(
              _isTtsPlaying ? Icons.stop_circle : Icons.play_circle_filled,
              color: const Color(0xFF6366F1),
              size: 32,
            ),
            tooltip: _isTtsPlaying ? 'Stop' : 'Play',
          ),
          // Replay button
          IconButton(
            onPressed: () async {
              await TtsService.stop();
              setState(() => _isTtsPlaying = true);
              await TtsService.speak(textToSpeak);
              setState(() => _isTtsPlaying = false);
            },
            icon: const Icon(
              Icons.replay,
              color: Color(0xFF6366F1),
              size: 28,
            ),
            tooltip: 'Replay',
          ),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text(
          'Are you sure you want to quit? Your progress will be lost.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Close quiz
              final ctrl = Get.find<QuizController>();
              ctrl.endQuiz();
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}

class AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback? onTap;

  const AnswerOption({
    super.key,
    required this.text,
    required this.isSelected,
    this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (isCorrect != null) {
      // Show results
      if (isCorrect!) {
        backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
        icon = Icons.check_circle;
      } else if (isSelected) {
        backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF991B1B);
        icon = Icons.cancel;
      } else {
        backgroundColor = Colors.grey[50]!;
        borderColor = Colors.grey[300]!;
        textColor = Colors.grey[600]!;
      }
    } else {
      // Normal state
      if (isSelected) {
        backgroundColor = const Color(0xFF6366F1).withOpacity(0.1);
        borderColor = const Color(0xFF6366F1);
        textColor = const Color(0xFF6366F1);
      } else {
        backgroundColor = Colors.white;
        borderColor = Colors.grey[300]!;
        textColor = const Color(0xFF1E293B);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: isCorrect! ? Colors.green : Colors.red,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
