import 'package:json_annotation/json_annotation.dart';

part 'grammar_card_model.g.dart';

@JsonSerializable()
class GrammarCard {
  final int id;
  final int deckId;
  final int userId;
  final int? categoryId;
  final String title;
  final String explanation;
  final String? example;
  final String? structure;
  final String? usageNote;
  final String level;
  final String? videoURL;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  GrammarCard({
    required this.id,
    required this.deckId,
    required this.userId,
    this.categoryId,
    required this.title,
    required this.explanation,
    this.example,
    this.structure,
    this.usageNote,
    required this.level,
    this.videoURL,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GrammarCard.fromJson(Map<String, dynamic> json) => _$GrammarCardFromJson(json);
  Map<String, dynamic> toJson() => _$GrammarCardToJson(this);
}