import 'package:flutter/material.dart';
import '/data/models/shadowing_model.dart';
import 'shadowing_player_screen.dart';

class ShadowingListScreen extends StatefulWidget {
  const ShadowingListScreen({super.key});

  @override
  State<ShadowingListScreen> createState() => _ShadowingListScreenState();
}

class _ShadowingListScreenState extends State<ShadowingListScreen> {
  final List<ShadowingContent> _contents = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedDifficulty = 'all';
  String _selectedAccent = 'all';

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  void _loadContents() {
    // Mock data với thumbnail và sourceUrl an toàn
    _contents.addAll([
      ShadowingContent(
        id: '1',
        title: 'Daily Conversation - Basic',
        description: 'Practice common daily conversations with clear pronunciation',
        thumbnail: null, // Không dùng thumbnail thật
        sourceUrl: 'https://example.com/audio1.mp3', // URL an toàn
        sourceType: SourceType.audio,
        transcript: 'Hello, how are you? I\'m doing great, thank you. What about you?',
        duration: 180,
        difficulty: Difficulty.beginner,
        accentType: 'American',
        speechRate: SpeechRate.slow,
        tags: ['conversation', 'basic', 'daily'],
        segments: _generateSegments(5),
        createdAt: DateTime.now(),
      ),
      ShadowingContent(
        id: '2',
        title: 'Business Meeting',
        description: 'Professional business meeting dialogues',
        thumbnail: null,
        sourceUrl: 'https://example.com/audio2.mp3',
        sourceType: SourceType.audio,
        transcript: 'Let\'s begin the meeting. First, I\'d like to discuss the quarterly results.',
        duration: 300,
        difficulty: Difficulty.intermediate,
        accentType: 'British',
        speechRate: SpeechRate.normal,
        tags: ['business', 'meeting', 'professional'],
        segments: _generateSegments(8),
        createdAt: DateTime.now(),
      ),
      ShadowingContent(
        id: '3',
        title: 'TED Talk Excerpt',
        description: 'Inspiring talk about innovation and technology',
        thumbnail: null,
        sourceUrl: 'https://youtube.com/watch?v=abc123',
        sourceType: SourceType.youtube,
        transcript: 'The future belongs to those who believe in the beauty of their dreams.',
        duration: 420,
        difficulty: Difficulty.advanced,
        accentType: 'American',
        speechRate: SpeechRate.fast,
        tags: ['TED', 'inspiration', 'technology'],
        segments: _generateSegments(12),
        createdAt: DateTime.now(),
      ),
    ]);
  }

  List<Segment> _generateSegments(int count) {
    final segments = [
      'Hello, how are you doing today?',
      'I\'m doing great, thank you for asking.',
      'What have you been working on recently?',
      'I\'ve been learning English with this app.',
      'That sounds like a wonderful idea!',
      'Practice makes perfect, as they say.',
      'Would you like to practice together sometime?',
      'That would be very helpful, thank you!',
      'Let\'s meet tomorrow at the same time.',
      'Looking forward to our practice session.',
      'Remember to speak clearly and slowly.',
      'Pronunciation is key to good communication.'
    ];
    
    return List.generate(count, (index) => Segment(
      id: 'seg_$index',
      index: index,
      text: segments[index % segments.length],
      startTime: index * 5000,
      endTime: (index + 1) * 5000,
    ));
  }

  List<ShadowingContent> get _filteredContents {
    return _contents.where((content) {
      final matchesSearch = _searchController.text.isEmpty ||
          content.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          content.description.toLowerCase().contains(_searchController.text.toLowerCase());
      
      final matchesDifficulty = _selectedDifficulty == 'all' ||
          content.difficulty.toString().split('.').last == _selectedDifficulty;
      
      final matchesAccent = _selectedAccent == 'all' ||
          content.accentType.toLowerCase() == _selectedAccent.toLowerCase();
      
      return matchesSearch && matchesDifficulty && matchesAccent;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shadowing Practice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              _showPracticeHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters section
          _buildSearchFilters(),
          
          // Content list
          Expanded(
            child: _filteredContents.isEmpty
                ? _buildEmptyState()
                : _buildContentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bài luyện...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          
          const SizedBox(height: 12),
          
          // Filter row
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  value: _selectedDifficulty,
                  items: _getDifficultyItems(),
                  label: 'Mức độ',
                  onChanged: (value) => setState(() => _selectedDifficulty = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  value: _selectedAccent,
                  items: _getAccentItems(),
                  label: 'Giọng',
                  onChanged: (value) => setState(() => _selectedAccent = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  List<DropdownMenuItem<String>> _getDifficultyItems() {
    return [
      const DropdownMenuItem(value: 'all', child: Text('Tất cả mức độ')),
      ...Difficulty.values.map((e) {
        final difficulty = e.toString().split('.').last;
        return DropdownMenuItem(
          value: difficulty,
          child: Text(_getDifficultyText(difficulty)),
        );
      }).toList(),
    ];
  }

  List<DropdownMenuItem<String>> _getAccentItems() {
    return [
      const DropdownMenuItem(value: 'all', child: Text('Tất cả giọng')),
      const DropdownMenuItem(value: 'American', child: Text('American')),
      const DropdownMenuItem(value: 'British', child: Text('British')),
      const DropdownMenuItem(value: 'Australian', child: Text('Australian')),
    ];
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner': return 'Cơ bản';
      case 'intermediate': return 'Trung cấp';
      case 'advanced': return 'Nâng cao';
      default: return difficulty;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy bài luyện nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredContents.length,
      itemBuilder: (context, index) {
        return _buildContentCard(_filteredContents[index]);
      },
    );
  }

  Widget _buildContentCard(ShadowingContent content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _navigateToPlayer(content);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row với icon và thông tin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon placeholder thay cho thumbnail
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.record_voice_over,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Content info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          content.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Tags và metadata
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildInfoChip(
                    _getDifficultyText(content.difficulty.toString().split('.').last),
                    _getDifficultyColor(content.difficulty),
                  ),
                  _buildInfoChip(content.accentType, Colors.blue),
                  _buildInfoChip('${content.duration ~/ 60} phút', Colors.green),
                  _buildInfoChip('${content.segments.length} câu', Colors.orange),
                  ...content.tags.take(2).map((tag) => _buildInfoChip(tag, Colors.purple)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Footer với action button
              Row(
                children: [
                  // View count (placeholder)
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${content.viewCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Start practice button
                  ElevatedButton.icon(
                    onPressed: () => _navigateToPlayer(content),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text(
                      'Bắt đầu luyện tập',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return const Color(0xFF10B981); // Green
      case Difficulty.intermediate:
        return const Color(0xFFF59E0B); // Orange
      case Difficulty.advanced:
        return const Color(0xFFEF4444); // Red
    }
  }

  void _navigateToPlayer(ShadowingContent content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShadowingPlayerScreen(content: content),
      ),
    );
  }

  void _showPracticeHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lịch sử luyện tập'),
        content: const Text('Tính năng đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}