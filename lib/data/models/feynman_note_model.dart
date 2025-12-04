class FeynmanNote {
  final int id;
  final int userId;
  final String cardType; 
  final int cardId;
  final String textNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeynmanNote({
    required this.id,
    required this.userId,
    required this.cardType,
    required this.cardId,
    required this.textNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeynmanNote.fromJson(Map<String, dynamic> json) {
    return FeynmanNote(
      id: json['id'],
      userId: json['userId'],
      cardType: json['cardType'],
      cardId: json['cardId'],
      textNote: json['textNote'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cardType': cardType,
      'cardId': cardId,
      'textNote': textNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}