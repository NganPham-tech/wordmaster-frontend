// lib/screens/profile/profile_screen.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordmaster_dacn/data/models/profile_model.dart';
import 'package:wordmaster_dacn/screens/settings/settings_screen.dart';
import 'package:wordmaster_dacn/services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService.instance;
  late UserProfile _userProfile;
  late List<StudyStat> _weeklyStats;
  late List<RecentActivity> _recentActivities;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    _userProfile = UserProfile(
      id: '1',
      firstName: 'Ngân',
      lastName: 'Ái',
      email: 'ngan.ai@example.com',
      phone: '+84 123 456 789',
      avatarUrl: null,
      joinDate: DateTime(2024, 1, 15),
      level: '12',
      currentStreak: 7,
      longestStreak: 15,
      totalPoints: 1250,
      totalCardsLearned: 234,
      totalQuizzesCompleted: 45,
      averageAccuracy: 78.5,
      bio: 'Yêu thích học tiếng Anh qua phương pháp trực quan và tương tác',
    );

    _weeklyStats = [
      StudyStat(
        date: DateTime.now().subtract(const Duration(days: 6)),
        minutesStudied: 25,
        cardsLearned: 15,
        quizzesCompleted: 2,
      ),
      StudyStat(
        date: DateTime.now().subtract(const Duration(days: 5)),
        minutesStudied: 40,
        cardsLearned: 22,
        quizzesCompleted: 3,
      ),
      StudyStat(
        date: DateTime.now().subtract(const Duration(days: 4)),
        minutesStudied: 35,
        cardsLearned: 18,
        quizzesCompleted: 1,
      ),
      StudyStat(
        date: DateTime.now().subtract(const Duration(days: 3)),
        minutesStudied: 50,
        cardsLearned: 30,
        quizzesCompleted: 4,
      ),
      StudyStat(
        date: DateTime.now().subtract(const Duration(days: 2)),
        minutesStudied: 20,
        cardsLearned: 12,
        quizzesCompleted: 2,
      ),
      StudyStat(
        date: DateTime.now().subtract(const Duration(days: 1)),
        minutesStudied: 45,
        cardsLearned: 25,
        quizzesCompleted: 3,
      ),
      StudyStat(
        date: DateTime.now(),
        minutesStudied: 30,
        cardsLearned: 20,
        quizzesCompleted: 2,
      ),
    ];

    _recentActivities = [
      RecentActivity(
        id: '1',
        type: 'flashcard',
        title: 'Học thẻ mới',
        description: 'Đã học 15 thẻ từ vựng mới',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        deckName: 'Daily Conversations',
      ),
      RecentActivity(
        id: '2',
        type: 'quiz',
        title: 'Hoàn thành quiz',
        description: 'Kết quả: 8/10 câu đúng',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        score: '80%',
        deckName: 'Grammar Test',
      ),
      RecentActivity(
        id: '3',
        type: 'dictation',
        title: 'Luyện nghe chính tả',
        description: 'Độ chính xác: 85%',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        score: '85%',
      ),
      RecentActivity(
        id: '4',
        type: 'shadowing',
        title: 'Luyện nói shadowing',
        description: 'Điểm phát âm: 7.5/10',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        score: '7.5',
      ),
      RecentActivity(
        id: '5',
        type: 'flashcard',
        title: 'Ôn tập thẻ',
        description: 'Đã ôn tập 25 thẻ đến hạn',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        deckName: 'Business English',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_authService.isLoggedIn.value) {
        return _buildGuestView();
      }
      return _buildAuthenticatedView();
    });
  }

  // Giao diện Duolingo-style khi chưa đăng nhập
  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header với gradient giống Duolingo
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF58CC02),
                    const Color(0xFF58CC02).withOpacity(0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  _buildBackgroundPattern(),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Owl mascot (thay thế bằng icon của bạn)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 40,
                            color: Color(0xFF58CC02),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'WordMaster',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Học tiếng Anh thông minh',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Benefits section
                    _buildBenefitItem(
                      icon: Icons.trending_up,
                      title: 'Theo dõi tiến độ học tập',
                      subtitle: 'Xem biểu đồ và thống kê chi tiết',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      icon: Icons.emoji_events,
                      title: 'Thành tích và huy hiệu',
                      subtitle: 'Nhận phần thưởng khi hoàn thành mục tiêu',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      icon: Icons.sync,
                      title: 'Đồng bộ đa thiết bị',
                      subtitle: 'Học mọi lúc, mọi nơi',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      icon: Icons.leaderboard,
                      title: 'Bảng xếp hạng',
                      subtitle: 'So tài với bạn bè và cộng đồng',
                    ),

                    const SizedBox(height: 40),

                    // CTA Buttons
                    Column(
                      children: [
                        // Continue with Google
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () => _handleGoogleLogin(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E293B),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.g_mobiledata,
                                      size: 24,
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Tiếp tục với Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Continue with Facebook
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () => _handleFacebookLogin(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E293B),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/facebook.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.facebook, size: 24);
                                  },
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Tiếp tục với Facebook',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'hoặc',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => const LoginScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF58CC02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Tạo tài khoản mới',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login Link
                        TextButton(
                          onPressed: () {
                            Get.to(() => const LoginScreen());
                          },
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              children: [
                                TextSpan(text: 'Đã có tài khoản? '),
                                TextSpan(
                                  text: 'Đăng nhập',
                                  style: TextStyle(
                                    color: Color(0xFF58CC02),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Footer text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Bằng việc tiếp tục, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo mật của chúng tôi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned(
      right: -50,
      top: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF58CC02), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    final success = await _authService.loginWithGoogle();
    if (success) {
      Get.snackbar(
        'Thành công',
        'Đăng nhập bằng Google thành công!',
        backgroundColor: const Color(0xFF58CC02),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Đăng nhập bằng Google thất bại',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleFacebookLogin() async {
    final success = await _authService.loginWithFacebook();
    if (success) {
      Get.snackbar(
        'Thành công',
        'Đăng nhập bằng Facebook thành công!',
        backgroundColor: const Color(0xFF58CC02),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Đăng nhập bằng Facebook thất bại',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Các method _buildAuthenticatedView() và các method khác giữ nguyên...
  Widget _buildAuthenticatedView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildFixedHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildStatsTab(), _buildActivityTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: _authService.userAvatar != null
                        ? NetworkImage(_authService.userAvatar!)
                        : null,
                    child: _authService.userAvatar == null
                        ? const Icon(
                            Icons.person,
                            size: 24,
                            color: Color(0xFF6366F1),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authService.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _authService.userEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _openSettings,
                ),
              ],
            ),
          ),
          _buildStatsCards(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Cấp ${_userProfile.level}',
              'Level',
              const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '${_userProfile.currentStreak} ngày',
              'Streak',
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '${_userProfile.totalPoints}',
              'Điểm',
              const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 2,
        tabs: const [
          Tab(text: 'Thống kê'),
          Tab(text: 'Hoạt động'),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionTitle('Thống kê học tập'),
          const SizedBox(height: 16),
          _buildLearningStats(),
          const SizedBox(height: 24),
          _buildSectionTitle('Tiến độ 7 ngày'),
          const SizedBox(height: 16),
          _buildWeeklyChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('Thành tích'),
          const SizedBox(height: 16),
          _buildAchievementProgress(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _recentActivities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildActivityItem(_recentActivities[index]);
      },
    );
  }

  Widget _buildLearningStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.style_outlined,
                  value: _userProfile.totalCardsLearned.toString(),
                  label: 'Thẻ đã học',
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.quiz_outlined,
                  value: _userProfile.totalQuizzesCompleted.toString(),
                  label: 'Quiz hoàn thành',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timeline_outlined,
                  value: '${_userProfile.averageAccuracy}%',
                  label: 'Độ chính xác',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  value: _userProfile.longestStreak.toString(),
                  label: 'Streak cao nhất',
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final maxMinutes = _weeklyStats
        .map((e) => e.minutesStudied)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyStats.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;
                final height = maxMinutes > 0
                    ? (stat.minutesStudied / maxMinutes) * 60
                    : 0.0;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${stat.minutesStudied}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            height: height,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDayName(index),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int index) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return days[index];
  }

  Widget _buildAchievementProgress() {
    final achievements = [
      {
        'name': 'Học 100 thẻ',
        'progress': 234.0,
        'target': 100,
        'completed': true,
      },
      {
        'name': 'Streak 7 ngày',
        'progress': 7.0,
        'target': 7,
        'completed': true,
      },
      {
        'name': 'Hoàn thành 50 quiz',
        'progress': 45.0,
        'target': 50,
        'completed': false,
      },
      {
        'name': 'Độ chính xác 80%',
        'progress': 78.5,
        'target': 80,
        'completed': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: achievements.map((achievement) {
          final isCompleted = achievement['completed'] as bool;
          final progress = achievement['progress'] as double;
          final target = achievement['target'] as int;
          final percentage = isCompleted ? 1.0 : progress / target;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        achievement['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCompleted
                          ? 'Hoàn thành'
                          : '${progress.toInt()}/$target',
                      style: TextStyle(
                        fontSize: 11,
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage > 1.0 ? 1.0 : percentage,
                    minHeight: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (activity.deckName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Bộ: ${activity.deckName}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getTimeAgo(activity.timestamp),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
              if (activity.score != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(activity.score!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    activity.score!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'flashcard':
        return const Color(0xFF6366F1);
      case 'quiz':
        return const Color(0xFF10B981);
      case 'dictation':
        return const Color(0xFFF59E0B);
      case 'shadowing':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'flashcard':
        return Icons.style_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'dictation':
        return Icons.headphones_outlined;
      case 'shadowing':
        return Icons.record_voice_over_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  Color _getScoreColor(String score) {
    if (score.contains('%')) {
      final percent = double.tryParse(score.replaceAll('%', '')) ?? 0;
      if (percent >= 80) return const Color(0xFF10B981);
      if (percent >= 60) return const Color(0xFFF59E0B);
      return const Color(0xFFEF4444);
    } else {
      final numericScore = double.tryParse(score) ?? 0;
      if (numericScore >= 8) return const Color(0xFF10B981);
      if (numericScore >= 6) return const Color(0xFFF59E0B);
      return const Color(0xFFEF4444);
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
    return '${timestamp.day}/${timestamp.month}';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
