// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoPlayAudio = true;
  bool _dailyReminder = true;
  String _language = 'Tiếng Việt';
  String _difficultyLevel = 'Trung bình';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
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
            // Tài khoản
            _buildSectionTitle('Tài khoản'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle: 'Quản lý thông tin tài khoản',
                onTap: () => _showComingSoon('Thông tin cá nhân'),
              ),
              _buildSettingsItem(
                icon: Icons.security_outlined,
                title: 'Bảo mật',
                subtitle: 'Đổi mật khẩu, xác thực 2 bước',
                onTap: () => _showComingSoon('Bảo mật'),
              ),
              _buildSettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Quyền riêng tư',
                subtitle: 'Kiểm soát dữ liệu cá nhân',
                onTap: () => _showComingSoon('Quyền riêng tư'),
              ),
            ]),

            const SizedBox(height: 24),

            // Học tập
            _buildSectionTitle('Học tập'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.school_outlined,
                title: 'Mục tiêu học tập',
                subtitle: 'Thiết lập mục tiêu hàng ngày',
                onTap: () => _showComingSoon('Mục tiêu học tập'),
              ),
              _buildSettingsItemWithDropdown(
                icon: Icons.flag_outlined,
                title: 'Cấp độ khó',
                subtitle: 'Điều chỉnh độ khó bài học',
                value: _difficultyLevel,
                onChanged: (value) {
                  setState(() {
                    _difficultyLevel = value!;
                  });
                },
                items: ['Dễ', 'Trung bình', 'Khó', 'Rất khó'],
              ),
              _buildSettingsItemWithSwitch(
                icon: Icons.play_arrow_outlined,
                title: 'Tự động phát audio',
                subtitle: 'Tự động phát âm thanh bài học',
                value: _autoPlayAudio,
                onChanged: (value) {
                  setState(() {
                    _autoPlayAudio = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Thông báo
            _buildSectionTitle('Thông báo'),
            _buildSettingsCard([
              _buildSettingsItemWithSwitch(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                subtitle: 'Bật/tắt tất cả thông báo',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSettingsItemWithSwitch(
                icon: Icons.alarm_outlined,
                title: 'Nhắc nhở học tập',
                subtitle: 'Nhắc nhở học tập hàng ngày',
                value: _dailyReminder,
                onChanged: (value) {
                  setState(() {
                    _dailyReminder = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Giao diện
            _buildSectionTitle('Giao diện'),
            _buildSettingsCard([
              _buildSettingsItemWithSwitch(
                icon: Icons.dark_mode_outlined,
                title: 'Chế độ tối',
                subtitle: 'Chuyển đổi giữa chế độ sáng/tối',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              _buildSettingsItemWithDropdown(
                icon: Icons.language_outlined,
                title: 'Ngôn ngữ',
                subtitle: 'Thay đổi ngôn ngữ ứng dụng',
                value: _language,
                onChanged: (value) {
                  setState(() {
                    _language = value!;
                  });
                },
                items: ['Tiếng Việt', 'English', '中文', '日本語'],
              ),
            ]),

            const SizedBox(height: 24),

            // Hỗ trợ
            _buildSectionTitle('Hỗ trợ'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Trung tâm trợ giúp',
                subtitle: 'Câu hỏi thường gặp và hướng dẫn',
                onTap: () => _showComingSoon('Trung tâm trợ giúp'),
              ),
              _buildSettingsItem(
                icon: Icons.feedback_outlined,
                title: 'Gửi phản hồi',
                subtitle: 'Chia sẻ ý kiến về ứng dụng',
                onTap: () => _showComingSoon('Gửi phản hồi'),
              ),
              _buildSettingsItem(
                icon: Icons.bug_report_outlined,
                title: 'Báo lỗi',
                subtitle: 'Báo cáo sự cố kỹ thuật',
                onTap: () => _showComingSoon('Báo lỗi'),
              ),
            ]),

            const SizedBox(height: 24),

            // Về ứng dụng
            _buildSectionTitle('Về ứng dụng'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'Giới thiệu',
                subtitle: 'Phiên bản 1.0.0',
                onTap: () => _showAboutDialog(),
              ),
              _buildSettingsItem(
                icon: Icons.article_outlined,
                title: 'Điều khoản sử dụng',
                subtitle: 'Điều khoản và chính sách',
                onTap: () => _showComingSoon('Điều khoản sử dụng'),
              ),
              _buildSettingsItem(
                icon: Icons.shield_outlined,
                title: 'Chính sách bảo mật',
                subtitle: 'Quyền riêng tư và bảo mật',
                onTap: () => _showComingSoon('Chính sách bảo mật'),
              ),
            ]),

            const SizedBox(height: 32),

            // Nút đăng xuất
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showLogoutDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nút xóa tài khoản
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _showDeleteAccountDialog,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Xóa tài khoản',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildSettingsCard(List<Widget> children) {
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
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSettingsItemWithSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildSettingsItemWithDropdown({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sẽ sớm được cập nhật!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'WordMaster',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản: 1.0.0'),
            SizedBox(height: 8),
            Text('Ứng dụng học tiếng Anh toàn diện'),
            SizedBox(height: 8),
            Text('© 2024 WordMaster. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text(
          'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn. Bạn có chắc chắn muốn xóa tài khoản?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Xóa tài khoản');
            },
            child: const Text(
              'Xóa tài khoản',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // TODO: Implement logout logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đăng xuất')),
    );
    // Navigate to login screen or perform logout
  }
}