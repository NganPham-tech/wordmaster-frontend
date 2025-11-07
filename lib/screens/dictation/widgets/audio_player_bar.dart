// lib/screens/dictation/widgets/audio_player_bar.dart
//D:\DemoDACN\wordmaster_dacn\lib\screens\dictation\widgets\audio_player_bar.dart
import 'package:flutter/material.dart';

class AudioPlayerBar extends StatelessWidget {
  final bool isPlaying;
  final double currentPosition;
  final double totalDuration;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const AudioPlayerBar({
    super.key,
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
    required this.onPlayPause,
    required this.onSeek,
    this.onNext,
    this.onPrevious,
  });

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  size: 32,
                  color: onPrevious != null 
                      ? const Color(0xFF6366F1) 
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: onNext,
                icon: Icon(
                  Icons.skip_next_rounded,
                  size: 32,
                  color: onNext != null 
                      ? const Color(0xFF6366F1) 
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Seek Bar
          Row(
            children: [
              Text(
                _formatDuration(currentPosition),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6366F1),
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: const Color(0xFF6366F1),
                    overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: currentPosition.clamp(0, totalDuration),
                    max: totalDuration > 0 ? totalDuration : 1,
                    onChanged: onSeek,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDuration(totalDuration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// lib/screens/dictation/widgets/result_dialog.dart
// ============================================================

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