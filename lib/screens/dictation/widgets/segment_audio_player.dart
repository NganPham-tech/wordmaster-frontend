import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../data/models/dictation_model.dart';

class SegmentAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final DictationSegment segment;
  final VoidCallback? onSegmentComplete;

  const SegmentAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.segment,
    this.onSegmentComplete,
  });

  @override
  State<SegmentAudioPlayer> createState() => _SegmentAudioPlayerState();
}

class _SegmentAudioPlayerState extends State<SegmentAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isAudioLoaded = false;
  Duration _currentPosition = Duration.zero;
  Duration _segmentDuration = Duration.zero;
  Duration _segmentStart = Duration.zero;
  Duration _segmentEnd = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
    _loadAudio();
  }

  @override
  void didUpdateWidget(SegmentAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if segment changed
    if (oldWidget.segment.id != widget.segment.id) {
      print('Segment changed from ${oldWidget.segment.orderIndex} to ${widget.segment.orderIndex}');
      _updateSegment();
    }
  }

  void _updateSegment() {
    // Stop current playback first
    _audioPlayer.pause();
    
    // Recalculate segment times
    _segmentStart = Duration(milliseconds: (widget.segment.startTime * 1000).toInt());
    _segmentEnd = Duration(milliseconds: (widget.segment.endTime * 1000).toInt());
    _segmentDuration = _segmentEnd - _segmentStart;

    print('Updated to Segment ${widget.segment.orderIndex}: ${_segmentStart.inSeconds}s - ${_segmentEnd.inSeconds}s');

    // Reset state completely
    setState(() {
      _currentPosition = Duration.zero;
      _isPlaying = false;
    });
  }

  void _initPlayer() {
    // Calculate segment times
    _segmentStart = Duration(milliseconds: (widget.segment.startTime * 1000).toInt());
    _segmentEnd = Duration(milliseconds: (widget.segment.endTime * 1000).toInt());
    _segmentDuration = _segmentEnd - _segmentStart;

    print('Segment ${widget.segment.orderIndex}: ${_segmentStart.inSeconds}s - ${_segmentEnd.inSeconds}s');

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      // Only process if we're currently playing
      if (!_isPlaying) return;
      
      // Check if we're within segment bounds
      if (position >= _segmentStart && position <= _segmentEnd) {
        setState(() {
          _currentPosition = position - _segmentStart;
        });
      }

      // Auto-stop when reaching segment end (with small buffer for precision)
      if (position >= _segmentEnd - const Duration(milliseconds: 100) && _isPlaying) {
        print('Segment completed at position: ${position.inSeconds}s');
        _stopPlayback();
        widget.onSegmentComplete?.call();
      }
    });

    // Listen to player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
      print('Player state: $state');
    });

    // Listen to duration
    _audioPlayer.onDurationChanged.listen((duration) {
      print('Total audio duration: ${duration.inSeconds}s');
    });
  }

  Future<void> _loadAudio() async {
    if (_isAudioLoaded) return;
    
    try {
      setState(() => _isLoading = true);
      print('Loading audio: ${widget.audioUrl}');
      
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      _isAudioLoaded = true;
      
      print('Audio loaded successfully');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Audio load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (!_isAudioLoaded) {
          await _loadAudio();
          // Wait a bit for audio to load
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        print('Seeking to: ${_segmentStart.inSeconds}s');
        await _audioPlayer.seek(_segmentStart);
        
        // Use play with UrlSource instead of resume to ensure proper playback
        await _audioPlayer.play(UrlSource(widget.audioUrl));
        await _audioPlayer.seek(_segmentStart); // Seek again after play to ensure correct position
      }
    } catch (e) {
      print('Playback error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi phát audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
      _currentPosition = Duration.zero;
    });
  }

  Future<void> _replaySegment() async {
    await _stopPlayback();
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Ensure we start from segment beginning
    setState(() {
      _currentPosition = Duration.zero;
    });
    
    await _togglePlayPause();
  }

  @override
  void dispose() {
    // Stop any ongoing playback and dispose player
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Time Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
              Text(
                _formatDuration(_segmentDuration),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _segmentDuration.inMilliseconds > 0
                  ? _currentPosition.inMilliseconds / _segmentDuration.inMilliseconds
                  : 0.0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Player Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replay Button
              IconButton(
                icon: const Icon(Icons.replay, size: 28),
                color: const Color(0xFF6366F1),
                onPressed: _replaySegment,
                tooltip: 'Nghe lại',
              ),
              
              const SizedBox(width: 20),
              
              // Play/Pause Button
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _togglePlayPause,
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Speed Control (Optional)
              IconButton(
                icon: const Icon(Icons.speed, size: 28),
                color: Colors.grey[400],
                onPressed: () {
                  // TODO: Implement speed control
                },
                tooltip: 'Tốc độ (coming soon)',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Segment Info
          Text(
            'Câu ${widget.segment.orderIndex + 1}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}