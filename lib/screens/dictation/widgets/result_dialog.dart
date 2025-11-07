// lib/screens/dictation/widgets/result_dialog.dart
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  Color _getScoreColor(double accuracy) {
    if (accuracy >= 80) return const Color(0xFF10B981);
    if (accuracy >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getGradeEmoji(double accuracy) {
    if (accuracy >= 90) return '🏆';
    if (accuracy >= 80) return '⭐';
    if (accuracy >= 70) return '👍';
    if (accuracy >= 60) return '💪';
    return '📚';
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(accuracy);
    final gradeEmoji = _getGradeEmoji(accuracy);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with emoji
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Score Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    scoreColor.withOpacity(0.2),
                    scoreColor.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: scoreColor,
                  width: 4,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gradeEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${accuracy.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
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
                  _buildStatRow(
                    icon: Icons.check_circle_outline,
                    label: 'Correct Sentences',
                    value: '$correctAnswers/$totalQuestions',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    icon: Icons.timer_outlined,
                    label: 'Time Spent',
                    value: _formatTime(timeSpent),
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    icon: Icons.speed_outlined,
                    label: 'Accuracy Rate',
                    value: '${accuracy.toStringAsFixed(1)}%',
                    color: scoreColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Motivational Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                accuracy >= 80
                    ? 'Excellent work! Your listening skills are improving! 🌟'
                    : accuracy >= 60
                        ? 'Good job! Keep practicing to improve your accuracy! 💪'
                        : 'Nice effort! Practice makes perfect! 📚',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: Color(0xFF6366F1),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
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

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}