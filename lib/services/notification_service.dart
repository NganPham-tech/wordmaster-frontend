import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;
  bool _isInitialized = false;

 
  Future<void> initialize() async {
    try {
      await AwesomeNotifications().initialize(
     
        null,
        [
        
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF6366F1),
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),
        
        
        NotificationChannel(
          channelKey: 'study_reminder',
          channelName: 'Study Reminders',
          channelDescription: 'Daily study reminder notifications',
          defaultColor: const Color(0xFF10B981),
          ledColor: Colors.green,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
        
        
        NotificationChannel(
          channelKey: 'achievement',
          channelName: 'Achievements',
          channelDescription: 'Achievement unlock notifications',
          defaultColor: const Color(0xFFFFA500),
          ledColor: Colors.orange,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
        
 
        NotificationChannel(
          channelKey: 'streak_reminder',
          channelName: 'Streak Reminders',
          channelDescription: 'Streak maintenance reminders',
          defaultColor: const Color(0xFFEF4444),
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
        ),
        ],
      );

   
      await requestPermission();

      
      _setupListeners();
      
      _isInitialized = true;
      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
      _isInitialized = false;
    }
  }


  Future<bool> requestPermission() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

 
  Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }


  void _setupListeners() {
  
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }



  Future<void> showBasicNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, skipping notification');
      }
      return;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'basic_channel',
          title: title,
          body: body,
          payload: {'data': payload ?? ''},
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing basic notification: $e');
      }
    }
  }


  Future<void> showAchievementNotification({
    required String title,
    required String message,
    required int points,
    String? icon,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, skipping notification');
      }
      return;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'achievement',
          title: title,
          body: '$message\n+$points XP',
          payload: {'type': 'achievement', 'points': points.toString()},
          notificationLayout: NotificationLayout.BigText,
          backgroundColor: const Color(0xFFFFA500),
          wakeUpScreen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'VIEW',
            label: 'Xem chi tiết',
            color: const Color(0xFF6366F1),
            autoDismissible: true,
          ),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing achievement notification: $e');
      }
    }
  }


  Future<void> showStudyReminder({
    required String title,
    required String message,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, skipping notification');
      }
      return;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'study_reminder',
          title: title,
          body: message,
          payload: {'type': 'study_reminder'},
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STUDY_NOW',
            label: 'Học ngay',
            color: const Color(0xFF10B981),
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'REMIND_LATER',
            label: 'Nhắc sau',
            autoDismissible: true,
          ),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing study reminder: $e');
      }
    }
  }

 
  Future<void> showStreakWarning({
    required int currentStreak,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, skipping notification');
      }
      return;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'streak_reminder',
          title: 'Streak của bạn sắp mất!',
          body: 'Bạn có chuỗi $currentStreak ngày. Học ngay để duy trì streak!',
          payload: {'type': 'streak_warning', 'streak': currentStreak.toString()},
          notificationLayout: NotificationLayout.BigText,
          criticalAlert: true,
          wakeUpScreen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'SAVE_STREAK',
            label: 'Duy trì streak',
            color: const Color(0xFFEF4444),
            autoDismissible: true,
          ),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing streak warning: $e');
      }
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String? title,
    String? message,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1, 
          channelKey: 'study_reminder',
          title: title ?? 'Đến giờ học rồi!',
          body: message ?? 'Hãy dành vài phút để học tiếng Anh mỗi ngày!',
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true, 
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STUDY_NOW',
            label: 'Học ngay',
            autoDismissible: true,
          ),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling daily reminder: $e');
      }
    }
  }


  Future<void> cancelScheduledNotification(int id) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, cannot cancel notification');
      }
      return;
    }

    try {
      await AwesomeNotifications().cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling notification: $e');
      }
    }
  }

  
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, cannot cancel notifications');
      }
      return;
    }

    try {
      await AwesomeNotifications().cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling all notifications: $e');
      }
    }
  }

  
  Future<void> showProgressNotification({
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, skipping notification');
      }
      return;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 100, 
          channelKey: 'basic_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.ProgressBar,
          progress: progress.toDouble(),
          locked: progress < maxProgress,
          payload: {'progress': progress.toString()},
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing progress notification: $e');
      }
    }
  }


  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print('Notification created: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    print('Notification displayed: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('Notification dismissed: ${receivedAction.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('Action received: ${receivedAction.buttonKeyPressed}');

   
    switch (receivedAction.buttonKeyPressed) {
      case 'VIEW':
       
        print('Navigate to achievement');
        break;
      case 'STUDY_NOW':
       
        print('Navigate to study');
        break;
      case 'SAVE_STREAK':
     
        print('Save streak');
        break;
      case 'REMIND_LATER':
      
        print('Remind later');
        break;
    }
  }
}