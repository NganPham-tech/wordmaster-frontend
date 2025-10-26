import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/progress_api.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  UserProgress? _userProgress;
  List<DailyProgress> _weeklyProgress = [];
  List<Activity> _recentActivities = [];
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final progress = await ProgressAPI.getUserProgress();
      final weekly = await ProgressAPI.getWeeklyProgress();
      final activities = await ProgressAPI.getRecentActivities();
      final achievements = await ProgressAPI.getAchievements();

      if (mounted) {
        setState(() {
          _userProgress = progress;
          _weeklyProgress = weekly;
          _recentActivities = activities;
          _achievements = achievements;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print('Error loading progress data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Không thể tải dữ liệu tiến độ';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
            : _userProgress == null
            ? const Center(child: Text('Không có dữ liệu'))
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 32, // Tăng padding bottom để tránh overflow
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 20), // Giảm từ 24
                      // Summary Cards
                      _buildSummaryCards(),
                      const SizedBox(height: 24), // Giảm từ 32
                      // Progress Chart
                      _buildProgressChart(),
                      const SizedBox(height: 24), // Giảm từ 32
                      // Recent Activities
                      _buildRecentActivities(),
                      const SizedBox(height: 24), // Giảm từ 32
                      // Achievements
                      _buildAchievements(),
                      const SizedBox(
                        height: 20,
                      ), // Tăng từ 16 để có không gian cuối
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.analytics, size: 28, color: Colors.blueAccent),
        const SizedBox(width: 12),
        const Text(
          'Tiến độ học tập',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                'Cấp ${_userProgress?.level ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0, // Giảm tỷ lệ để tăng chiều cao card
      ),
      children: [
        _buildSummaryCard(
          icon: Icons.flash_on,
          title: 'Từ đã học',
          value: (_userProgress?.totalLearned ?? 0).toString(),
          subtitle: '${_userProgress?.totalMastered ?? 0} đã thuộc',
          color: Colors.blue,
        ),
        _buildSummaryCard(
          icon: Icons.local_fire_department,
          title: 'Streak',
          value: '${_userProgress?.currentStreak ?? 0} ngày',
          subtitle: 'Cao nhất: ${_userProgress?.bestStreak ?? 0}',
          color: Colors.orange,
        ),
        _buildSummaryCard(
          icon: Icons.psychology,
          title: 'Tỷ lệ nhớ',
          value: '${_userProgress?.memoryRate ?? 0}%',
          subtitle: 'Hiệu quả học tập',
          color: Colors.green,
        ),
        _buildSummaryCard(
          icon: Icons.quiz,
          title: 'Bài Quiz',
          value: (_userProgress?.totalQuizzes ?? 0).toString(),
          subtitle: '${_userProgress?.perfectQuizCount ?? 0} bài perfect',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18, // Giảm từ 20 xuống 18
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // Giảm từ 4 xuống 2
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12, // Giảm từ 14 xuống 12
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10, // Giảm từ 12 xuống 10
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến độ 7 ngày qua',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 180, // Giảm từ 200 để tiết kiệm không gian
              width: double.infinity,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      _weeklyProgress
                          .map((e) => e.cardsLearned.toDouble())
                          .reduce((a, b) => a > b ? a : b) +
                      5,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = _weeklyProgress[groupIndex];
                        return BarTooltipItem(
                          '${day.cardsLearned} thẻ\n${day.quizzesCompleted} quiz',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = _weeklyProgress[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _weeklyProgress.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: day.cardsLearned.toDouble(),
                          color: Colors.blueAccent,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 12, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text('Số thẻ học mỗi ngày', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _recentActivities
                  .take(5) // Chỉ hiển thị tối đa 5 activity để tránh overflow
                  .map((activity) => _buildActivityItem(activity))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity.icon, size: 20, color: activity.color),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            activity.timeAgo,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Huy hiệu thành tích',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              return _buildAchievementCard(_achievements[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: achievement.isUnlocked ? 4 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  achievement.icon,
                  size: 24,
                  color: achievement.isUnlocked
                      ? achievement.color
                      : Colors.grey,
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      achievement.name,
                      style: TextStyle(
                        fontSize: 11, // Giảm từ 12 xuống 11
                        fontWeight: FontWeight.bold,
                        color: achievement.isUnlocked
                            ? Colors.black87
                            : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (achievement.isUnlocked) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '+${achievement.points}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'Chưa mở khóa',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
