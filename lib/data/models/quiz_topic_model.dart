import 'package:flutter/material.dart';

class QuizTopic {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final int questionCount;
  final Duration estimatedTime;
  final List<String> tags;

  QuizTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.questionCount,
    required this.estimatedTime,
    required this.tags,
  });

  factory QuizTopic.fromMap(Map<String, dynamic> map) {
    // Backend trả về: title, description, quizType, timeLimit, questions
    int questionCount = 0;
    if (map['questions'] != null) {
      if (map['questions'] is List) {
        questionCount = (map['questions'] as List).length;
      } else if (map['_count'] != null && map['_count']['questions'] != null) {
        questionCount = map['_count']['questions'];
      }
    }

    // Lấy timeLimit từ backend (đơn vị: phút)
    int timeInMinutes = map['timeLimit'] ?? map['estimated_time'] ?? 10;

    return QuizTopic(
      id: map['id'] ?? 0,
      name: map['title'] ?? map['name'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['quizType'] ?? map['difficulty'] ?? 'Medium',
      questionCount: questionCount,
      estimatedTime: Duration(minutes: timeInMinutes),
      tags: _parseTags(map),
    );
  }

  static List<String> _parseTags(Map<String, dynamic> map) {
    if (map['tags'] != null) {
      if (map['tags'] is String) {
        return (map['tags'] as String).split(',');
      } else if (map['tags'] is List) {
        return List<String>.from(map['tags']);
      }
    }

    // Tạo tags từ các trường khác
    List<String> tags = [];
    if (map['category'] != null && map['category']['name'] != null) {
      tags.add(map['category']['name']);
    }
    if (map['quizType'] != null) {
      tags.add(map['quizType']); // Chỉ add tên type, không add emoji
    }
    return tags;
  }

  static Widget getIconWidget(String type, {double size = 24.0, Color? color}) {
    color = color ?? Colors.blue;
    
    switch (type.toLowerCase()) {
      case 'vocabulary':
        return _VocabularyIcon(size: size, color: color);
      case 'grammar':
        return _GrammarIcon(size: size, color: color);
      case 'listening':
        return _ListeningIcon(size: size, color: color);
      case 'reading':
        return _ReadingIcon(size: size, color: color);
      default:
        return _DefaultQuizIcon(size: size, color: color);
    }
  }



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'question_count': questionCount,
      'estimated_time': estimatedTime.inMinutes,
      'tags': tags.join(','),
    };
  }
}

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String correctAnswer; // Thêm field này cho FillInBlank
  final String questionType; // Thêm field này
  final String explanation;
  final String difficulty;
  final int points;
  final bool useTts; // Thêm field cho TTS
  final String audioText; // Thêm field cho text TTS đọc

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.correctAnswer = '',
    this.questionType = 'MultipleChoice',
    required this.explanation,
    required this.difficulty,
    this.points = 10,
    this.useTts = false,
    this.audioText = '',
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    List<String> options = [];

    // Parse options từ backend
    if (map['options'] != null) {
      // Nếu backend trả về array of objects: [{id, optionText, isCorrect}]
      if (map['options'] is List) {
        final optionsList = map['options'] as List;
        if (optionsList.isNotEmpty && optionsList.first is Map) {
          options = optionsList
              .map((opt) => (opt['optionText'] ?? opt['text'] ?? '').toString())
              .toList();
        } else {
          options = List<String>.from(optionsList);
        }
      } else if (map['options'] is String) {
        options = (map['options'] as String).split('|');
      }
    }

    // Tìm correct answer index từ options array
    int correctIndex = 0;
    String correctAnswer = map['correctAnswer'] ?? '';

    if (map['correctAnswerIndex'] != null) {
      correctIndex = map['correctAnswerIndex'];
    } else if (map['correct_answer_index'] != null) {
      correctIndex = map['correct_answer_index'];
    } else if (map['options'] is List) {
      // Tìm trong options array
      final optionsList = map['options'] as List;
      for (int i = 0; i < optionsList.length; i++) {
        if (optionsList[i] is Map && optionsList[i]['isCorrect'] == true) {
          correctIndex = i;
          break;
        }
      }
    }

    return QuizQuestion(
      id: map['id'] ?? 0,
      question: map['questionText'] ?? map['question'] ?? '',
      options: options,
      correctAnswerIndex: correctIndex,
      correctAnswer: correctAnswer,
      questionType: map['questionType'] ?? 'MultipleChoice',
      explanation: map['explanation'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      points: map['points'] ?? 10,
      useTts: map['useTts'] ?? false,
      audioText: map['audioText'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options.join('|'),
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'difficulty': difficulty,
      'points': points,
    };
  }
}

