// D:\DemoDACN\wordmaster_dacn\lib\screens\dictation\widgets\result_dialog.dart
import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final String title;
  final double accuracy;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const ResultDialog({
    super.key,
    required this.title,
    required this.accuracy,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.onRetry,
    required this.onClose,
  });

  String _getFeedback(double accuracy) {
    if (accuracy >= 90) return 'Xuất sắc! Bạn nghe rất tốt! 🌟';
    if (accuracy >= 80) return 'Rất tốt! Tiếp tục phát huy! 👏';
    if (accuracy >= 70) return 'Tốt! Bạn đang tiến bộ! 👍';
    if (accuracy >= 60) return 'Khá! Hãy luyện tập thêm! 💪';
    return 'Cố gắng hơn nữa! Luyện tập làm nên thành công! 📚';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return const Color(0xFF10B981);
    if (accuracy >= 80) return const Color(0xFFF59E0B);
    if (accuracy >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Accuracy Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: accuracy / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getAccuracyColor(accuracy),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${accuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getAccuracyColor(accuracy),
                      ),
                    ),
                    Text(
                      'Độ chính xác',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Từ đúng:', '$correctAnswers/$totalQuestions'),
                  const SizedBox(height: 8),
                  _buildStatRow('Thời gian:', '${timeSpent ~/ 60}:${(timeSpent % 60).toString().padLeft(2, '0')}'),
                  const SizedBox(height: 8),
                  _buildStatRow('Tốc độ:', '${(totalQuestions / timeSpent * 60).toStringAsFixed(1)} từ/phút'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feedback
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getAccuracyColor(accuracy).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: _getAccuracyColor(accuracy),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getFeedback(accuracy),
                      style: TextStyle(
                        color: _getAccuracyColor(accuracy),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Làm Lại',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hoàn Thành',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}