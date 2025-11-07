import 'package:flutter/material.dart';
import '/data/models/shadowing_model.dart';

class RecordButton extends StatefulWidget {
  final RecordState state;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const RecordButton({
    super.key,
    required this.state,
    required this.onStartRecording,
    required this.onStopRecording,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == RecordState.recording) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.value = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: widget.state == RecordState.recording ? Colors.red : Colors.grey[300],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (widget.state == RecordState.recording ? Colors.red : Colors.grey)
                  .withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            widget.state == RecordState.recording ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () {
            if (widget.state == RecordState.recording) {
              widget.onStopRecording();
            } else {
              widget.onStartRecording();
            }
          },
        ),
      ),
    );
  }
}