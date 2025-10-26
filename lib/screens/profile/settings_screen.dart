import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import 'notification_settings_screen.dart';
import 'language_settings_screen.dart';
import 'help_center_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Menu Items
          _buildMenuItem(
            context,
            Icons.notifications,
            'Thông báo',
            'Cài đặt thông báo',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return _buildSwitchMenuItem(
                context,
                Icons.dark_mode_outlined,
                'Chế độ tối',
                'Bật/tắt giao diện tối',
                settingsProvider.isDarkMode,
                (value) {
                  settingsProvider.setDarkMode(!settingsProvider.isDarkMode);
                },
              );
            },
          ),
          _buildMenuItem(
            context,
            Icons.language_outlined,
            'Ngôn ngữ',
            'Thay đổi ngôn ngữ ứng dụng',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            Icons.help_outline,
            'Hỗ trợ',
            'Trung tâm trợ giúp',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            Icons.info_outline,
            'Về ứng dụng',
            'Thông tin phiên bản',
            () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4f6bff).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4f6bff)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4f6bff).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4f6bff)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF4f6bff),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4f6bff).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Color(0xFF4f6bff)),
              ),
              const SizedBox(width: 12),
              const Text('Về WordMaster'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WordMaster',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Phiên bản: 1.0.0'),
              const SizedBox(height: 16),
              const Text(
                'Ứng dụng học từ vựng thông minh với flashcards và quiz tương tác.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Được phát triển bởi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Nhóm phát triển WordMaster'),
              const SizedBox(height: 16),
              const Text(
                '© 2024 WordMaster. Mọi quyền được bảo lưu.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Đóng',
                style: TextStyle(color: Color(0xFF4f6bff)),
              ),
            ),
          ],
        );
      },
    );
  }
}
