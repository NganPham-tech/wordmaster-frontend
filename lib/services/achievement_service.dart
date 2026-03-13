import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/models/achievement.dart';
import 'api_service.dart';

class AchievementService extends GetxService {
  static AchievementService get instance => Get.find();
  final _apiService = ApiService.instance;


  Future<List<Achievement>> getUserAchievements() async {
    try {
      print('Calling API: /users/achievements');
      final response = await _apiService.get('/users/achievements');
      
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> achievementsData = responseData['data'];
          final achievements = achievementsData.map<Achievement>((json) => Achievement.fromJson(json)).toList();
          print('Successfully loaded ${achievements.length} achievements from API');
          return achievements;
        }
      }
      
      print('API failed, using mock data');
      return getMockAchievements();
    } catch (e) {
      print('Error getting user achievements: $e');
      return getMockAchievements();
    }
  }

  Future<AchievementStats> getAchievementStats() async {
    try {
      final response = await _apiService.get('/users/achievement-stats');
      
      if (response.isOk && response.body != null) {
        final responseData = response.body;
        if (responseData['success'] == true && responseData['data'] != null) {
          return AchievementStats.fromJson(responseData['data']);
        }
      }
      
      print('API failed, using mock stats');
      return getMockAchievementStats();
    } catch (e) {
      print('Error getting achievement stats: $e');
      return getMockAchievementStats();
    }
  }


  List<Achievement> getMockAchievements() {
    return [
      Achievement(
        id: 1,
        title: 'First Steps',
        description: 'Hoàn thành session học đầu tiên',
        badgeIcon: Icons.track_changes,
        condition: 'complete_sessions',
        targetProgress: 1,
        points: 10,
        isUnlocked: true,
        progress: 1,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Achievement(
        id: 2,
        title: 'Grammar Guru',
        description: 'Hoàn thành 5 bài học ngữ pháp',
        badgeIcon: Icons.menu_book,
        condition: 'complete_grammar_sessions',
        targetProgress: 5,
        points: 25,
        isUnlocked: true,
        progress: 5,
        unlockedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Achievement(
        id: 3,
        title: 'Dedicated Learner',
        description: 'Học liên tục 7 ngày',
        badgeIcon: Icons.local_fire_department,
        condition: 'daily_streak',
        targetProgress: 7,
        points: 50,
        isUnlocked: false,
        progress: 4,
      ),
      Achievement(
        id: 4,
        title: 'Vocabulary Master',
        description: 'Học 100 từ vựng qua Flashcard',
        badgeIcon: Icons.lightbulb_outline,
        condition: 'flashcard_words_learned',
        targetProgress: 100,
        points: 75,
        isUnlocked: false,
        progress: 32,
      ),
      Achievement(
        id: 5,
        title: 'Quiz Champion',
        description: 'Đạt 90% độ chính xác trong 10 bài quiz',
        badgeIcon: Icons.emoji_events,
        condition: 'quiz_accuracy_streak',
        targetProgress: 10,
        points: 100,
        isUnlocked: false,
        progress: 6,
      ),
      Achievement(
        id: 6,
        title: 'Dictation Expert',
        description: 'Hoàn thành 20 bài dictation với điểm cao',
        badgeIcon: Icons.mic,
        condition: 'dictation_high_score',
        targetProgress: 20,
        points: 60,
        isUnlocked: false,
        progress: 8,
      ),
      Achievement(
        id: 7,
        title: 'Speed Reader',
        description: 'Hoàn thành bài học trong thời gian kỷ lục',
        badgeIcon: Icons.speed,
        condition: 'fast_completion',
        targetProgress: 1,
        points: 30,
        isUnlocked: false,
        progress: 0,
      ),
      Achievement(
        id: 8,
        title: 'Perfectionist',
        description: 'Đạt 100% độ chính xác trong 5 session liên tiếp',
        badgeIcon: Icons.diamond,
        condition: 'perfect_accuracy_streak',
        targetProgress: 5,
        points: 150,
        isUnlocked: false,
        progress: 2,
      ),
    ];
  }

  AchievementStats getMockAchievementStats() {
    final achievements = getMockAchievements();
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final totalPoints = achievements
        .where((a) => a.isUnlocked)
        .fold<int>(0, (sum, a) => sum + a.points);

    return AchievementStats(
      totalAchievements: achievements.length,
      unlockedAchievements: unlocked,
      totalPoints: totalPoints,
      currentStreak: 4,
      bestStreak: 8,
      categoryProgress: {
        'flashcard': 32,
        'quiz': 6,
        'dictation': 8,
        'grammar': 5,
      },
    );
  }
}