import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationTestHelper {
  static final NotificationService _notificationService = NotificationService.instance;

  // Test basic notification
  static Future<void> testBasicNotification() async {
    await _notificationService.showBasicNotification(
      title: 'Test Notification',
      body: 'This is a test notification from WordMaster',
      payload: 'test_data',
    );
  }

  // Test achievement notification
  static Future<void> testAchievementNotification() async {
    await _notificationService.showAchievementNotification(
      title: 'Achievement Unlocked!',
      message: 'You completed your first vocabulary session',
      points: 25,
    );
  }

  // Test study reminder
  static Future<void> testStudyReminder() async {
    await _notificationService.showStudyReminder(
      title: 'Study Time!',
      message: 'Don\'t forget to practice your English today',
    );
  }

  // Test streak warning
  static Future<void> testStreakWarning() async {
    await _notificationService.showStreakWarning(
      currentStreak: 7,
    );
  }

  // Test progress notification
  static Future<void> testProgressNotification() async {
    await _notificationService.showProgressNotification(
      title: 'Learning Progress',
      body: 'You\'re making great progress!',
      progress: 3,
      maxProgress: 10,
    );
  }

  // Schedule daily reminder (for 9 AM)
  static Future<void> scheduleTestReminder() async {
    await _notificationService.scheduleDailyReminder(
      hour: 9,
      minute: 0,
      title: 'Daily Study Time',
      message: 'Time for your daily English practice!',
    );
  }

  // Cancel all test notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  // Check if notifications are allowed
  static Future<bool> checkPermission() async {
    return await _notificationService.isNotificationAllowed();
  }
}

// Widget for testing notifications in debug mode
class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: NotificationTestHelper.testBasicNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Test Basic Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: NotificationTestHelper.testAchievementNotification,
              icon: const Icon(Icons.emoji_events),
              label: const Text('Test Achievement Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: NotificationTestHelper.testStudyReminder,
              icon: const Icon(Icons.school),
              label: const Text('Test Study Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: NotificationTestHelper.testStreakWarning,
              icon: const Icon(Icons.local_fire_department),
              label: const Text('Test Streak Warning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: NotificationTestHelper.testProgressNotification,
              icon: const Icon(Icons.trending_up),
              label: const Text('Test Progress Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            
            const Divider(),
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: NotificationTestHelper.scheduleTestReminder,
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule Daily Reminder (9 AM)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: NotificationTestHelper.cancelAllNotifications,
              icon: const Icon(Icons.clear_all),
              label: const Text('Cancel All Notifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            
            FutureBuilder<bool>(
              future: NotificationTestHelper.checkPermission(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: snapshot.data! ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          snapshot.data! ? Icons.check_circle : Icons.error,
                          color: snapshot.data! ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          snapshot.data! 
                              ? 'Notifications Enabled' 
                              : 'Notifications Disabled',
                          style: TextStyle(
                            color: snapshot.data! ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}