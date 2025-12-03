// lib/screens/flashcard/widgets/feynman_note_display.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/feynman_controller.dart';
import '../../../data/models/feynman_note_model.dart';

class FeynmanNoteDisplay extends StatelessWidget {
  final String cardType;
  final int cardId;
  final Color accentColor;

  const FeynmanNoteDisplay({
    Key? key,
    required this.cardType,
    required this.cardId,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final feynmanController = Get.put(FeynmanController());
    
    // Load note khi widget được tạo
    feynmanController.loadNote(cardType: cardType, cardId: cardId);

    return Obx(() {
      if (feynmanController.isLoading.value) {
        return const SizedBox.shrink();
      }

      final note = feynmanController.currentNote.value;
      
      if (note == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.1),
              accentColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: accentColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Giải thích của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.textNote,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}