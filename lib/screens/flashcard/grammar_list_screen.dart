import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/grammar_deck_controller.dart';
import 'study_grammar_screen.dart';

class GrammarListScreen extends StatelessWidget {
  const GrammarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grammarController = Get.put(GrammarDeckController());
    

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
      body: Obx(() {
        // Loading
        if (grammarController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (grammarController.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  grammarController.error.value,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: grammarController.refresh,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // Filter decks that have grammar cards
        final grammarDecks = grammarController.filteredDecks
            .where((deck) => deck.totalCards > 0)
            .toList();

        if (grammarDecks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có bộ ngữ pháp nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: grammarController.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: grammarDecks.length,
            itemBuilder: (context, index) {
              final deck = grammarDecks[index];
              final color = deck.category?.colorCode != null
                  ? Color(int.parse(
                      deck.category!.colorCode.replaceFirst('#', '0xFF')))
                  : const Color(0xFF10B981);

              return _buildTopicCard(deck, color);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTopicCard(dynamic deck, Color color) {
    // Map emoji based on deck name or use default
    String emoji = '📗';
    if (deck.name.toLowerCase().contains('tense')) emoji = '⏰';
    if (deck.name.toLowerCase().contains('passive')) emoji = '🔄';
    if (deck.name.toLowerCase().contains('report')) emoji = '💬';
    if (deck.name.toLowerCase().contains('conditional')) emoji = '🤔';
    if (deck.name.toLowerCase().contains('modal')) emoji = '🎯';
    if (deck.name.toLowerCase().contains('relative')) emoji = '🔗';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => StudyGrammarScreen(
              topicId: deck.id,
              topicName: deck.name,
            ));
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
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
                    deck.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deck.description ?? 'Bộ ngữ pháp',
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${deck.totalCards} thẻ',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
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
                color: color,
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