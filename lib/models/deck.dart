class DeckCategory {
  final int categoryID;
  final String name;
  final String description;
  final String icon;

  DeckCategory({
    required this.categoryID,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class Deck {
  final int? deckID;
  final int userID;
  final int? categoryID;
  final String name;
  final String? description;
  final String? thumbnail;
  final bool isPublic;
  final int viewCount;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI-specific properties
  final int cardCount;
  final int learnedCount;
  final bool isFavorite;
  final bool isUserCreated;
  final String authorName;

  // Getters để tương thích với code hiện tại
  int get id => deckID ?? 0;

  Deck({
    this.deckID,
    required this.userID,
    this.categoryID,
    required this.name,
    this.description,
    this.thumbnail,
    this.isPublic = false,
    this.viewCount = 0,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
    required this.updatedAt,
    this.cardCount = 0,
    this.learnedCount = 0,
    this.isFavorite = false,
    this.isUserCreated = false,
    this.authorName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'DeckID': deckID,
      'UserID': userID,
      'CategoryID': categoryID,
      'Name': name,
      'Description': description,
      'Thumbnail': thumbnail,
      'IsPublic': isPublic,
      'ViewCount': viewCount,
      'Rating': rating,
      'TotalRatings': totalRatings,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
      'CardCount': cardCount,
      'LearnedCount': learnedCount,
      'IsFavorite': isFavorite,
      'IsUserCreated': isUserCreated,
      'AuthorName': authorName,
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      deckID: map['DeckID'],
      userID: map['UserID'],
      categoryID: map['CategoryID'],
      name: map['Name'],
      description: map['Description'],
      thumbnail: map['Thumbnail'],
      isPublic: map['IsPublic'] == 1 || map['IsPublic'] == true,
      viewCount: map['ViewCount'] ?? 0,
      rating: (map['Rating'] ?? 0.0).toDouble(),
      totalRatings: map['TotalRatings'] ?? 0,
      createdAt: DateTime.parse(map['CreatedAt']),
      updatedAt: DateTime.parse(map['UpdatedAt']),
      cardCount: map['CardCount'] ?? 0,
      learnedCount: map['LearnedCount'] ?? 0,
      isFavorite: map['IsFavorite'] == 1 || map['IsFavorite'] == true,
      isUserCreated: map['IsUserCreated'] == 1 || map['IsUserCreated'] == true,
      authorName: map['AuthorName'] ?? '',
    );
  }

  Deck copyWith({
    int? deckID,
    int? userID,
    int? categoryID,
    String? name,
    String? description,
    String? thumbnail,
    bool? isPublic,
    int? viewCount,
    double? rating,
    int? totalRatings,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? cardCount,
    int? learnedCount,
    bool? isFavorite,
    bool? isUserCreated,
    String? authorName,
  }) {
    return Deck(
      deckID: deckID ?? this.deckID,
      userID: userID ?? this.userID,
      categoryID: categoryID ?? this.categoryID,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      isPublic: isPublic ?? this.isPublic,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cardCount: cardCount ?? this.cardCount,
      learnedCount: learnedCount ?? this.learnedCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      authorName: authorName ?? this.authorName,
    );
  }

  // Helper getters
  double get progress => cardCount > 0 ? learnedCount / cardCount : 0.0;
  String get progressText => '$learnedCount/$cardCount từ';
  
  // Getters để tương thích với code hiện tại
  int get learnedCards => learnedCount;
  int get totalCards => cardCount;

  // Factory constructor từ JSON (cho API calls)
  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      deckID: json['id'] ?? json['deck_id'],
      userID: json['user_id'] ?? 1,
      categoryID: json['category_id'],
      name: json['name'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      isPublic: json['is_public'] ?? false,
      viewCount: json['view_count'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
      cardCount: json['card_count'] ?? json['total_cards'] ?? 0,
      learnedCount: json['learned_count'] ?? json['learned_cards'] ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      isUserCreated: json['is_user_created'] ?? false,
      authorName: json['author_name'] ?? '',
    );
  }

  // Chuyển đổi thành JSON (cho API calls)
  Map<String, dynamic> toJson() {
    return {
      'id': deckID,
      'user_id': userID,
      'category_id': categoryID,
      'name': name,
      'description': description,
      'thumbnail': thumbnail,
      'is_public': isPublic,
      'view_count': viewCount,
      'rating': rating,
      'total_ratings': totalRatings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'card_count': cardCount,
      'learned_count': learnedCount,
      'is_favorite': isFavorite,
      'is_user_created': isUserCreated,
      'author_name': authorName,
    };
  }
}
