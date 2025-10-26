import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../models/quiz_topic.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).startQuiz(widget.topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showQuitDialog(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
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

          if (quizProvider.error != null) {
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
                  Text(quizProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final currentQuestion = quizProvider.currentQuestion;
          if (currentQuestion == null) {
            return const Center(child: Text('No questions available'));
          }

          final progress =
              (quizProvider.currentQuestionIndex + 1) /
              quizProvider.currentQuestions.length;

          return Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.currentQuestions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
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
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Answer options
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
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentQuestion.explanation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[800],
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
                    if (quizProvider.currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showExplanation
                              ? null
                              : () {
                                  quizProvider.previousQuestion();
                                  _resetAnswerState();
                                },
                          child: const Text('Previous'),
                        ),
                      ),
                    if (quizProvider.currentQuestionIndex > 0)
                      const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedAnswer == null ? null : _handleNext,
                        child: Text(_getNextButtonText(quizProvider)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
    });
    Provider.of<QuizProvider>(context, listen: false).answerQuestion(index);
  }

  void _handleNext() {
    if (!_showExplanation) {
      setState(() {
        _showExplanation = true;
      });
    } else {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final hasNext = quizProvider.nextQuestion();

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
    });
  }

  void _finishQuiz() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final result = quizProvider.getQuizResult();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => QuizResultScreen(result: result)),
    );
  }

  String _getNextButtonText(QuizProvider quizProvider) {
    if (!_showExplanation) {
      return 'Submit Answer';
    }

    final isLast =
        quizProvider.currentQuestionIndex ==
        quizProvider.currentQuestions.length - 1;
    return isLast ? 'Finish Quiz' : 'Next Question';
  }

  Color _getDifficultyColor(String difficulty) {
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

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text(
          'Are you sure you want to quit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close quiz
              Provider.of<QuizProvider>(context, listen: false).endQuiz();
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
        backgroundColor = Colors.green[50]!;
        borderColor = Colors.green;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
      } else if (isSelected) {
        backgroundColor = Colors.red[50]!;
        borderColor = Colors.red;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
      } else {
        backgroundColor = Colors.grey[50]!;
        borderColor = Colors.grey[300]!;
        textColor = Colors.grey[600]!;
      }
    } else {
      // Normal state
      if (isSelected) {
        backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
        borderColor = Theme.of(context).primaryColor;
        textColor = Theme.of(context).primaryColor;
      } else {
        backgroundColor = Colors.white;
        borderColor = Colors.grey[300]!;
        textColor = Colors.black87;
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
