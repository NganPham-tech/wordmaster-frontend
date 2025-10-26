class User {
  final int? userID;
  final String fullName;
  final String email;
  final String password;
  final String avatar;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    this.userID,
    required this.fullName,
    required this.email,
    required this.password,
    this.avatar = 'default-avatar.png',
    required this.createdAt,
    this.lastLogin,
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
  }) {
    return User(
      userID: userID ?? this.userID,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
