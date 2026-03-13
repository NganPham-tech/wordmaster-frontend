// D:\DemoDACN\wordmaster_dacn\lib\screens\dictation\widgets\audio_player_bar.dart
import 'package:flutter/material.dart';

class AudioPlayerBar extends StatelessWidget {
  final bool isPlaying;
  final double currentPosition;
  final double totalDuration;
  final VoidCallback onPlayPause;
  final Function(double) onSeek;
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

  String _formatTime(double seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
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
        
          Slider(
            value: currentPosition.clamp(0, totalDuration),
            min: 0,
            max: totalDuration,
            onChanged: onSeek,
            activeColor: const Color(0xFF6366F1),
            inactiveColor: Colors.grey[300],
          ),
          
          const SizedBox(height: 8),
          
          // Time and Controls
          Row(
            children: [
              Text(
                _formatTime(currentPosition),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              
              const Spacer(),
              
              
              Row(
                children: [
                  if (onPrevious != null)
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: onPrevious,
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
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: onPlayPause,
                    ),
                  ),
                  
                  if (onNext != null)
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: onNext,
                      color: const Color(0xFF6366F1),
                    ),
                ],
              ),
              
              const Spacer(),
              
              Text(
                _formatTime(totalDuration),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}