import 'package:flutter/material.dart';

class AudioWave extends StatelessWidget {
  const AudioWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: WaveformPainter(),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    const waveCount = 20;
    final waveWidth = size.width / waveCount;
    final centerY = size.height / 2;

    for (var i = 0; i < waveCount; i++) {
      final x = i * waveWidth;
      final height = (i % 3 + 1) * 8.0; // Varying heights for wave effect
      
      final rect = Rect.fromLTWH(
        x + 2, // spacing
        centerY - height / 2,
        waveWidth - 4, // width with spacing
        height,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}