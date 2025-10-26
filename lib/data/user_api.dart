// lib/data/user_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserAPI {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Thay bằng URL API của bạn

  // Đồng bộ Firebase user vào database
  static Future<Map<String, dynamic>> syncUser({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? avatar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebaseUid': firebaseUid,
          'email': email,
          'fullName': fullName,
          'avatar': avatar,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to sync user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing user: $e');
      rethrow;
    }
  }

  // Lấy profile user bằng Firebase UID
  static Future<Map<String, dynamic>> getUserProfile({
    String? firebaseUid,
    int? userId,
  }) async {
    if (firebaseUid == null && userId == null) {
      throw Exception('Either firebaseUid or userId must be provided');
    }

    try {
      final queryParams = firebaseUid != null
          ? 'firebaseUid=$firebaseUid'
          : 'userId=$userId';

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile?$queryParams'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }
}

// Model cho User Profile
class UserProfile {
  final int userId;
  final String? firebaseUid;
  final String fullName;
  final String email;
  final String avatar;
  final int totalLearned;
  final int totalMastered;
  final int currentStreak;
  final int bestStreak;
  final int totalPoints;
  final int level;
  final int perfectQuizCount;
  final int memoryRate;
  final int totalQuizzes;

  UserProfile({
    required this.userId,
    this.firebaseUid,
    required this.fullName,
    required this.email,
    required this.avatar,
    required this.totalLearned,
    required this.totalMastered,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalPoints,
    required this.level,
    required this.perfectQuizCount,
    required this.memoryRate,
    required this.totalQuizzes,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as int,
      firebaseUid: json['firebaseUid'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      totalLearned: json['totalLearned'] as int,
      totalMastered: json['totalMastered'] as int,
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
      totalPoints: json['totalPoints'] as int,
      level: json['level'] as int,
      perfectQuizCount: json['perfectQuizCount'] as int,
      memoryRate: json['memoryRate'] as int,
      totalQuizzes: json['totalQuizzes'] as int,
    );
  }
}