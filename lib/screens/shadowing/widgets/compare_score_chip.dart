import 'package:flutter/material.dart';

class CompareScoreChip extends StatelessWidget {
  final double score;

  const CompareScoreChip({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);
    final icon = _getScoreIcon(score);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 85) return Icons.thumb_up;
    if (score >= 70) return Icons.thumbs_up_down;
    return Icons.thumb_down;
  }
}