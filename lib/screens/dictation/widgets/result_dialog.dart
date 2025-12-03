// D:\DemoDACN\wordmaster_dacn\lib\screens\dictation\widgets\result_dialog.dart
import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final String title;
  final double accuracy;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent;
  final int? scoreEarned;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const ResultDialog({
    super.key,
    required this.title,
    required this.accuracy,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    this.scoreEarned,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getAccuracyColor(accuracy),
                    _getAccuracyColor(accuracy).withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAccuracyIcon(accuracy),
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 16),
            
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
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: accuracy / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getAccuracyColor(accuracy),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${accuracy.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getAccuracyColor(accuracy),
                        ),
                      ),
                      const Text(
                        'Độ chính xác',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Đúng',
                    value: correctAnswers.toString(),
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.cancel,
                    label: 'Sai',
                    value: (totalQuestions - correctAnswers).toString(),
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    label: 'Thời gian',
                    value: _formatTime(timeSpent),
                    color: const Color(0xFF6366F1),
                  ),
                ),
              
                if (scoreEarned != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.stars,
                      label: 'Điểm',
                      value: '$scoreEarned XP',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Motivational Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAccuracyColor(accuracy).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAccuracyColor(accuracy).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMotivationIcon(accuracy),
                    color: _getAccuracyColor(accuracy),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getMotivationMessage(accuracy),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getAccuracyColor(accuracy),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Thử Lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hoàn Thành',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return const Color(0xFF10B981);
    if (accuracy >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData _getAccuracyIcon(double accuracy) {
    if (accuracy >= 80) return Icons.emoji_events;
    if (accuracy >= 60) return Icons.thumb_up;
    return Icons.trending_up;
  }

  IconData _getMotivationIcon(double accuracy) {
    if (accuracy >= 80) return Icons.stars;
    if (accuracy >= 60) return Icons.thumb_up;
    return Icons.sentiment_satisfied;
  }

  String _getMotivationMessage(double accuracy) {
    if (accuracy >= 80) {
      return 'Xuất sắc! Bạn đã làm rất tốt! 🌟';
    } else if (accuracy >= 60) {
      return 'Tốt lắm! Tiếp tục phát huy nhé! 👍';
    } else {
      return 'Đừng nản chí! Luyện tập thêm sẽ tiến bộ! 💪';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }
}