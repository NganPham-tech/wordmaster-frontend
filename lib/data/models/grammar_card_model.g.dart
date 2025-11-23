// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrammarCard _$GrammarCardFromJson(Map<String, dynamic> json) => GrammarCard(
  id: (json['id'] as num).toInt(),
  deckId: (json['deckId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  categoryId: (json['categoryId'] as num?)?.toInt(),
  title: json['title'] as String,
  explanation: json['explanation'] as String,
  example: json['example'] as String?,
  structure: json['structure'] as String?,
  usageNote: json['usageNote'] as String?,
  level: json['level'] as String,
  videoURL: json['videoURL'] as String?,
  isPublic: json['isPublic'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GrammarCardToJson(GrammarCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deckId': instance.deckId,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'title': instance.title,
      'explanation': instance.explanation,
      'example': instance.example,
      'structure': instance.structure,
      'usageNote': instance.usageNote,
      'level': instance.level,
      'videoURL': instance.videoURL,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
