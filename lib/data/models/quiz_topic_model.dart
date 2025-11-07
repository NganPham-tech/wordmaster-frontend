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
    return QuizTopic(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      questionCount: map['question_count'] ?? 0,
      estimatedTime: Duration(minutes: map['estimated_time'] ?? 10),
      tags: map['tags'] != null
          ? List<String>.from(map['tags'] is String
              ? (map['tags'] as String).split(',')
              : map['tags'])
          : [],
    );
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
  final String explanation;
  final String difficulty;
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
    this.points = 10,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    List<String> options = [];
    if (map['options'] != null) {
      if (map['options'] is String) {
        options = (map['options'] as String).split('|');
      } else if (map['options'] is List) {
        options = List<String>.from(map['options']);
      }
    }

    return QuizQuestion(
      id: map['id'] ?? 0,
      question: map['question'] ?? '',
      options: options,
      correctAnswerIndex: map['correct_answer_index'] ?? 0,
      explanation: map['explanation'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      points: map['points'] ?? 10,
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
