import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser; // Null if not logged in

  @override
  void initState() {
    super.initState();
    // TODO: Check if user is logged in and fetch user data
  }

  @override
  Widget build(BuildContext context) {
    // If user is not logged in, show login/register options
    if (_currentUser == null) {
      return _buildAuthOptions();
    }

    // If user is logged in, show profile
    return _buildProfile();
  }

  Widget _buildAuthOptions() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ảnh chào mừng
              Image.asset(
                '/images/bannerapp.png', // TODO: Thêm minh họa chào mừng
                height: 200,
              ),
              const SizedBox(height: 32),
              // Tiêu đề chào mừng
              const Text(
                'Chào mừng bạn đến với WordMaster!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Mô tả yêu cầu đăng nhập
              Text(
                'Vui lòng đăng nhập hoặc đăng ký để sử dụng đầy đủ các tính năng, theo dõi tiến độ học tập và đồng bộ dữ liệu cá nhân.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Nút đăng nhập
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Nút đăng ký
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tạo tài khoản mới',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: DecorationImage(
                          image: NetworkImage(
                            _currentUser!.avatar ??
                                'https://ui-avatars.com/api/?name=${_currentUser!.fullName}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser!.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser!.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Stats
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      value: '7',
                      label: 'Chuỗi ngày',
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.style_outlined,
                      value: '234',
                      label: 'Từ vựng',
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.school_outlined,
                      value: '12',
                      label: 'Bộ thẻ',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),

              // Profile Menu
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                onTap: () {
                  // TODO: Navigate to edit profile
                },
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                onTap: () {
                  // TODO: Navigate to notifications
                },
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Cài đặt',
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Trợ giúp & Hỗ trợ',
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                color: const Color(0xFFEF4444),
                onTap: () {
                  // TODO: Implement logout
                  setState(() {
                    _currentUser = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF1E293B),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
