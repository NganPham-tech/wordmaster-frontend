// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Flashcard _$FlashcardFromJson(Map<String, dynamic> json) => Flashcard(
  id: (json['id'] as num).toInt(),
  deckId: (json['deckId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  question: json['question'] as String,
  answer: json['answer'] as String,
  example: json['example'] as String?,
  audioPath: json['audioPath'] as String?,
  imagePath: json['imagePath'] as String?,
  difficulty: json['difficulty'] as String,
  wordType: json['wordType'] as String?,
  phonetic: json['phonetic'] as String?,
  nextReviewDate: json['nextReviewDate'] == null
      ? null
      : DateTime.parse(json['nextReviewDate'] as String),
  isReported: json['isReported'] as bool,
  reportReason: json['reportReason'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FlashcardToJson(Flashcard instance) => <String, dynamic>{
  'id': instance.id,
  'deckId': instance.deckId,
  'userId': instance.userId,
  'question': instance.question,
  'answer': instance.answer,
  'example': instance.example,
  'audioPath': instance.audioPath,
  'imagePath': instance.imagePath,
  'difficulty': instance.difficulty,
  'wordType': instance.wordType,
  'phonetic': instance.phonetic,
  'nextReviewDate': instance.nextReviewDate?.toIso8601String(),
  'isReported': instance.isReported,
  'reportReason': instance.reportReason,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
