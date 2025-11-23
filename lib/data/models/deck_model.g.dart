// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Deck _$DeckFromJson(Map<String, dynamic> json) => Deck(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  categoryId: (json['categoryId'] as num?)?.toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  thumbnail: json['thumbnail'] as String?,
  isPublic: json['isPublic'] as bool,
  isDefault: json['isDefault'] as bool,
  viewCount: (json['viewCount'] as num).toInt(),
  rating: (json['rating'] as num).toDouble(),
  totalCards: (json['totalCards'] as num).toInt(),
  tags: json['tags'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeckToJson(Deck instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
  'name': instance.name,
  'description': instance.description,
  'thumbnail': instance.thumbnail,
  'isPublic': instance.isPublic,
  'isDefault': instance.isDefault,
  'viewCount': instance.viewCount,
  'rating': instance.rating,
  'totalCards': instance.totalCards,
  'tags': instance.tags,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'category': instance.category,
  'user': instance.user,
};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  contentType: json['contentType'] as String,
  description: json['description'] as String?,
  colorCode: json['colorCode'] as String,
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'contentType': instance.contentType,
  'description': instance.description,
  'colorCode': instance.colorCode,
  'icon': instance.icon,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'avatar': instance.avatar,
};
