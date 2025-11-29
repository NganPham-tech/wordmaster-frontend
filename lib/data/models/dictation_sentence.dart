class DictationSentence {
  final String text;
  final double startTime;
  final double endTime;
  final int wordCount;
  
  DictationSentence({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.wordCount,
  });
  
  factory DictationSentence.fromSegment(Map<String, dynamic> segment) {
    final text = segment['text'] ?? '';
    return DictationSentence(
      text: text,
      startTime: (segment['startTime'] ?? 0).toDouble(),
      endTime: (segment['endTime'] ?? 0).toDouble(),
      wordCount: text.split(' ').length,
    );
  }
}