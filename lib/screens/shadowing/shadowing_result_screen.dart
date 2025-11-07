import 'package:flutter/material.dart';
import '/data/models/shadowing_model.dart';

class ShadowingResultScreen extends StatelessWidget {
  final ShadowingResult result;

  const ShadowingResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall summary
            _buildOverallSummary(),
            const SizedBox(height: 24),
            
            // Score breakdown
            _buildScoreBreakdown(),
            const SizedBox(height: 24),
            
            // Segment results
            _buildSegmentResults(),
            const SizedBox(height: 24),
            
            // Action buttons
            _buildActionButtons(context), // Đã thêm context
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Session Completed! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Segments', '${result.practicedSegments}/${result.totalSegments}'),
                _buildStatItem('Avg Score', '${result.averageScore.toStringAsFixed(1)}%'),
                _buildStatItem('Time', '${result.totalTimeSpent ~/ 60}m'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildScoreBar('Accuracy', _getAverageAccuracy(), Colors.green),
            const SizedBox(height: 12),
            _buildScoreBar('Pronunciation', _getAveragePronunciation(), Colors.blue),
            const SizedBox(height: 12),
            _buildScoreBar('Fluency', _getAverageFluency(), Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${score.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildSegmentResults() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Segment Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...result.segmentResults.asMap().entries.map((entry) {
              final index = entry.key;
              final segmentResult = entry.value;
              return _buildSegmentResultItem(index + 1, segmentResult);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentResultItem(int segmentNumber, SegmentResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$segmentNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: ${result.overallScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(result.overallScore),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.feedback,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Đã thêm tham số BuildContext
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Practice More'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }

  double _getAverageAccuracy() {
    final total = result.segmentResults
        .map((r) => r.accuracyScore)
        .reduce((a, b) => a + b);
    return total / result.segmentResults.length;
  }

  double _getAveragePronunciation() {
    final total = result.segmentResults
        .map((r) => r.pronunciationScore)
        .reduce((a, b) => a + b);
    return total / result.segmentResults.length;
  }

  double _getAverageFluency() {
    final total = result.segmentResults
        .map((r) => r.fluencyScore)
        .reduce((a, b) => a + b);
    return total / result.segmentResults.length;
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}