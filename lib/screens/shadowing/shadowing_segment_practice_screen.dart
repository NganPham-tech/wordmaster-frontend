import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/data/models/shadowing_model.dart';
import '/controllers/shadowing_controller.dart';
import 'widgets/record_button.dart';
import 'widgets/audio_wave.dart';

class ShadowingSegmentPracticeScreen extends StatefulWidget {
  final ShadowingContentDetail content;

  const ShadowingSegmentPracticeScreen({super.key, required this.content});

  @override
  State<ShadowingSegmentPracticeScreen> createState() =>
      _ShadowingSegmentPracticeScreenState();
}

class _ShadowingSegmentPracticeScreenState
    extends State<ShadowingSegmentPracticeScreen> {
  late final ShadowingController controller;

  @override
  void initState() {
    super.initState();

    try {
      controller = Get.find<ShadowingController>();
    } catch (e) {
      controller = Get.put(ShadowingController(), permanent: true);
    }
    _playCurrentSegment();
  }
  
  int _currentSegmentIndex = 0;
  RecordState _recordState = RecordState.idle;
  String? _recordedAudioPath;
  final Map<int, SegmentResult> _segmentResults = {};
  
  bool _isLooping = false;
  double _playbackSpeed = 1.0;

  // Loading messages
  final List<String> _loadingMessages = [
    "AI đang lắng nghe bạn...",
    "Đang phân tích ngữ điệu...",
    "Đang chấm điểm phát âm...",
    "Đang so sánh với bản gốc...",
    "Đang đánh giá độ chính xác...",
    "Đang xử lý âm thanh...",
    "AI đang suy nghĩ...",
    "Đang kiểm tra từng từ...",
  ];
  String _currentLoadingMessage = "";

  @override
  void dispose() {
    controller.stopAudio();
    super.dispose();
  }

  ShadowingSegment get _currentSegment =>
      widget.content.segments[_currentSegmentIndex];


  bool get _hasResult => _segmentResults.containsKey(_currentSegment.id);
  
  SegmentResult? get _currentResult => _segmentResults[_currentSegment.id];

  void _playCurrentSegment() {
    if (widget.content.audioURL != null) {
      controller.playSegment(_currentSegment, widget.content.audioURL!);
    }
  }

  void _togglePlayPause() {
    controller.togglePlayPause();
  }

  Future<void> _startRecording() async {
    if (mounted) {
      setState(() {
        _recordState = RecordState.recording;
        _recordedAudioPath = null;
      });
    }
    
    await controller.startRecording();
    
    // Check if recording actually started
    if (!controller.isRecording.value) {
      if (mounted) {
        setState(() {
          _recordState = RecordState.idle;
        });
      }
      
     
      if (controller.error.value.isNotEmpty) {
        Get.snackbar(
          'Recording Error',
          controller.error.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    final path = await controller.stopRecording();
    
    if (mounted) {
      setState(() {
        if (path != null) {
          _recordState = RecordState.recorded;
          _recordedAudioPath = path;
        } else {
          _recordState = RecordState.idle;
          _recordedAudioPath = null;
        }
      });
    }
    
    // Show error if stopping failed
    if (path == null && controller.error.value.isNotEmpty) {
      Get.snackbar(
        'Recording Error',
        controller.error.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitRecording() async {
    if (_recordedAudioPath == null) return;

    if (mounted) {
      setState(() {
        _recordState = RecordState.processing;
        // Show random loading message
        _currentLoadingMessage = _loadingMessages[
          DateTime.now().millisecondsSinceEpoch % _loadingMessages.length
        ];
      });
    }

    // Simulate more realistic processing time
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final result = await controller.submitSegmentRecording(
        contentId: widget.content.id,
        segmentId: _currentSegment.id,
        audioPath: _recordedAudioPath!,
      );

      if (result != null) {
        if (mounted) {
          setState(() {
            _segmentResults[_currentSegment.id] = result;
            _recordState = RecordState.idle;
            _recordedAudioPath = null;
            _currentLoadingMessage = "";
          });
        }

        _showResultDialog(result);
      } else {
        if (mounted) {
          setState(() {
            _recordState = RecordState.recorded;
            _currentLoadingMessage = "";
          });
        }
        
        Get.snackbar(
          'Error',
          controller.error.value.isNotEmpty 
              ? controller.error.value 
              : 'Failed to analyze recording',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recordState = RecordState.recorded;
          _currentLoadingMessage = "";
        });
      }
      
      Get.snackbar(
        'Error',
        'Failed to submit recording: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _retryRecording() {
    if (mounted) {
      setState(() {
        _recordState = RecordState.idle;
        _recordedAudioPath = null;
      });
    }
  }

  void _nextSegment() {
    if (_currentSegmentIndex < widget.content.segments.length - 1) {
      if (mounted) {
        setState(() {
          _currentSegmentIndex++;
          _recordState = RecordState.idle;
          _recordedAudioPath = null;
        });
      }
      _playCurrentSegment();
    } else {
      _showCompletionDialog();
    }
  }

  void _previousSegment() {
    if (_currentSegmentIndex > 0) {
      if (mounted) {
        setState(() {
          _currentSegmentIndex--;
          _recordState = RecordState.idle;
          _recordedAudioPath = null;
        });
      }
      _playCurrentSegment();
    }
  }

  void _showResultDialog(SegmentResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getScoreIcon(result.overallScore),
              color: _getScoreColor(result.overallScore),
            ),
            const SizedBox(width: 8),
            const Text('Result'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Score
              Center(
                child: Column(
                  children: [
                    Text(
                      '${result.overallScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(result.overallScore),
                      ),
                    ),
                    Text(
                      _getScoreLabel(result.overallScore),
                      style: TextStyle(
                        fontSize: 16,
                        color: _getScoreColor(result.overallScore),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Score Breakdown
              _buildScoreRow(
                'Accuracy',
                result.accuracyScore,
                Icons.check_circle_outline,
              ),
              const SizedBox(height: 12),
              _buildScoreRow(
                'Pronunciation',
                result.pronunciationScore,
                Icons.record_voice_over,
              ),
              const SizedBox(height: 12),
              _buildScoreRow(
                'Fluency',
                result.fluencyScore,
                Icons.speed,
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Feedback
              const Text(
                'Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.feedback,
                style: const TextStyle(fontSize: 14),
              ),

              // Recognized Text
              if (result.recognizedText.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'What we heard:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.recognizedText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              // Provider info
              if (result.provider != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      result.isMock == true ? Icons.science : Icons.cloud,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.isMock == true ? 'Mock STT' : result.provider!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retryRecording();
            },
            child: const Text('Practice Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _nextSegment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: Text(
              _currentSegmentIndex < widget.content.segments.length - 1
                  ? 'Next Segment'
                  : 'Finish',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[200],
                color: _getScoreColor(score),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${score.toStringAsFixed(0)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getScoreColor(score),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog() {
    final practicedCount = _segmentResults.length;
    final totalSegments = widget.content.segments.length;
    final avgScore = _segmentResults.isEmpty
        ? 0.0
        : _segmentResults.values.map((r) => r.overallScore).reduce((a, b) => a + b) /
            _segmentResults.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You practiced $practicedCount out of $totalSegments segments',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Average Score: ${avgScore.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(avgScore),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Finish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                setState(() {
                  _currentSegmentIndex = 0;
                  _segmentResults.clear();
                  _recordState = RecordState.idle;
                  _recordedAudioPath = null;
                });
                _playCurrentSegment();
              }
            },
            child: const Text('Practice Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segment Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressBar(),

          // Current segment display
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSegmentCard(),
                  const SizedBox(height: 24),
                  _buildPlayerControls(),
                  const SizedBox(height: 24),
                  _buildRecordingSection(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentSegmentIndex + 1) / widget.content.segments.length;
    
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Segment ${_currentSegmentIndex + 1} of ${widget.content.segments.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_segmentResults.length} practiced',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF6366F1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              const Color(0xFF8B5CF6).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Segment text
            Text(
              _currentSegment.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Duration info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_currentSegment.duration.toStringAsFixed(1)}s',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Result badge if exists
            if (_hasResult) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(_currentResult!.overallScore),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Score: ${_currentResult!.overallScore.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Play button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: _playCurrentSegment,
                ),
                const SizedBox(width: 16),
                Obx(() => Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    )),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _playCurrentSegment,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Speed control
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed, size: 20),
                const SizedBox(width: 8),
                DropdownButton<double>(
                  value: _playbackSpeed,
                  items: [0.75, 1.0, 1.25, 1.5].map((speed) {
                    return DropdownMenuItem(
                      value: speed,
                      child: Text('${speed}x'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (mounted) {
                      setState(() => _playbackSpeed = value!);
                    }
                    controller.changeSpeed(value!);
                  },
                ),
                const SizedBox(width: 24),
                const Icon(Icons.loop, size: 20),
                const SizedBox(width: 8),
                Switch(
                  value: _isLooping,
                  onChanged: (value) {
                    if (mounted) {
                      setState(() => _isLooping = value);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
            const AudioWave(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Your Recording',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (_recordState == RecordState.idle) ...[
              ElevatedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.mic),
                label: const Text('Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else if (_recordState == RecordState.recording) ...[
              const Text(
                'Recording...',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              RecordButton(
                state: _recordState,
                onStartRecording: _startRecording,
                onStopRecording: _stopRecording,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _stopRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Stop Recording'),
              ),
            ] else if (_recordState == RecordState.recorded) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 8),
              const Text('Recording complete!'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _retryRecording,
                    icon: const Icon(Icons.replay),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submitRecording,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit for Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ] else if (_recordState == RecordState.processing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _currentLoadingMessage.isNotEmpty 
                    ? _currentLoadingMessage 
                    : 'Đang chấm điểm...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _currentSegmentIndex > 0 ? _previousSegment : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _nextSegment,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                _currentSegmentIndex < widget.content.segments.length - 1
                    ? 'Next'
                    : 'Finish',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Practice'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Listen to the segment'),
            SizedBox(height: 8),
            Text('2. Record yourself repeating it'),
            SizedBox(height: 8),
            Text('3. Get instant feedback'),
            SizedBox(height: 8),
            Text('4. Practice until perfect!'),
            SizedBox(height: 8),
            Text('5. Move to next segment'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
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
    if (score >= 85) return Icons.star;
    if (score >= 70) return Icons.thumb_up;
    return Icons.info;
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Great!';
    if (score >= 70) return 'Good!';
    if (score >= 60) return 'Keep practicing!';
    return 'Try again!';
  }
}