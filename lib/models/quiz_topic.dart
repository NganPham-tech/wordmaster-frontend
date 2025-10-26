class QuizTopic {
  final int id;
  final String name;
  final String description;
  final String imagePath;
  final int questionCount;
  final String difficulty;
  final List<String> tags;
  final Duration estimatedTime;

  QuizTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.questionCount,
    required this.difficulty,
    required this.tags,
    required this.estimatedTime,
  });

  factory QuizTopic.fromMap(Map<String, dynamic> map) {
    return QuizTopic(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      questionCount: map['questionCount'] ?? 0,
      difficulty: map['difficulty'] ?? 'Easy',
      tags: List<String>.from(map['tags'] ?? []),
      estimatedTime: Duration(minutes: map['estimatedTimeMinutes'] ?? 10),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'questionCount': questionCount,
      'difficulty': difficulty,
      'tags': tags,
      'estimatedTimeMinutes': estimatedTime.inMinutes,
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

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? 0,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'difficulty': difficulty,
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
      topicId: map['topicId'] ?? 0,
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      wrongAnswers: map['wrongAnswers'] ?? 0,
      timeTaken: Duration(seconds: map['timeTakenSeconds'] ?? 0),
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] ?? 0),
      percentage: map['percentage']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'timeTakenSeconds': timeTaken.inSeconds,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'percentage': percentage,
    };
  }
}
