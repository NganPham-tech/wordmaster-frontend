// lib/services/user_service.dart
import 'package:get/get.dart';
import 'api_service.dart';
import '../data/models/profile_model.dart';

class UserService extends GetxService {
  static UserService get instance => Get.find<UserService>();
  final _apiService = ApiService.instance;

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final response = await _apiService.get('/users/profile');
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          return UserProfile(
            id: data['id'].toString(),
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            email: data['email'] ?? '',
            phone: data['phone'],
            avatarUrl: data['avatar'],
            joinDate: data['createdAt'] != null 
                ? DateTime.parse(data['createdAt']) 
                : DateTime.now(),
            level: data['level']?.toString() ?? '1',
            currentStreak: data['currentStreak'] ?? 0,
            longestStreak: data['longestStreak'] ?? 0,
            totalPoints: data['totalPoints'] ?? 0,
            totalCardsLearned: 0,
            totalQuizzesCompleted: 0, 
            averageAccuracy: 0.0,
            bio: null,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final response = await _apiService.get('/users/stats');
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  // Get weekly study stats
  Future<List<StudyStat>> getWeeklyStats() async {
    try {
      final response = await _apiService.get('/users/weekly-stats');
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((stat) {
            return StudyStat(
              date: DateTime.parse(stat['date']),
              minutesStudied: stat['minutesStudied'] ?? 0,
              cardsLearned: stat['cardsLearned'] ?? 0,
              quizzesCompleted: stat['quizzesCompleted'] ?? 0,
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting weekly stats: $e');
      return [];
    }
  }

  // Get recent activities
  Future<List<RecentActivity>> getRecentActivities({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/users/recent-activities?limit=${limit.toString()}'
      );
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((activity) {
            return RecentActivity(
              id: activity['id'],
              type: activity['type'],
              title: activity['title'],
              description: activity['description'],
              timestamp: DateTime.parse(activity['timestamp']),
              score: activity['score'],
              deckName: activity['deckName'],
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  // Get user achievements
  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final response = await _apiService.get('/users/achievements');
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error getting achievements: $e');
      return [];
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _apiService.put('/users/profile', data);
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}