import 'package:json_annotation/json_annotation.dart';

part 'deck_model.g.dart';

@JsonSerializable()
class Deck {
  final int id;
  final int userId;
  final int? categoryId;
  final String name;
  final String? description;
  final String? thumbnail;
  final bool isPublic;
  final bool isDefault;
  final int viewCount;
  final double rating;
  final int totalCards;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final Category? category;
  final User? user;

  Deck({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.name,
    this.description,
    this.thumbnail,
    required this.isPublic,
    required this.isDefault,
    required this.viewCount,
    required this.rating,
    required this.totalCards,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.user,
  });

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);
  Map<String, dynamic> toJson() => _$DeckToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String contentType;
  final String? description;
  final String colorCode;
  final String? icon;

  Category({
    required this.id,
    required this.name,
    required this.contentType,
    this.description,
    required this.colorCode,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}