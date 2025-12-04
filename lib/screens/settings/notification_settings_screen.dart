

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _notificationService = NotificationService.instance;

  bool _notificationsEnabled = true;
  bool _achievementNotifications = true;
  bool _studyReminders = true;
  bool _streakReminders = true;
  bool _dailyGoalReminders = true;
  
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _achievementNotifications = prefs.getBool('achievement_notifications') ?? true;
      _studyReminders = prefs.getBool('study_reminders') ?? true;
      _streakReminders = prefs.getBool('streak_reminders') ?? true;
      _dailyGoalReminders = prefs.getBool('daily_goal_reminders') ?? true;
      
      final hour = prefs.getInt('reminder_hour') ?? 20;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('achievement_notifications', _achievementNotifications);
    await prefs.setBool('study_reminders', _studyReminders);
    await prefs.setBool('streak_reminders', _streakReminders);
    await prefs.setBool('daily_goal_reminders', _dailyGoalReminders);
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cài đặt thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master toggle
            _buildMasterToggleCard(),
            
            const SizedBox(height: 16),

            if (_notificationsEnabled) ...[
              // Notification types
              _buildSectionTitle('Loại thông báo'),
              _buildNotificationTypesCard(),
              
              const SizedBox(height: 24),

              // Daily reminder settings
              if (_studyReminders) ...[
                _buildSectionTitle('Nhắc nhở học tập hàng ngày'),
                _buildDailyReminderCard(),
                
                const SizedBox(height: 24),
              ],

              // Test notifications
              _buildSectionTitle('Kiểm tra'),
              _buildTestNotificationsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _notificationsEnabled
                  ? const Color(0xFF6366F1).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled
                  ? const Color(0xFF6366F1)
                  : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bật thông báo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notificationsEnabled
                      ? 'Nhận thông báo từ WordMaster'
                      : 'Tắt tất cả thông báo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) async {
              if (value) {
                final allowed = await _notificationService.isNotificationAllowed();
                if (!allowed) {
                  final granted = await _notificationService.requestPermission();
                  if (!granted) {
                    _showPermissionDialog();
                    return;
                  }
                }
              }
              
              setState(() {
                _notificationsEnabled = value;
              });
              await _saveSettings();
              
              if (!value) {
                await _notificationService.cancelAllNotifications();
              }
            },
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNotificationToggle(
            icon: Icons.emoji_events,
            title: 'Thành tích',
            subtitle: 'Thông báo khi mở khóa thành tích mới',
            value: _achievementNotifications,
            color: const Color(0xFFFFA500),
            onChanged: (value) {
              setState(() {
                _achievementNotifications = value;
              });
              _saveSettings();
            },
          ),
          _buildDivider(),
          _buildNotificationToggle(
            icon: Icons.school,
            title: 'Nhắc nhở học tập',
            subtitle: 'Nhắc nhở học tập hàng ngày',
            value: _studyReminders,
            color: const Color(0xFF10B981),
            onChanged: (value) async {
              setState(() {
                _studyReminders = value;
              });
              await _saveSettings();
              
              if (value) {
                await _scheduleDailyReminder();
              } else {
                await _notificationService.cancelScheduledNotification(1);
              }
            },
          ),
          _buildDivider(),
          _buildNotificationToggle(
            icon: Icons.local_fire_department,
            title: 'Cảnh báo Streak',
            subtitle: 'Nhắc khi streak sắp bị mất',
            value: _streakReminders,
            color: const Color(0xFFEF4444),
            onChanged: (value) {
              setState(() {
                _streakReminders = value;
              });
              _saveSettings();
            },
          ),
          _buildDivider(),
          _buildNotificationToggle(
            icon: Icons.flag,
            title: 'Mục tiêu hàng ngày',
            subtitle: 'Nhắc khi chưa hoàn thành mục tiêu',
            value: _dailyGoalReminders,
            color: const Color(0xFF8B5CF6),
            onChanged: (value) {
              setState(() {
                _dailyGoalReminders = value;
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReminderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thời gian nhắc nhở',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Chọn giờ nhận thông báo nhắc học',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.alarm,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(_reminderTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.edit,
                    color: Color(0xFF6366F1),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            title: const Text(
              'Thông báo đơn giản',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: const Text(
              'Kiểm tra thông báo cơ bản',
              style: TextStyle(fontSize: 12),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _notificationService.showBasicNotification(
                  title: 'Test Notification',
                  body: 'Đây là thông báo test từ WordMaster!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Test',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          _buildDivider(),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFA500),
                size: 20,
              ),
            ),
            title: const Text(
              'Thành tích',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: const Text(
              'Kiểm tra thông báo achievement',
              style: TextStyle(fontSize: 12),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _notificationService.showAchievementNotification(
                  title: 'First Steps',
                  message: 'Hoàn thành bài học đầu tiên',
                  points: 10,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Test',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          _buildDivider(),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
            title: const Text(
              'Cảnh báo Streak',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: const Text(
              'Kiểm tra cảnh báo streak',
              style: TextStyle(fontSize: 12),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _notificationService.showStreakWarning(currentStreak: 7);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Test',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _saveSettings();
      await _scheduleDailyReminder();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đặt nhắc nhở lúc ${_formatTime(picked)}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _scheduleDailyReminder() async {
    await _notificationService.scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      title: 'Đến giờ học rồi!',
      message: 'Hãy dành vài phút để học tiếng Anh mỗi ngày!',
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu quyền thông báo'),
        content: const Text(
          'WordMaster cần quyền gửi thông báo để nhắc nhở bạn học tập và cập nhật thành tích. Vui lòng cấp quyền trong cài đặt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Mở settings để user cấp quyền
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }
}