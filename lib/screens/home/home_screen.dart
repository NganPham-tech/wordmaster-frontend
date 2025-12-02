// lib/screens/home/home_screen.dart 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordmaster_dacn/screens/shadowing/shadowing_list_screen.dart';
import 'package:wordmaster_dacn/services/auth_service.dart';
import 'package:wordmaster_dacn/services/user_service.dart';
import '/screens/dictation/dictation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService.instance;
  final _userService = UserService.instance;

  late AnimationController _animationController;

  // Data variables
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!_authService.isLoggedIn.value) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final stats = await _userService.getUserStats();
      setState(() {
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Getters for data with fallback to AuthService or 0
  String get userName => _authService.userName.split(' ').first;
  int get currentStreak => _userStats?['currentStreak'] ?? _authService.userStreak;
  int get totalCardsLearned => _userStats?['totalCardsLearned'] ?? 0;
  int get totalGrammarCards => _userStats?['totalGrammarCards'] ?? 0;
  int get totalQuizzes => _userStats?['totalQuizzesCompleted'] ?? 0;
  int get totalDictation => _userStats?['totalDictationResults'] ?? 0;
  int get totalShadowing => _userStats?['totalShadowingResults'] ?? 0;
  
  // Daily goal - can be fetched from API or calculated
  int get targetMinutes => 20;
  int get completedMinutes => 12; // TODO: Get from daily activity
  int get targetCards => 10;
  int get completedCards => 6; // TODO: Get from daily activity
  double get dailyProgress => (completedMinutes / targetMinutes).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Hero Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildHeroCard(),
                ),
              ),

              // Quick Actions (2x2 Grid)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildQuickActions(),
                ),
              ),

              // Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildQuickStats(),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sẵn sàng học hôm nay chưa?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF97316)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$currentStreak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mục tiêu hôm nay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedMinutes/$targetMinutes phút • $completedCards/$targetCards thẻ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: dailyProgress,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text(
                      '${(dailyProgress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: dailyProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to study section
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Bắt đầu học',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'id': 'flashcards',
        'title': 'Flashcard',
        'subtitle': 'Học từ vựng',
        'icon': Icons.style_outlined,
        'color': const Color(0xFF6366F1),
        'pendingItems': 8, // TODO: Get from API
      },
      {
        'id': 'grammar',
        'title': 'Grammar',
        'subtitle': 'Ngữ pháp',
        'icon': Icons.school_outlined,
        'color': const Color(0xFF8B5CF6),
        'pendingItems': 3,
      },
      {
        'id': 'dictation',
        'title': 'Dictation',
        'subtitle': 'Luyện nghe',
        'icon': Icons.headphones_outlined,
        'color': const Color(0xFF10B981),
        'pendingItems': totalDictation,
      },
      {
        'id': 'shadowing',
        'title': 'Shadowing',
        'subtitle': 'Luyện nói',
        'icon': Icons.record_voice_over_outlined,
        'color': const Color(0xFFF59E0B),
        'pendingItems': totalShadowing,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương pháp học',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        // Grid 2x2
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(actions[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(actions[1]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(actions[2]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(actions[3]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          switch (action['id']) {
            case 'dictation':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DictationScreen(),
                ),
              );
              break;
            case 'flashcards':
              Get.snackbar(
                'Thông báo',
                'Tính năng Flashcard đang được phát triển',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF6366F1),
                colorText: Colors.white,
              );
              break;
            case 'grammar':
              Get.snackbar(
                'Thông báo',
                'Tính năng Grammar đang được phát triển',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF8B5CF6),
                colorText: Colors.white,
              );
              break;
            case 'shadowing':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShadowingListScreen(),
                ),
              );
              break;
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (action['pendingItems'] > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        action['pendingItems'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                action['title'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                action['subtitle'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {
        'value': totalCardsLearned.toString(),
        'label': 'Từ vựng',
        'icon': Icons.style_outlined,
        'color': const Color(0xFF6366F1)
      },
      {
        'value': totalGrammarCards.toString(),
        'label': 'Ngữ pháp',
        'icon': Icons.school_outlined,
        'color': const Color(0xFF8B5CF6)
      },
      {
        'value': currentStreak.toString(),
        'label': 'Chuỗi ngày',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFEF4444)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thống kê',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to profile tab
                DefaultTabController.of(context)?.animateTo(3);
              },
              child: const Text(
                'Xem chi tiết',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < stats.length - 1 ? 12 : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}