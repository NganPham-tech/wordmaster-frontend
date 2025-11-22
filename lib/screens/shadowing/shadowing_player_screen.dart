import 'package:flutter/material.dart';
import '/data/models/shadowing_model.dart';
import 'widgets/segment_tile.dart';
import 'widgets/record_button.dart';
import 'widgets/audio_wave.dart';
import 'shadowing_result_screen.dart';
//D:\DemoDACN\wordmaster_dacn\lib\screens\shadowing\shadowing_player_screen.dart
class ShadowingPlayerScreen extends StatefulWidget {
  final ShadowingContent content;

  const ShadowingPlayerScreen({super.key, required this.content});

  @override
  State<ShadowingPlayerScreen> createState() => _ShadowingPlayerScreenState();
}

class _ShadowingPlayerScreenState extends State<ShadowingPlayerScreen> {
  final List<Segment> _segments = [];
  int _currentSegmentIndex = 0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  RecordState _recordState = RecordState.idle;
  Segment? _currentRecordingSegment;
  // String? _currentRecordingPath; // Removed unused field
  final Map<String, SegmentResult> _segmentResults = {};

  @override
  void initState() {
    super.initState();
    _segments.addAll(widget.content.segments);
  }

  void _playSegment(Segment segment) {
    setState(() {
      _currentSegmentIndex = segment.index;
    });
    // TODO: Implement audio playback for segment
    _playAudioSegment(segment);
  }

  void _playAudioSegment(Segment segment) {
    // TODO: Implement audio playback
    print('Playing segment ${segment.index}: ${segment.text}');
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: Implement play/pause logic
  }

  void _startRecording(Segment segment) {
    setState(() {
      _recordState = RecordState.recording;
      _currentRecordingSegment = segment;
    });
    // TODO: Start audio recording
  }

  void _stopRecording() {
    setState(() {
      _recordState = RecordState.recorded;
    });
    // TODO: Stop audio recording and save file
  }

  void _submitRecording() {
    setState(() {
      _recordState = RecordState.processing;
    });
    
    // TODO: Submit recording for analysis
    Future.delayed(const Duration(seconds: 2), () {
      // Mock result
      final result = SegmentResult(
        segmentId: _currentRecordingSegment!.id,
        accuracyScore: 85.0,
        pronunciationScore: 78.0,
        fluencyScore: 82.0,
        overallScore: 82.0,
        recognizedText: _currentRecordingSegment!.text,
        feedback: 'Good pronunciation! Focus on vowel sounds in "practice".',
        pronunciationHints: [
          PronunciationHint(
            word: 'practice',
            expectedPronunciation: '/ˈpræk.tɪs/',
            userPronunciation: '/ˈpræk.təs/',
            suggestion: 'Focus on the "ɪ" sound in the second syllable',
          ),
        ],
      );
      
      setState(() {
        _recordState = RecordState.idle;
        _segmentResults[_currentRecordingSegment!.id] = result;
        _currentRecordingSegment = null;
      });
    });
  }

  void _retryRecording() {
    setState(() {
      _recordState = RecordState.idle;
      _currentRecordingSegment = null;
    });
  }

  int get _practicedSegmentsCount {
    return _segmentResults.length;
  }

  double get _averageScore {
    if (_segmentResults.isEmpty) return 0.0;
    final total = _segmentResults.values
        .map((result) => result.overallScore)
        .reduce((a, b) => a + b);
    return total / _segmentResults.length;
  }

  void _endSession() {
    final result = ShadowingResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user_1', // TODO: Get from auth
      contentId: widget.content.id,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      completedAt: DateTime.now(),
      totalSegments: _segments.length,
      practicedSegments: _practicedSegmentsCount,
      averageScore: _averageScore,
      totalTimeSpent: 600, // 10 minutes
      segmentResults: _segmentResults.values.toList(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ShadowingResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show practice history
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInstructions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card
          _buildHeaderCard(),
          
          // Player controls
          _buildPlayerControls(),
          
          // Segments list
          Expanded(
            child: _buildSegmentsList(),
          ),
          
          // Recording area or session summary
          if (_recordState != RecordState.idle) _buildRecordingArea(),
          
          // Session footer
          _buildSessionFooter(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.2),
                  image: widget.content.thumbnail != null
                      ? DecorationImage(
                          image: NetworkImage(widget.content.thumbnail!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.content.thumbnail == null
                    ? const Icon(Icons.audiotrack, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.content.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _togglePlayPause,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                label: const Text('Play Full'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // Scroll to segments
                },
                icon: const Icon(Icons.list),
                label: const Text('Practice Segments'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Main play button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, size: 28),
                onPressed: () {
                  // TODO: Rewind 10 seconds
                },
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10, size: 28),
                onPressed: () {
                  // TODO: Forward 10 seconds
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Speed and loop controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed selector
              Row(
                children: [
                  const Icon(Icons.speed, size: 20, color: Colors.grey),
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
                      setState(() {
                        _playbackSpeed = value!;
                      });
                      // TODO: Update playback speed
                    },
                  ),
                ],
              ),
              
              // Loop toggle
              Row(
                children: [
                  const Icon(Icons.loop, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isLooping,
                    onChanged: (value) {
                      setState(() {
                        _isLooping = value;
                      });
                      // TODO: Toggle segment looping
                    },
                    activeColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            children: [
              Slider(
                value: 0.3, // TODO: Connect to actual progress
                onChanged: (value) {
                  // TODO: Implement seeking
                },
                activeColor: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1:30', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('5:00', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          
          // Waveform (optional)
          const SizedBox(height: 8),
          const AudioWave(),
        ],
      ),
    );
  }

  Widget _buildSegmentsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Practice Segments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _segments.length,
              itemBuilder: (context, index) {
                final segment = _segments[index];
                final result = _segmentResults[segment.id];
                
                return SegmentTile(
                  segment: segment,
                  isCurrent: _currentSegmentIndex == index,
                  result: result,
                  onPlaySegment: () => _playSegment(segment),
                  onRecord: () => _startRecording(segment),
                  onViewResult: result != null ? () {
                    _showSegmentResult(segment, result);
                  } : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recording Segment ${_currentRecordingSegment!.index + 1}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_recordState == RecordState.recording) ...[
            const Text(
              'Recording...',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RecordButton(
              state: _recordState,
              onStartRecording: _stopRecording, // Actually stops when pressed again
              onStopRecording: _stopRecording,
            ),
          ] else if (_recordState == RecordState.recorded) ...[
            const Text('Recording complete!'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _submitRecording,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit for Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _retryRecording,
                  icon: const Icon(Icons.replay),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ] else if (_recordState == RecordState.processing) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Analyzing your recording...'),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Segments practiced: $_practicedSegmentsCount/${_segments.length}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Avg score: ${_averageScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getScoreColor(_averageScore),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _endSession,
                  child: const Text('End Session'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save session progress
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: const Text('Save Progress'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shadowing Instructions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Listen to the segment carefully'),
            Text('2. Record yourself repeating the segment'),
            Text('3. Get instant feedback on your pronunciation'),
            Text('4. Practice difficult segments multiple times'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSegmentResult(Segment segment, SegmentResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Segment ${segment.index + 1} Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Score: ${result.overallScore.toStringAsFixed(1)}%'),
            Text('Accuracy: ${result.accuracyScore.toStringAsFixed(1)}%'),
            Text('Pronunciation: ${result.pronunciationScore.toStringAsFixed(1)}%'),
            Text('Fluency: ${result.fluencyScore.toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            const Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(result.feedback),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startRecording(segment);
            },
            child: const Text('Practice Again'),
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
}