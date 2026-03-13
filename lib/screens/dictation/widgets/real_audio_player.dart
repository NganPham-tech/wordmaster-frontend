import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RealAudioPlayer extends StatefulWidget {
  final String? audioUrl;
  final Function(Duration)? onPositionChanged;
  final Function()? onCompleted;

  const RealAudioPlayer({
    super.key,
    required this.audioUrl,
    this.onPositionChanged,
    this.onCompleted,
  });

  @override
  State<RealAudioPlayer> createState() => _RealAudioPlayerState();
}

class _RealAudioPlayerState extends State<RealAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Configure audio player for maximum compatibility
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setVolume(1.0); // Set volume to maximum
    
    // Listen to player state
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
        print('Player state changed: $state');
      }
    });

    // Listen to duration
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
        print('Duration changed: ${_formatDuration(duration)}');
      }
    });

    // Listen to position
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
        widget.onPositionChanged?.call(position);
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        widget.onCompleted?.call();
        print('Audio playback completed');
      }
    });
  }

  Future<void> _loadAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'No audio URL provided';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      print('Loading audio from: ${widget.audioUrl}');
      await _audioPlayer.setSourceUrl(widget.audioUrl!);
      print('Audio loaded successfully');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Audio load error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load audio: $e';
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (!mounted) return;
    
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        
        if (_duration == Duration.zero && !_isLoading) {
          await _loadAudio();
          
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        
        if (_position == Duration.zero || _audioPlayer.state == PlayerState.stopped) {
          await _audioPlayer.play(UrlSource(widget.audioUrl!));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('Play/pause error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Seek error: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadAudio,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
          // Time Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress Bar
          Slider(
            value: _duration.inSeconds > 0
                ? _position.inSeconds.toDouble()
                : 0,
            max: _duration.inSeconds.toDouble(),
            activeColor: const Color(0xFF6366F1),
            inactiveColor: Colors.grey[200],
            onChanged: (value) {
              _seekTo(Duration(seconds: value.toInt()));
            },
          ),
          
          const SizedBox(height: 12),
          
          // Player Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  final newPosition = _position - const Duration(seconds: 10);
                  _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
                },
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final newPosition = _position + const Duration(seconds: 10);
                  _seekTo(newPosition > _duration ? _duration : newPosition);
                },
                color: const Color(0xFF6366F1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
