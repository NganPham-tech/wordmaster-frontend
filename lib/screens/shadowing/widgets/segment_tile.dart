import 'package:flutter/material.dart';
import '/data/models/shadowing_model.dart';
import 'compare_score_chip.dart';

class SegmentTile extends StatelessWidget {
  final ShadowingSegment segment;
  final bool isCurrent;
  final SegmentResult? result;
  final VoidCallback onPlaySegment;
  final VoidCallback onRecord;
  final VoidCallback? onViewResult;

  const SegmentTile({
    super.key,
    required this.segment,
    required this.isCurrent,
    this.result,
    required this.onPlaySegment,
    required this.onRecord,
    this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent ? Colors.blue[50] : Colors.white,
      elevation: isCurrent ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Segment index
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF6366F1)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${segment.orderIndex + 1}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Segment text
                Expanded(
                  child: Text(
                    segment.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: isCurrent ? const Color(0xFF6366F1) : Colors.black,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Score chip if practiced
                if (result != null)
                  CompareScoreChip(score: result!.overallScore),
              ],
            ),

            const SizedBox(height: 8),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow, size: 20),
                  onPressed: onPlaySegment,
                  tooltip: 'Play segment',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.mic, size: 20),
                  onPressed: onRecord,
                  tooltip: 'Record practice',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                    foregroundColor: const Color(0xFF10B981),
                  ),
                ),
                if (onViewResult != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.analytics, size: 20),
                    onPressed: onViewResult,
                    tooltip: 'View results',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
