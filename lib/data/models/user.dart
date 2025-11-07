class User {
  final int? userID;
  final String fullName;
  final String email;
  final String password;
  final String avatar;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final int currentStreak;
  final int totalPoints;
  final int level;

  User({
    this.userID,
    required this.fullName,
    required this.email,
    required this.password,
    this.avatar = 'default-avatar.png',
    required this.createdAt,
    this.lastLogin,
    this.currentStreak = 0,
    this.totalPoints = 0,
    this.level = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserID': userID,
      'FullName': fullName,
      'Email': email,
      'Password': password,
      'Avatar': avatar,
      'CreatedAt': createdAt.toIso8601String(),
      'LastLogin': lastLogin?.toIso8601String(),
      'CurrentStreak': currentStreak,
      'TotalPoints': totalPoints,
      'Level': level,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userID: map['UserID'],
      fullName: map['FullName'],
      email: map['Email'],
      password: map['Password'],
      avatar: map['Avatar'] ?? 'default-avatar.png',
      createdAt: DateTime.parse(map['CreatedAt']),
      lastLogin: map['LastLogin'] != null
          ? DateTime.parse(map['LastLogin'])
          : null,
      currentStreak: map['CurrentStreak'] ?? 0,
      totalPoints: map['TotalPoints'] ?? 0,
      level: map['Level'] ?? 1,
    );
  }

  User copyWith({
    int? userID,
    String? fullName,
    String? email,
    String? password,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastLogin,
    int? currentStreak,
    int? totalPoints,
    int? level,
  }) {
    return User(
      userID: userID ?? this.userID,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      currentStreak: currentStreak ?? this.currentStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
    );
  }
}