class QuizResult {
  final int topicId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final Duration timeTaken;
  final DateTime completedAt;
  final double percentage;

  QuizResult({
    required this.topicId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeTaken,
    required this.completedAt,
    required this.percentage,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      topicId: map['topic_id'] ?? 0,
      score: map['score'] ?? 0,
      totalQuestions: map['total_questions'] ?? 0,
      correctAnswers: map['correct_answers'] ?? 0,
      wrongAnswers: map['wrong_answers'] ?? 0,
      timeTaken: Duration(seconds: map['time_taken'] ?? 0),
      completedAt: DateTime.parse(
        map['completed_at'] ?? DateTime.now().toIso8601String(),
      ),
      percentage: map['percentage'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topic_id': topicId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'time_taken': timeTaken.inSeconds,
      'completed_at': completedAt.toIso8601String(),
      'percentage': percentage,
    };
  }
}

// Custom Icon Widgets
class _VocabularyIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const _VocabularyIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.6,
            height: size * 0.8,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            top: size * 0.15,
            child: Container(
              width: size * 0.4,
              height: 2,
              color: color,
            ),
          ),
          Positioned(
            top: size * 0.35,
            child: Container(
              width: size * 0.4,
              height: 2,
              color: color,
            ),
          ),
          Positioned(
            top: size * 0.55,
            child: Container(
              width: size * 0.4,
              height: 2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrammarIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const _GrammarIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pencil body
          Container(
            width: size * 0.15,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size * 0.075),
            ),
          ),
          // Pencil tip
          Positioned(
            bottom: size * 0.1,
            child: Container(
              width: 0,
              height: 0,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.transparent,
                    width: size * 0.075,
                  ),
                  right: BorderSide(
                    color: Colors.transparent,
                    width: size * 0.075,
                  ),
                  bottom: BorderSide(
                    color: color,
                    width: size * 0.15,
                  ),
                ),
              ),
            ),
          ),
          // Eraser
          Positioned(
            top: size * 0.1,
            child: Container(
              width: size * 0.2,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(size * 0.075),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeningIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const _ListeningIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Headphone arc
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(size * 0.4),
            ),
          ),
          // Left ear piece
          Positioned(
            left: size * 0.05,
            child: Container(
              width: size * 0.15,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size * 0.075),
              ),
            ),
          ),
          // Right ear piece
          Positioned(
            right: size * 0.05,
            child: Container(
              width: size * 0.15,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size * 0.075),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const _ReadingIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Book pages
          Container(
            width: size * 0.7,
            height: size * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: color, width: 2),
            ),
          ),
          // Book spine
          Positioned(
            left: size * 0.15,
            child: Container(
              width: 3,
              height: size * 0.8,
              color: color,
            ),
          ),
          // Text lines
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: size * 0.4, height: 1.5, color: color.withOpacity(0.6)),
              SizedBox(height: size * 0.08),
              Container(width: size * 0.35, height: 1.5, color: color.withOpacity(0.6)),
              SizedBox(height: size * 0.08),
              Container(width: size * 0.4, height: 1.5, color: color.withOpacity(0.6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DefaultQuizIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const _DefaultQuizIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
