enum QuizType { listening, fillInBlank, multipleChoice, mixed }

class Quiz {
  final int? quizID;
  final int deckID;
  final String title;
  final String? description;
  final QuizType quizType;
  final int duration; // in minutes
  final int passScore; // percentage
  final DateTime createdAt;

  Quiz({
    this.quizID,
    required this.deckID,
    required this.title,
    this.description,
    this.quizType = QuizType.mixed,
    this.duration = 10,
    this.passScore = 70,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'QuizID': quizID,
      'DeckID': deckID,
      'Title': title,
      'Description': description,
      'QuizType': quizType.toString().split('.').last,
      'Duration': duration,
      'PassScore': passScore,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      quizID: map['QuizID'],
      deckID: map['DeckID'],
      title: map['Title'],
      description: map['Description'],
      quizType: QuizType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (map['QuizType']?.toString().toLowerCase() ?? 'mixed'),
        orElse: () => QuizType.mixed,
      ),
      duration: map['Duration'] ?? 10,
      passScore: map['PassScore'] ?? 70,
      createdAt: DateTime.parse(map['CreatedAt']),
    );
  }

  Quiz copyWith({
    int? quizID,
    int? deckID,
    String? title,
    String? description,
    QuizType? quizType,
    int? duration,
    int? passScore,
    DateTime? createdAt,
  }) {
    return Quiz(
      quizID: quizID ?? this.quizID,
      deckID: deckID ?? this.deckID,
      title: title ?? this.title,
      description: description ?? this.description,
      quizType: quizType ?? this.quizType,
      duration: duration ?? this.duration,
      passScore: passScore ?? this.passScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum QuestionType { multipleChoice, fillInBlank, listening }

class QuizQuestion {
  final int? questionID;
  final int quizID;
  final String questionText;
  final String? audioText; // Text to be spoken by TTS
  final QuestionType questionType;
  final String correctAnswer;
  final String? explanation;

  QuizQuestion({
    this.questionID,
    required this.quizID,
    required this.questionText,
    this.audioText,
    required this.questionType,
    required this.correctAnswer,
    this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'QuestionID': questionID,
      'QuizID': quizID,
      'QuestionText': questionText,
      'AudioText': audioText,
      'QuestionType': questionType.toString().split('.').last,
      'CorrectAnswer': correctAnswer,
      'Explanation': explanation,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      questionID: map['QuestionID'],
      quizID: map['QuizID'],
      questionText: map['QuestionText'],
      audioText: map['AudioText'],
      questionType: QuestionType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (map['QuestionType']?.toString().toLowerCase() ?? 'multiplechoice'),
        orElse: () => QuestionType.multipleChoice,
      ),
      correctAnswer: map['CorrectAnswer'],
      explanation: map['Explanation'],
    );
  }
}

class QuizOption {
  final int? optionID;
  final int questionID;
  final String optionText;
  final bool isCorrect;

  QuizOption({
    this.optionID,
    required this.questionID,
    required this.optionText,
    this.isCorrect = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'OptionID': optionID,
      'QuestionID': questionID,
      'OptionText': optionText,
      'IsCorrect': isCorrect,
    };
  }

  factory QuizOption.fromMap(Map<String, dynamic> map) {
    return QuizOption(
      optionID: map['OptionID'],
      questionID: map['QuestionID'],
      optionText: map['OptionText'],
      isCorrect: map['IsCorrect'] == 1 || map['IsCorrect'] == true,
    );
  }
}
