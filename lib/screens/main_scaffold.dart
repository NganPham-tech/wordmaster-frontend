import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home/home_screen.dart';
import 'flashcard/flashcard_index_screen.dart';
import 'quiz/quiz_index_screen.dart';

// Main scaffold với Bottom Navigation Bar
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  // Badge counts
  final int _studyDueCount = 15; // Số thẻ đến hạn
  final int _practiceChallenges = 3; // Số challenges mới

  final List<Widget> _screens = [
    const HomeScreen(),
    const FlashcardIndexScreen(),
    const QuizIndexScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) {
      // Re-tap: scroll to top hoặc action đặc biệt
      _handleReTap(index);
    } else {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward(from: 0);
    }
  }

  void _handleReTap(int index) {
    HapticFeedback.mediumImpact();
    // TODO: Implement scroll to top hoặc show modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getRetapMessage(index)),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getRetapMessage(int index) {
    switch (index) {
      case 0:
        return 'Cuộn lên đầu trang';
      case 1:
        return 'Bắt đầu ôn tập ngay';
      case 2:
        return 'Chọn bài tập nhanh';
      case 3:
        return 'Xem thành tích';
      default:
        return '';
    }
  }

  void _handleLongPress(int index) {
    HapticFeedback.mediumImpact();
    if (index == 1) {
      _showStudyShortcuts();
    } else if (index == 2) {
      _showPracticeHub();
    }
  }

  void _showStudyShortcuts() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Study Shortcuts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildShortcutTile(
              icon: Icons.history,
              title: 'Start Review (Due)',
              subtitle: '$_studyDueCount thẻ đến hạn',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to review
              },
            ),
            _buildShortcutTile(
              icon: Icons.shuffle,
              title: 'Start Random 10',
              subtitle: 'Học ngẫu nhiên 10 thẻ',
              color: const Color(0xFF6366F1),
              onTap: () {
                Navigator.pop(context);
                // TODO: Start random
              },
            ),
            _buildShortcutTile(
              icon: Icons.add_circle_outline,
              title: 'Create Card',
              subtitle: 'Tạo flashcard mới',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.pop(context);
                // TODO: Create card
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showPracticeHub() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Practice Hub',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPracticeCard(
                    icon: Icons.quiz_outlined,
                    title: 'Quiz',
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPracticeCard(
                    icon: Icons.headphones_outlined,
                    title: 'Dictation',
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPracticeCard(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Shadowing',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPracticeCard(
                    icon: Icons.mic_outlined,
                    title: 'Speaking',
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildPracticeCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        // TODO: Navigate to practice
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.auto_stories_outlined,
              activeIcon: Icons.auto_stories,
              label: 'Study',
              index: 1,
              badgeCount: _studyDueCount,
            ),
            _buildNavItem(
              icon: Icons.school_outlined,
              activeIcon: Icons.school,
              label: 'Practice',
              index: 2,
              badgeCount: _practiceChallenges,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    int? badgeCount,
  }) {
    final isActive = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: GestureDetector(
        onLongPress: () => _handleLongPress(index),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6366F1).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isActive ? activeIcon : icon, size: 24),
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      label: label,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Profile Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stats • Settings • History',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
