// lib/controllers/session_controller.dart
import 'package:get/get.dart';
import '../data/models/study_session_model.dart';
import '../data/models/achievement_model.dart';
import '../widgets/achievement_dialog.dart';
import '../services/session_service.dart';

class SessionController extends GetxController {
  final SessionService _service = SessionService();
  
  final Rx<StudySession?> currentSession = Rx<StudySession?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // Session tracking
  DateTime? _sessionStartTime;
  int _completedItems = 0;
  final RxDouble _currentScore = 0.0.obs;
  

  Future<bool> startSession({
    required String contentType,
    required int contentId,
    required String contentTitle,
    String mode = 'Learn',
    int? totalItems,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final session = await _service.startSession(
        contentType: contentType,
        contentId: contentId,
        mode: mode,
        totalItems: totalItems,
      );
      
      if (session != null) {
        currentSession.value = session;
        _sessionStartTime = DateTime.now();
        _completedItems = 0;
        _currentScore.value = 0;
        return true;
      } else {
        error.value = 'Failed to start session';
        return false;
      }
    } catch (e) {
      error.value = 'Error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  

  Future<void> updateProgress({
    int? completedItems,
    double? scoreIncrement,
  }) async {
    if (currentSession.value == null) return;
    
    if (completedItems != null) {
      _completedItems = completedItems;
    }
    
    if (scoreIncrement != null) {
      _currentScore.value += scoreIncrement;
    }
    
    await _service.updateProgress(
      sessionId: currentSession.value!.id,
      completedItems: _completedItems,
      score: _currentScore.value,
    );
  }
  

  Future<void> incrementCompleted({double scoreIncrement = 0}) async {
    _completedItems++;
    if (scoreIncrement > 0) {
      _currentScore.value += scoreIncrement;
    }
    
    await updateProgress(
      completedItems: _completedItems,
      scoreIncrement: scoreIncrement > 0 ? scoreIncrement : null,
    );
  }
 
  Future<StudySession?> completeSession() async {
    if (currentSession.value == null) return null;
    
    try {
      isLoading.value = true;
      
      final completedSession = await _service.completeSession(
        sessionId: currentSession.value!.id,
        completedItems: _completedItems,
        score: _currentScore.value,
      );
      
      if (completedSession != null) {
        // Parse the response to get session data
        final sessionData = completedSession['session'] ?? completedSession;
            
        if (sessionData is Map<String, dynamic>) {
          currentSession.value = StudySession.fromJson(sessionData);
        }
    
        final unlockedAchievements = completedSession['unlockedAchievements'];
            
        if (unlockedAchievements != null && unlockedAchievements.isNotEmpty) {
          _showAchievementDialogs(unlockedAchievements);
        }
        
        return currentSession.value;
      }
      
      return null;
    } catch (e) {
      error.value = 'Error completing session: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  

  void _showAchievementDialogs(List<dynamic> achievements) async {
    for (var achievementData in achievements) {
      try {
        final achievement = Achievement.fromJson(achievementData);
        
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        AchievementDialog.show(achievement);
        
   
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        print('Error parsing achievement: $e');
      }
    }
  }
  

  void endSession() {
    currentSession.value = null;
    _sessionStartTime = null;
    _completedItems = 0;
    _currentScore.value = 0;
  }
  

  int get completedItems => _completedItems;
  double get currentScore => _currentScore.value;
  
  Duration? get elapsedTime {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }
  
  double get progress {
    if (currentSession.value == null || 
        currentSession.value!.totalItems == null ||
        currentSession.value!.totalItems == 0) {
      return 0.0;
    }
    return _completedItems / currentSession.value!.totalItems!;
  }
}