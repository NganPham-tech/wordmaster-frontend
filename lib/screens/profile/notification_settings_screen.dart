import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _studyReminders = true;
  bool _achievementNotifications = true;
  bool _weeklyProgress = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studyReminders = prefs.getBool('study_reminders') ?? true;
      _achievementNotifications =
          prefs.getBool('achievement_notifications') ?? true;
      _weeklyProgress = prefs.getBool('weekly_progress') ?? false;
      _soundEnabled = prefs.getBool('notification_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notification_vibration') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Notification Types Section
          _buildSectionHeader('Loại thông báo'),
          const SizedBox(height: 16),
          _buildNotificationTile(
            icon: Icons.access_time,
            title: 'Nhắc nhở học tập',
            subtitle: 'Nhận thông báo nhắc nhở học từ vựng hàng ngày',
            value: _studyReminders,
            onChanged: (value) {
              setState(() {
                _studyReminders = value;
              });
              _saveSetting('study_reminders', value);
            },
          ),
          _buildNotificationTile(
            icon: Icons.emoji_events,
            title: 'Thành tích',
            subtitle: 'Thông báo khi đạt được thành tích mới',
            value: _achievementNotifications,
            onChanged: (value) {
              setState(() {
                _achievementNotifications = value;
              });
              _saveSetting('achievement_notifications', value);
            },
          ),
          _buildNotificationTile(
            icon: Icons.bar_chart,
            title: 'Báo cáo tiến độ',
            subtitle: 'Tóm tắt tiến độ học tập hàng tuần',
            value: _weeklyProgress,
            onChanged: (value) {
              setState(() {
                _weeklyProgress = value;
              });
              _saveSetting('weekly_progress', value);
            },
          ),

          const SizedBox(height: 32),

          // Notification Behavior Section
          _buildSectionHeader('Hành vi thông báo'),
          const SizedBox(height: 16),
          _buildNotificationTile(
            icon: Icons.volume_up,
            title: 'Âm thanh',
            subtitle: 'Phát âm thanh khi có thông báo',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
              _saveSetting('notification_sound', value);
            },
          ),
          _buildNotificationTile(
            icon: Icons.vibration,
            title: 'Rung',
            subtitle: 'Rung thiết bị khi có thông báo',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              _saveSetting('notification_vibration', value);
            },
          ),

          const SizedBox(height: 32),

          // Study Reminder Time
          _buildSectionHeader('Thời gian nhắc nhở'),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFd63384).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, color: Color(0xFFd63384)),
              ),
              title: const Text('Giờ nhắc nhở học tập'),
              subtitle: const Text('20:00 hàng ngày'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showTimePickerDialog();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thông báo giúp bạn duy trì thói quen học tập đều đặn và đạt được mục tiêu.',
                    style: TextStyle(color: Colors.blue.shade800, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFd63384),
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFd63384).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFd63384)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFd63384),
      ),
    );
  }

  void _showTimePickerDialog() {
    showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFFd63384)),
          ),
          child: child!,
        );
      },
    ).then((time) {
      if (time != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đặt giờ nhắc nhở: ${time.format(context)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
