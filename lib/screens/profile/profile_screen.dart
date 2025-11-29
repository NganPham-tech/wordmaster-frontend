// lib/screens/profile/profile_screen.dart 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordmaster_dacn/data/models/profile_model.dart';
import 'package:wordmaster_dacn/screens/settings/settings_screen.dart';
import 'package:wordmaster_dacn/services/auth_service.dart';
import 'package:wordmaster_dacn/services/user_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService.instance;
  final _userService = UserService.instance;
  
  late TabController _tabController;
  
  // Data variables
  UserProfile? _userProfile;
  Map<String, dynamic>? _userStats;
  List<StudyStat> _weeklyStats = [];
  List<RecentActivity> _recentActivities = [];
  List<Map<String, dynamic>> _achievements = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!_authService.isLoggedIn.value) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _userService.getUserProfile(),
        _userService.getUserStats(),
        _userService.getWeeklyStats(),
        _userService.getRecentActivities(limit: 10),
        _userService.getAchievements(),
      ]);

      setState(() {
        _userProfile = results[0] as UserProfile?;
        _userStats = results[1] as Map<String, dynamic>?;
        _weeklyStats = results[2] as List<StudyStat>;
        _recentActivities = results[3] as List<RecentActivity>;
        _achievements = results[4] as List<Map<String, dynamic>>;
        
        // Nếu không load được profile từ API, tạo profile từ AuthService
        if (_userProfile == null) {
          _userProfile = UserProfile(
            id: _authService.userId.toString(),
            firstName: _authService.userName.split(' ').first,
            lastName: _authService.userName.split(' ').length > 1 
                ? _authService.userName.split(' ').last 
                : '',
            email: _authService.userEmail,
            phone: null,
            avatarUrl: _authService.userAvatar,
            joinDate: DateTime.now(),
            level: '1',
            currentStreak: 0,
            longestStreak: 0,
            totalPoints: 0,
            totalCardsLearned: 0,
            totalQuizzesCompleted: 0,
            averageAccuracy: 0.0,
            bio: null,
          );
        }
        
        // Update profile with stats
        if (_userStats != null) {
          _userProfile = UserProfile(
            id: _userProfile!.id,
            firstName: _userProfile!.firstName,
            lastName: _userProfile!.lastName,
            email: _userProfile!.email,
            phone: _userProfile!.phone,
            avatarUrl: _userProfile!.avatarUrl,
            joinDate: _userProfile!.joinDate,
            level: _userStats!['level']?.toString() ?? _userProfile!.level,
            currentStreak: _userStats!['currentStreak'] ?? 0,
            longestStreak: _userStats!['longestStreak'] ?? 0,
            totalPoints: _userStats!['totalPoints'] ?? 0,
            totalCardsLearned: _userStats!['totalCardsLearned'] ?? 0,
            totalQuizzesCompleted: _userStats!['totalQuizzesCompleted'] ?? 0,
            averageAccuracy: (_userStats!['averageAccuracy'] ?? 0.0).toDouble(),
            bio: _userProfile!.bio,
          );
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      
      // Vẫn tạo profile cơ bản từ AuthService để không bị lỗi
      setState(() {
        _userProfile = UserProfile(
          id: _authService.userId.toString(),
          firstName: _authService.userName.split(' ').first,
          lastName: _authService.userName.split(' ').length > 1 
              ? _authService.userName.split(' ').last 
              : '',
          email: _authService.userEmail,
          phone: null,
          avatarUrl: _authService.userAvatar,
          joinDate: DateTime.now(),
          level: '1',
          currentStreak: 0,
          longestStreak: 0,
          totalPoints: 0,
          totalCardsLearned: 0,
          totalQuizzesCompleted: 0,
          averageAccuracy: 0.0,
          bio: null,
        );
        _isLoading = false;
      });
    }
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

  Widget _buildAuthenticatedView() {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Luôn hiển thị UI ngay cả khi chưa có dữ liệu
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
                    backgroundImage: _userProfile?.avatarUrl != null
                        ? NetworkImage(_userProfile!.avatarUrl!)
                        : null,
                    child: _userProfile?.avatarUrl == null
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
                        _userProfile?.fullName ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userProfile?.email ?? '',
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
              'Cấp ${_userProfile?.level ?? 1}',
              'Level',
              const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '${_userProfile?.currentStreak ?? 0} ngày',
              'Streak',
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '${_userProfile?.totalPoints ?? 0}',
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
    // Check if user has any learning data
    final hasData = (_userProfile?.totalCardsLearned ?? 0) > 0 ||
        (_userProfile?.totalQuizzesCompleted ?? 0) > 0 ||
        _weeklyStats.isNotEmpty ||
        _achievements.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!hasData) ...[
              // Empty state for new users
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rocket_launch_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bắt đầu hành trình học tập!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chào mừng bạn đến với WordMaster!\nHãy bắt đầu học để xem thống kê và tiến độ của bạn.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.style_outlined,
                            title: 'Flashcards',
                            color: const Color(0xFF6366F1),
                            onTap: () {
                              DefaultTabController.of(context).animateTo(1);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.headphones_outlined,
                            title: 'Dictation',
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              DefaultTabController.of(context).animateTo(2);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.record_voice_over_outlined,
                            title: 'Shadowing',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              // Navigate to shadowing
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.quiz_outlined,
                            title: 'Quiz',
                            color: const Color(0xFF10B981),
                            onTap: () {
                              // Navigate to quiz
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Original stats display
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
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    if (_recentActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: 48,
                  color: const Color(0xFF6366F1).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chưa có hoạt động nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Bắt đầu học để xem lịch sử hoạt động của bạn tại đây',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to home tab
                  DefaultTabController.of(context).animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'Bắt đầu học ngay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _recentActivities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildActivityItem(_recentActivities[index]);
        },
      ),
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
                  value: (_userProfile?.totalCardsLearned ?? 0).toString(),
                  label: 'Thẻ đã học',
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.quiz_outlined,
                  value: (_userProfile?.totalQuizzesCompleted ?? 0).toString(),
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
                  value: '${_userProfile?.averageAccuracy.toStringAsFixed(1) ?? 0}%',
                  label: 'Độ chính xác',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  value: (_userProfile?.longestStreak ?? 0).toString(),
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
    if (_weeklyStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu học tập',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu học để xem tiến độ của bạn!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to home tab
                DefaultTabController.of(context).animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Bắt đầu học',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

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
                        _getDayName(stat.date.weekday - 1),
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

  String _getDayName(int weekday) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return days[weekday % 7];
  }

  Widget _buildAchievementProgress() {
    if (_achievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có thành tích',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hoàn thành các nhiệm vụ để nhận huy hiệu!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
        children: _achievements.map((achievement) {
          final isCompleted = achievement['completed'] as bool;
          final progress = (achievement['progress'] as num).toDouble();
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

  // Keep the _buildGuestView() method as is from your original code
  Widget _buildGuestView() {
    // ... (giữ nguyên code gốc)
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đăng nhập để trải nghiệm đầy đủ',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.to(() => const LoginScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}