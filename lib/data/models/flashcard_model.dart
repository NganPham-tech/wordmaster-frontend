import 'package:json_annotation/json_annotation.dart';

part 'flashcard_model.g.dart';

@JsonSerializable()
class Flashcard {
  final int id;
  final int deckId;
  final int userId;
  final String question;
  final String answer;
  final String? example;
  final String? audioPath;
  final String? imagePath;
  final String difficulty;
  final String? wordType;
  final String? phonetic;
  final DateTime? nextReviewDate;
  final bool isReported;
  final String? reportReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.userId,
    required this.question,
    required this.answer,
    this.example,
    this.audioPath,
    this.imagePath,
    required this.difficulty,
    this.wordType,
    this.phonetic,
    this.nextReviewDate,
    required this.isReported,
    this.reportReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) => _$FlashcardFromJson(json);
  Map<String, dynamic> toJson() => _$FlashcardToJson(this);
}