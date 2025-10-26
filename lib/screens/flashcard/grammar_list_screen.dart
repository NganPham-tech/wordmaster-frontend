import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'study_grammar_screen.dart';

// Model cho Grammar Topic
class GrammarTopic {
  final String id;
  final String name;
  final String description;
  final int totalCards;
  final String emoji;
  final Color color;

  GrammarTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.totalCards,
    required this.emoji,
    required this.color,
  });
}

class GrammarListScreen extends StatelessWidget {
  const GrammarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu
    final List<GrammarTopic> topics = [
      GrammarTopic(
        id: '1',
        name: 'Tenses (12 thì)',
        description: 'Hiểu cách dùng và cấu trúc của 12 thì trong tiếng Anh',
        totalCards: 12,
        emoji: '⏰',
        color: const Color(0xFF6366F1),
      ),
      GrammarTopic(
        id: '2',
        name: 'Passive Voice',
        description: 'Câu bị động và cách chuyển đổi từ chủ động sang bị động',
        totalCards: 8,
        emoji: '🔄',
        color: const Color(0xFF8B5CF6),
      ),
      GrammarTopic(
        id: '3',
        name: 'Reported Speech',
        description: 'Câu tường thuật và cách chuyển đổi lời nói trực tiếp',
        totalCards: 10,
        emoji: '💬',
        color: const Color(0xFF10B981),
      ),
      GrammarTopic(
        id: '4',
        name: 'Conditional Sentences',
        description: 'Các loại câu điều kiện (If clauses)',
        totalCards: 6,
        emoji: '🤔',
        color: const Color(0xFFF59E0B),
      ),
      GrammarTopic(
        id: '5',
        name: 'Modal Verbs',
        description: 'Động từ khiếm khuyết: can, could, should, must...',
        totalCards: 9,
        emoji: '🎯',
        color: const Color(0xFFEF4444),
      ),
      GrammarTopic(
        id: '6',
        name: 'Relative Clauses',
        description: 'Mệnh đề quan hệ: who, which, that, whose...',
        totalCards: 7,
        emoji: '🔗',
        color: const Color(0xFF06B6D4),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Flashcard Ngữ pháp',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return _buildTopicCard(context, topics[index]);
        },
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, GrammarTopic topic) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyGrammarScreen(
              topicId: topic.id,
              topicName: topic.name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: topic.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  topic.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: topic.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${topic.totalCards} thẻ',
                      style: TextStyle(
                        fontSize: 12,
                        color: topic.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Arrow button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: topic.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}