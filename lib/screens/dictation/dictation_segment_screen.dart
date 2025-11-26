// D:\DemoDACN\wordmaster_dacn\lib\screens\dictation\dictation_segment_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '/data/models/dictation_model.dart';
import 'widgets/real_audio_player.dart';

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
  bool _isPlaying = false;
  double _currentPosition = 0;
  Timer? _playbackTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    
    // Initialize controllers and state for each segment
    if (widget.content.segments != null) {
      for (int i = 0; i < widget.content.segments!.length; i++) {
        _segmentControllers.add(TextEditingController());
        _segmentChecked.add(false);
        _segmentFeedback.add(null);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _segmentControllers) {
      controller.dispose();
    }
    _playbackTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _startPlayback();
    } else {
      _pausePlayback();
    }
  }

  void _startPlayback() {
    final currentSegment = widget.content.segments![_currentSegmentIndex];
    _currentPosition = currentSegment.startTime.toDouble();
    
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentPosition += 0.1;
        if (_currentPosition >= currentSegment.endTime) {
          _currentPosition = currentSegment.endTime;
          _isPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  void _pausePlayback() {
    _playbackTimer?.cancel();
  }

  void _checkAnswer(int segmentIndex) {
    final controller = _segmentControllers[segmentIndex];
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type what you hear'),
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
        _segmentFeedback[segmentIndex] = 'Great job! ${accuracy.toStringAsFixed(0)}% accurate';
      } else if (accuracy >= 60) {
        _segmentFeedback[segmentIndex] = 'Good try! ${accuracy.toStringAsFixed(0)}% accurate';
      } else {
        _segmentFeedback[segmentIndex] = 'Keep practicing! ${accuracy.toStringAsFixed(0)}% accurate';
      }
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  void _nextSegment() {
    if (_currentSegmentIndex < widget.content.segments!.length - 1) {
      setState(() {
        _currentSegmentIndex++;
        _currentPosition = widget.content.segments![_currentSegmentIndex].startTime.toDouble();
        _isPlaying = false;
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
        _currentPosition = widget.content.segments![_currentSegmentIndex].startTime.toDouble();
        _isPlaying = false;
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
        title: const Text('Segment Practice Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You completed $completedSegments out of $totalSegments segments.'),
            const SizedBox(height: 16),
            const Text(
              'Great job practicing sentence by sentence! This helps build listening accuracy.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset to first segment
              setState(() {
                _currentSegmentIndex = 0;
                _currentPosition = widget.content.segments![0].startTime.toDouble();
                _isPlaying = false;
              });
            },
            child: const Text('Practice Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Finish', style: TextStyle(color: Colors.white)),
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
          title: const Text('Sentence by Sentence'),
        ),
        body: const Center(
          child: Text('No segments available for this content'),
        ),
      );
    }

    final currentSegment = segments[_currentSegmentIndex];
    final isChecked = _segmentChecked[_currentSegmentIndex];
    final feedback = _segmentFeedback[_currentSegmentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Sentence ${_currentSegmentIndex + 1} of ${segments.length}',
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
          // Segment Player Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Time Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currentSegment.startTime.toStringAsFixed(1)}s',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${currentSegment.endTime.toStringAsFixed(1)}s',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (_currentPosition - currentSegment.startTime) / 
                            (currentSegment.endTime - currentSegment.startTime),
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Player Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: _currentSegmentIndex > 0 ? _previousSegment : null,
                      color: const Color(0xFF6366F1),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: _currentSegmentIndex < segments.length - 1 
                          ? _nextSegment 
                          : null,
                      color: const Color(0xFF6366F1),
                    ),
                  ],
                ),
              ],
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
                    const SizedBox(height: 40),
                    
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
                            Icons.format_list_numbered,
                            size: 48,
                            color: const Color(0xFF6366F1).withOpacity(0.8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Listen to this sentence and type what you hear',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Focus on accuracy for each individual sentence',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked 
                              ? (feedback?.contains('Great') ?? false
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
                          hintText: 'Type this sentence...',
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
                          color: feedback.contains('Great')
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: feedback.contains('Great')
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  feedback.contains('Great')
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color: feedback.contains('Great')
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feedback,
                                    style: TextStyle(
                                      color: feedback.contains('Great')
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
                                    'Correct sentence:',
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
                            'Check Answer',
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
                            'Try Again',
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
                                ? 'Next Sentence'
                                : 'Finish',
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