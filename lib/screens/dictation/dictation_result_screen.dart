// lib/screens/dictation/dictation_result_screen.dart
import 'package:flutter/material.dart';
import '../../models/dictation.dart';
import '../../services/dictation_scoring_service.dart';

class DictationResultScreen extends StatefulWidget {
  final DictationResult result;

  const DictationResultScreen({super.key, required this.result});

  @override
  State<DictationResultScreen> createState() => _DictationResultScreenState();
}

class _DictationResultScreenState extends State<DictationResultScreen> {
  bool _showComparison = true;

  @override
  Widget build(BuildContext context) {
    final isPassed = DictationScoringService.isPassed(widget.result);
    final errors = DictationScoringService.analyzeErrors(widget.result);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kết quả'),
        backgroundColor: const Color(0xFFd63384),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Card
            _buildScoreCard(isPassed),
            const SizedBox(height: 24),

            // Statistics
            _buildStatisticsCard(),
            const SizedBox(height: 24),

            // Error Analysis
            if (!isPassed) _buildErrorAnalysis(errors),
            if (!isPassed) const SizedBox(height: 24),

            // Toggle Comparison
            _buildComparisonToggle(),
            const SizedBox(height: 16),

            // Text Comparison
            if (_showComparison) _buildTextComparison(),
            const SizedBox(height: 24),

            // Actions
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(bool isPassed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPassed
              ? [Colors.green[600]!, Colors.green[800]!]
              : [Colors.orange[600]!, Colors.orange[800]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isPassed ? Icons.check_circle : Icons.info_outline,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            widget.result.grade,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.result.wordAccuracy.toStringAsFixed(1)}% chính xác',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreStat(
                '${widget.result.correctWords}/${widget.result.totalWords}',
                'Từ đúng',
              ),
              _buildScoreStat(
                '${widget.result.timeSpentSeconds}s',
                'Thời gian',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê chi tiết',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Số từ đúng',
              '${widget.result.correctWords}',
              Colors.green,
              Icons.check_circle,
            ),
            _buildStatRow(
              'Số từ sai',
              '${widget.result.totalWords - widget.result.correctWords}',
              Colors.red,
              Icons.cancel,
            ),
            _buildStatRow(
              'Độ chính xác từ',
              '${widget.result.wordAccuracy.toStringAsFixed(1)}%',
              Colors.blue,
              Icons.text_fields,
            ),
            _buildStatRow(
              'Độ chính xác ký tự',
              '${widget.result.charAccuracy.toStringAsFixed(1)}%',
              Colors.purple,
              Icons.format_size,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorAnalysis(Map<String, int> errors) {
    if (errors.values.every((count) => count == 0)) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Phân tích lỗi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (errors['missing_words']! > 0)
              _buildErrorItem('Thiếu từ', errors['missing_words']!, Colors.red),
            if (errors['extra_words']! > 0)
              _buildErrorItem('Thừa từ', errors['extra_words']!, Colors.orange),
            if (errors['wrong_words']! > 0)
              _buildErrorItem('Sai từ', errors['wrong_words']!, Colors.purple),
            if (errors['spelling_errors']! > 0)
              _buildErrorItem(
                'Lỗi chính tả',
                errors['spelling_errors']!,
                Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            '$count lỗi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonToggle() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text(
          'So sánh với đáp án',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Xem chi tiết từng từ đúng/sai',
          style: TextStyle(fontSize: 12),
        ),
        value: _showComparison,
        activeColor: const Color(0xFFd63384),
        onChanged: (value) {
          setState(() {
            _showComparison = value;
          });
        },
      ),
    );
  }

  Widget _buildTextComparison() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'So sánh chi tiết',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Your Answer
            _buildTextSection(
              'Câu trả lời của bạn',
              widget.result.userInput,
              Colors.orange,
            ),

            const SizedBox(height: 16),

            // Correct Answer
            _buildTextSection(
              'Đáp án đúng',
              widget.result.correctText,
              Colors.green,
            ),

            const SizedBox(height: 16),

            // Word by Word Comparison
            const Text(
              'Chi tiết từng từ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWordComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSection(String title, String text, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildWordComparison() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.result.wordComparisons.map((comparison) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: comparison.isCorrect ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: comparison.isCorrect
                  ? Colors.green[300]!
                  : Colors.red[300]!,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!comparison.isCorrect && comparison.userWord.isNotEmpty) ...[
                Text(
                  comparison.userWord,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                comparison.correctWord.isNotEmpty
                    ? comparison.correctWord
                    : '(thiếu)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: comparison.isCorrect
                      ? Colors.green[700]
                      : Colors.red[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.replay),
            label: const Text('Làm lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd63384),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('Về trang chủ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFd63384),
              side: const BorderSide(color: Color(0xFFd63384), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
