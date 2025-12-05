// File: lib/screens/dictation/dictation_segment_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/data/models/dictation_model.dart';
import '/controllers/session_controller.dart';
import 'widgets/segment_audio_player.dart';

class DictationSegmentScreen extends StatefulWidget {
  final DictationContent content;

  const DictationSegmentScreen({
    super.key,
    required this.content,
  });

  @override
  State<DictationSegmentScreen> createState() => _DictationSegmentScreenState();
}

class _DictationSegmentScreenState extends State<DictationSegmentScreen> 
    with SingleTickerProviderStateMixin {
  int _currentSegmentIndex = 0;
  final List<TextEditingController> _segmentControllers = [];
  final List<bool> _segmentChecked = [];
  final List<String?> _segmentFeedback = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final sessionController = Get.put(SessionController());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Start dictation session
    _startSession();
    
    // Initialize controllers
    if (widget.content.segments != null) {
      for (int i = 0; i < widget.content.segments!.length; i++) {
        _segmentControllers.add(TextEditingController());
        _segmentChecked.add(false);
        _segmentFeedback.add(null);
      }
    }
  }

  void _startSession() {
    sessionController.startSession(
      contentType: 'Dictation',
      contentId: int.parse(widget.content.id),
      contentTitle: widget.content.title,
      mode: 'SegmentPractice',
      totalItems: widget.content.segments?.length ?? 1,
    );
  }

  @override
  void dispose() {
    for (var controller in _segmentControllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  String _getAudioUrl() {
    // Use the fixed audioURL getter that handles duplicate paths correctly
    if (widget.content.audioURL != null) {
      print('Using fixed audioURL: ${widget.content.audioURL}');
      return widget.content.audioURL!;
    }
    
    // Fallback: Sử dụng sourceURL (YouTube)
    print('Debug - audioPath: ${widget.content.audioPath}');
    print('Debug - sourceURL: ${widget.content.sourceURL}');
    print('Debug - using YouTube URL as fallback: ${widget.content.sourceURL}');
    return widget.content.sourceURL;
  }

  void _checkAnswer(int segmentIndex) {
    final controller = _segmentControllers[segmentIndex];
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập câu bạn nghe được'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }
    
    final segment = widget.content.segments![segmentIndex];
    final correct = segment.text.toLowerCase().trim();
    final userInput = controller.text.toLowerCase().trim();
    
    // Calculate accuracy
    final correctWords = correct.split(' ');
    final userWords = userInput.split(' ');
    int matchedWords = 0;
    
    for (int i = 0; i < correctWords.length && i < userWords.length; i++) {
      if (correctWords[i] == userWords[i]) {
        matchedWords++;
      }
    }
    
    final accuracy = (matchedWords / correctWords.length) * 100;
    
    setState(() {
      _segmentChecked[segmentIndex] = true;
      
      if (accuracy >= 80) {
        _segmentFeedback[segmentIndex] = 'Xuất sắc! ${accuracy.toStringAsFixed(0)}% chính xác';
      } else if (accuracy >= 60) {
        _segmentFeedback[segmentIndex] = 'Tốt lắm! ${accuracy.toStringAsFixed(0)}% chính xác';
      } else {
        _segmentFeedback[segmentIndex] = 'Cần luyện tập thêm! ${accuracy.toStringAsFixed(0)}% chính xác';
      }
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  void _nextSegment() {
    if (_currentSegmentIndex < widget.content.segments!.length - 1) {
      setState(() {
        _currentSegmentIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _showCompletionDialog();
    }
  }

  void _previousSegment() {
    if (_currentSegmentIndex > 0) {
      setState(() {
        _currentSegmentIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showCompletionDialog() {
    final completedSegments = _segmentChecked.where((checked) => checked).length;
    final totalSegments = widget.content.segments!.length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn Thành!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn đã hoàn thành $completedSegments/$totalSegments câu.'),
            const SizedBox(height: 16),
            const Text(
              'Rất tốt! Hãy tiếp tục luyện tập để cải thiện kỹ năng nghe.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentSegmentIndex = 0;
              });
            },
            child: const Text('Luyện Lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Hoàn Thành', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _retrySegment(int segmentIndex) {
    setState(() {
      _segmentChecked[segmentIndex] = false;
      _segmentFeedback[segmentIndex] = null;
      _segmentControllers[segmentIndex].clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final segments = widget.content.segments;
    if (segments == null || segments.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Học Từng Câu'),
        ),
        body: const Center(
          child: Text('Nội dung này chưa có phân đoạn'),
        ),
      );
    }

    final currentSegment = segments[_currentSegmentIndex];
    final isChecked = _segmentChecked[_currentSegmentIndex];
    final feedback = _segmentFeedback[_currentSegmentIndex];

    // CHECK AUDIO URL
    if (widget.content.audioURL == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Học Từng Câu'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Không tìm thấy file audio'),
              const SizedBox(height: 8),
              Text('Audio path: ${widget.content.audioPath ?? "null"}'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Câu ${_currentSegmentIndex + 1}/${segments.length}',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentSegmentIndex + 1}/${segments.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🆕 SEGMENT AUDIO PLAYER
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentAudioPlayer(
              audioUrl: _getAudioUrl(),
              segment: currentSegment,
              onSegmentComplete: () {
                print('Segment playback completed');
              },
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Progress Indicator
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (_currentSegmentIndex + 1) / segments.length,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Instruction Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.hearing,
                            size: 48,
                            color: const Color(0xFF6366F1).withOpacity(0.8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nghe câu này và gõ lại chính xác',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bạn có thể nghe lại nhiều lần',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked 
                              ? (feedback?.contains('Xuất sắc') ?? false
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B))
                              : Colors.grey[300]!,
                          width: isChecked ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _segmentControllers[_currentSegmentIndex],
                        minLines: 3,
                        maxLines: 5,
                        enabled: !isChecked,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Gõ câu bạn nghe được...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    
                    // Feedback Section
                    if (isChecked && feedback != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: feedback.contains('Xuất sắc')
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: feedback.contains('Xuất sắc')
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  feedback.contains('Xuất sắc')
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color: feedback.contains('Xuất sắc')
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feedback,
                                    style: TextStyle(
                                      color: feedback.contains('Xuất sắc')
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFF92400E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Câu đúng:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentSegment.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (!isChecked) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _checkAnswer(_currentSegmentIndex),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Kiểm Tra',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _retrySegment(_currentSegmentIndex),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                          Icon(Icons.refresh, color: Color(0xFF6366F1), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Thử Lại',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextSegment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentSegmentIndex < segments.length - 1
                                ? 'Câu Tiếp'
                                : 'Hoàn Thành',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentSegmentIndex < segments.length - 1
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}