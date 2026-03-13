import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/srs_service.dart';
import '../services/auth_service.dart';

class SrsController extends GetxController {
  final _srsService = SrsService.instance;
  final _authService = AuthService.instance;

  final isLoading = false.obs;
  final error = ''.obs;

  // Daily Stats
  final dueCount = 0.obs;
  final newCount = 0.obs;
  final reviewedToday = 0.obs;
  final currentStreak = 0.obs;
  final longestStreak = 0.obs;
  final totalPoints = 0.obs;

  // Review Session
  final reviewItems = <dynamic>[].obs;
  final currentIndex = 0.obs;
  final sessionStats = <String, int>{
    'easy': 0,
    'good': 0,
    'hard': 0,
    'forgot': 0,
  }.obs;

  // Settings
  final contentMode = 'Mixed'.obs; 
  final maxNewCardsPerDay = 20.obs;
  final showExamples = true.obs;
  final autoPlayAudio = false.obs;

  dynamic get currentItem => 
      reviewItems.isNotEmpty && currentIndex.value < reviewItems.length
          ? reviewItems[currentIndex.value]
          : null;

  double get progress => 
      reviewItems.isEmpty ? 0 : currentIndex.value / reviewItems.length;

  int get totalReviewed => 
      sessionStats['easy']! + 
      sessionStats['good']! + 
      sessionStats['hard']! + 
      sessionStats['forgot']!;


  @override
  void onInit() {
    super.onInit();
    loadDailyStats();
    loadSettings();
  }

  
  void resetUserData() {
    _resetToDefaults();
    reviewItems.clear();
    currentIndex.value = 0;
    sessionStats.assignAll({
      'easy': 0,
      'good': 0,
      'hard': 0,
      'forgot': 0,
    });
  }

 
  Future<void> loadDailyStats() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authService.userId;
      if (userId == null || userId == 0) {
        
        _resetToDefaults();
        return;
      }

      final response = await _srsService.getDailyStats(userId);
      
      if (response['success'] == true) {
        final data = response['data'];
        dueCount.value = data['dueCount'] ?? 0;
        newCount.value = data['newCount'] ?? 0;
        reviewedToday.value = data['reviewedToday'] ?? 0;
        currentStreak.value = data['currentStreak'] ?? 0;
        longestStreak.value = data['longestStreak'] ?? 0;
        totalPoints.value = data['totalPoints'] ?? 0;
      } else {
        
        _resetToDefaults();
      }
    } catch (e) {
      error.value = e.toString();
      print('loadDailyStats error: $e');
     
      _resetToDefaults();
    } finally {
      isLoading.value = false;
    }
  }

  void _resetToDefaults() {
    dueCount.value = 0;
    newCount.value = 0;
    reviewedToday.value = 0;
    currentStreak.value = 0;
    longestStreak.value = 0;
    totalPoints.value = 0;
  }


  Future<void> startReviewSession() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authService.userId;
      if (userId == 0) throw 'User not logged in';

      final response = await _srsService.getDueReviews(
        userId: userId,
        contentType: contentMode.value,
      );

      if (response['success'] == true) {
        reviewItems.value = response['data'] ?? [];
        currentIndex.value = 0;
        sessionStats.value = {
          'easy': 0,
          'good': 0,
          'hard': 0,
          'forgot': 0,
        };

        if (reviewItems.isEmpty) {
          Get.snackbar(
            'Thông báo', 
            'Không có thẻ nào cần ôn tập!',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      error.value = e.toString();
      print('startReviewSession error: $e');
      Get.snackbar('Lỗi', 'Không thể tải bài ôn tập: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitAnswer(String difficulty) async {
    try {
      final userId = _authService.userId;
      if (userId == 0) throw 'User not logged in';

      final item = currentItem;
      if (item == null) return;

      // Update session stats
      sessionStats[difficulty.toLowerCase()] = 
          (sessionStats[difficulty.toLowerCase()] ?? 0) + 1;

      // Submit to backend
      await _srsService.submitReview(
        userId: userId,
        contentType: item['contentType'],
        contentId: item['contentId'],
        difficulty: difficulty,
      );

      // Move to next card
      if (currentIndex.value < reviewItems.length - 1) {
        currentIndex.value++;
      } else {
        // Session completed
        _showSessionSummary();
      }
    } catch (e) {
      print('submitAnswer error: $e');
      Get.snackbar('Lỗi', 'Không thể lưu kết quả: $e');
    }
  }

  void _showSessionSummary() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Hoàn thành!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tổng số thẻ: ${reviewItems.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Dễ', sessionStats['easy']!, Colors.green),
                _buildStatColumn('Tốt', sessionStats['good']!, Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Khó', sessionStats['hard']!, Colors.orange),
                _buildStatColumn('Quên', sessionStats['forgot']!, Colors.red),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Back to dashboard
              loadDailyStats(); // Refresh stats
            },
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

 
  Future<void> loadSettings() async {
    try {
      final userId = _authService.userId;
      if (userId == 0) return;

      final response = await _srsService.getSettings(userId);
      
      if (response['success'] == true) {
        final data = response['data'];
        maxNewCardsPerDay.value = data['maxNewCardsPerDay'] ?? 20;
        contentMode.value = data['contentMode'] ?? 'Mixed';
        showExamples.value = data['showExamples'] ?? true;
        autoPlayAudio.value = data['autoPlayAudio'] ?? false;
      }
    } catch (e) {
      print('loadSettings error: $e');
    }
  }

  Future<void> refresh() async {
    await loadDailyStats();
  }

  
  Future<void> submitFlashcardResult({
    required String contentType,
    required int contentId,
    required bool isCorrect,
  }) async {
    try {
      final userId = _authService.userId;
      if (userId == 0) {
        print('User not logged in, skipping SRS submission');
        return;
      }

      // Convert boolean to difficulty string
      final difficulty = isCorrect ? 'easy' : 'forgot';

      await _srsService.submitReview(
        userId: userId,
        contentType: contentType,
        contentId: contentId,
        difficulty: difficulty,
      );

      print('SRS result submitted: $contentType:$contentId -> $difficulty');
    } catch (e) {
      print('submitFlashcardResult error: $e');
      // Don't show error to user as this is background functionality
    }
  }
}