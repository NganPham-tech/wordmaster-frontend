import 'package:flutter/material.dart';
import '../flashcard/flashcard_overview_screen.dart';
import '../dictation/dictation_list_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy data - sẽ thay thế bằng API call thực tế
  final Map<String, dynamic> _userProgress = {
    'todayLearned': 8,
    'dailyGoal': 20,
    'streak': 4,
    'totalPoints': 1200,
  };

  final List<Map<String, dynamic>> _quickActions = [
    {'icon': Icons.flash_on, 'label': 'Flashcard', 'badge': 0},
    {'icon': Icons.repeat, 'label': 'Ôn tập', 'badge': 5},
    {'icon': Icons.quiz, 'label': 'Quiz', 'badge': 0},
    {'icon': Icons.mic, 'label': 'Dictation', 'badge': 0},
    {'icon': Icons.record_voice_over, 'label': 'Shadowing', 'badge': 0},
    {'icon': Icons.menu_book, 'label': 'Grammar', 'badge': 2},
  ];

  final List<Map<String, dynamic>> _recommendedDecks = [
    {
      'id': 1,
      'title': 'TOEIC Essential 500',
      'thumbnail': null,
      'cardsCount': 500
    },
    {
      'id': 2,
      'title': 'Business English',
      'thumbnail': null,
      'cardsCount': 300
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildHeader(),
              const SizedBox(height: 16),
              
              // SEARCH BAR
              _buildSearchBar(),
              const SizedBox(height: 24),
              
              // PROGRESS CARD
              _buildProgressCard(),
              const SizedBox(height: 32),
              
              // QUICK ACTIONS
              _buildQuickActions(),
              const SizedBox(height: 32),
              
              // RECOMMENDED DECKS
              _buildRecommendedSection(),
              const SizedBox(height: 32),
              
              // RECENT ACTIVITY
              _buildRecentActivity(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Logo & App Name
        Row(
          children: [
            Image.asset(
              'images/Bannerapp.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WordMaster',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFd63384),
                  ),
                ),
                Text(
                  'Học từ vựng dễ — Nhớ lâu hơn mỗi ngày',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const Spacer(),
        
        // Notification & Avatar
        Row(
          children: [
            IconButton(
              icon: Badge(
                label: const Text('3'),
                child: Icon(Icons.notifications, color: Colors.grey[600]),
              ),
              onPressed: () {},
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFd63384),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm từ, chủ đề hoặc bài học...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _userProgress['todayLearned'] / _userProgress['dailyGoal'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFd63384), Color(0xFFa61e4d)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiến độ hôm nay',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${_userProgress['todayLearned']}/${_userProgress['dailyGoal']} từ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Streak: ${_userProgress['streak']} ngày',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                height: 8,
                width: MediaQuery.of(context).size.width * 0.7 * progress,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to review screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFd63384),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ôn tập ngay',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Học nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: _quickActions.length,
          itemBuilder: (context, index) {
            final action = _quickActions[index];
            return _buildActionTile(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              badge: action['badge'] as int,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionTile({required IconData icon, required String label, required int badge}) {
    return GestureDetector(
      onTap: () {
        // Handle navigation to each feature
        _handleFeatureNavigation(label);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text(badge.toString()),
              child: Icon(icon, size: 28, color: Color(0xFFd63384)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFeatureNavigation(String feature) {
    // Implement navigation logic for each feature
    switch (feature) {
      case 'Flashcard':
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const FlashcardOverviewScreen())
        );
        break;
      case 'Ôn tập':
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const FlashcardOverviewScreen())
        );
        break;
      case 'Quiz':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen()));
        break;
      case 'Dictation':
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const DictationListScreen())
        );
        break;
      case 'Shadowing':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ShadowingScreen()));
        break;
      case 'Grammar':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => GrammarScreen()));
        break;
    }
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gợi ý cho bạn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedDecks.length,
            itemBuilder: (context, index) {
              final deck = _recommendedDecks[index];
              return _buildDeckCard(deck);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeckCard(Map<String, dynamic> deck) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              'images/timo.jpg',
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${deck['cardsCount']} thẻ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildActivityItem('Bạn hoàn thành Quiz: Travel — 8/10'),
              _buildActivityItem('Học xong 15 từ trong "Business English"'),
              _buildActivityItem('Đạt streak 4 ngày liên tiếp'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String activity) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(0xFFd63384).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.check_circle, color: Color(0xFFd63384), size: 20),
      ),
      title: Text(
        activity,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Text(
        '2h trước',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
    );
  }


}