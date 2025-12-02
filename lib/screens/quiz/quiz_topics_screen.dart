import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/quiz_controller.dart';
import '../../data/models/quiz_topic_model.dart';
import 'quiz_screen.dart';

class QuizTopicsScreen extends StatefulWidget {
  const QuizTopicsScreen({super.key});

  @override
  State<QuizTopicsScreen> createState() => _QuizTopicsScreenState();
}

class _QuizTopicsScreenState extends State<QuizTopicsScreen> {
  late final QuizController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(QuizController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadQuizTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Quiz Topics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SafeArea(
        child: Obx(() {
          final ctrl = Get.find<QuizController>();
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.error.value != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ctrl.error.value!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ctrl.loadQuizTopics(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (ctrl.topics.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No quiz topics available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new quizzes!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Choose a topic to start your quiz',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: ctrl.topics.length,
                  itemBuilder: (context, index) {
                    final topic = ctrl.topics[index];
                    return QuizTopicCard(
                      topic: topic,
                      onTap: () => _startQuiz(context, topic),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _startQuiz(BuildContext context, QuizTopic topic) {
    Get.to(() => QuizScreen(topic: topic));
  }
}

class QuizTopicCard extends StatelessWidget {
  final QuizTopic topic;
  final VoidCallback onTap;

  const QuizTopicCard({super.key, required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuizController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          topic.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              ctrl.getDifficultyIcon(topic.difficulty),
                              size: 14,
                              color: ctrl.getDifficultyColor(topic.difficulty),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              topic.difficulty,
                              style: TextStyle(
                                fontSize: 11,
                                color: ctrl.getDifficultyColor(
                                  topic.difficulty,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                topic.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.quiz,
                    label: '${topic.questionCount} Questions',
                    color: const Color(0xFF6366F1),
                  ),
                  _InfoChip(
                    icon: Icons.schedule,
                    label: '${topic.estimatedTime.inMinutes} min',
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
              if (topic.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: topic.tags
                      .take(3) 
                      .map((tag) => _TagChip(tag: tag))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF6366F1),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}