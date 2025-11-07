// lib/screens/dictation/dictation_screen.dart
//D:\DemoDACN\wordmaster_dacn\lib\screens\dictation\dictation_screen.dart
import 'package:flutter/material.dart';
import '/data/models/dictation_model.dart';
import 'dictation_player_screen.dart';

class DictationScreen extends StatefulWidget {
  const DictationScreen({super.key});

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DictationContent> _allContent = [];
  List<DictationContent> _filteredContent = [];
  String _selectedDifficulty = 'All';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadDictationContent();
    _searchController.addListener(_filterContent);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDictationContent() {
    // Mock data - sau này sẽ load từ API
    _allContent = [
      DictationContent(
        id: '1',
        title: 'Daily Conversation at Coffee Shop',
        description: 'Practice listening to everyday conversations',
        sourceType: 'YouTube',
        sourceURL: 'https://www.youtube.com/watch?v=example1',
        thumbnail: 'https://img.youtube.com/vi/example1/0.jpg',
        transcript: 'Hello, what can I get for you today? I\'d like a cappuccino please...',
        duration: 92,
        difficulty: 'Beginner',
        accentType: 'US',
        tags: ['daily', 'conversation', 'coffee'],
        viewCount: 245,
        createdAt: DateTime.now(),
      ),
      DictationContent(
        id: '2',
        title: 'Business Meeting Discussions',
        description: 'Learn professional English vocabulary',
        sourceType: 'Audio',
        sourceURL: 'audio/business_meeting.mp3',
        transcript: 'Let\'s discuss the quarterly report...',
        duration: 180,
        difficulty: 'Intermediate',
        accentType: 'UK',
        tags: ['business', 'professional', 'meeting'],
        viewCount: 189,
        createdAt: DateTime.now(),
      ),
      DictationContent(
        id: '3',
        title: 'Travel English: At the Airport',
        description: 'Essential phrases for traveling',
        sourceType: 'YouTube',
        sourceURL: 'https://www.youtube.com/watch?v=example2',
        thumbnail: 'https://img.youtube.com/vi/example2/0.jpg',
        transcript: 'Where is your final destination?...',
        duration: 120,
        difficulty: 'Beginner',
        accentType: 'US',
        tags: ['travel', 'airport', 'tourism'],
        viewCount: 567,
        createdAt: DateTime.now(),
      ),
      DictationContent(
        id: '4',
        title: 'Technology News Report',
        description: 'Stay updated with tech vocabulary',
        sourceType: 'Video',
        sourceURL: 'video/tech_news.mp4',
        transcript: 'The latest innovation in artificial intelligence...',
        duration: 240,
        difficulty: 'Advanced',
        accentType: 'Australian',
        tags: ['technology', 'news', 'AI'],
        viewCount: 134,
        createdAt: DateTime.now(),
      ),
    ];
    _filteredContent = List.from(_allContent);
  }

  void _filterContent() {
    setState(() {
      _filteredContent = _allContent.where((content) {
        final matchesSearch = content.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            content.description
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesDifficulty = _selectedDifficulty == 'All' ||
            content.difficulty == _selectedDifficulty;

        final matchesCategory = _selectedCategory == 'All' ||
            content.tags.contains(_selectedCategory.toLowerCase());

        return matchesSearch && matchesDifficulty && matchesCategory;
      }).toList();
    });
  }

  void _showAddContentDialog() {
    final TextEditingController linkController = TextEditingController();
    String selectedLevel = 'Beginner';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Dictation Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: 'Paste audio or video link',
                  hintText: 'YouTube, MP3, or video URL',
                  prefixIcon: const Icon(Icons.link, color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: InputDecoration(
                  labelText: 'Language Level',
                  prefixIcon: const Icon(Icons.signal_cellular_alt, color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Beginner', 'Intermediate', 'Advanced']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedLevel = value ?? 'Beginner';
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Process the link and add to content
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Content added successfully!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Add & Start',
                      style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Dictation Practice',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Text('🎧', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: _showAddContentDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search lessons or paste link...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All Levels',
                        isSelected: _selectedDifficulty == 'All',
                        onSelected: () {
                          setState(() {
                            _selectedDifficulty = 'All';
                            _filterContent();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Beginner',
                        isSelected: _selectedDifficulty == 'Beginner',
                        color: const Color(0xFF10B981),
                        onSelected: () {
                          setState(() {
                            _selectedDifficulty = 'Beginner';
                            _filterContent();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Intermediate',
                        isSelected: _selectedDifficulty == 'Intermediate',
                        color: const Color(0xFFF59E0B),
                        onSelected: () {
                          setState(() {
                            _selectedDifficulty = 'Intermediate';
                            _filterContent();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Advanced',
                        isSelected: _selectedDifficulty == 'Advanced',
                        color: const Color(0xFFEF4444),
                        onSelected: () {
                          setState(() {
                            _selectedDifficulty = 'Advanced';
                            _filterContent();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content List
          Expanded(
            child: _filteredContent.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.headphones_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No content found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredContent.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDictationCard(_filteredContent[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color color = const Color(0xFF6366F1),
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDictationCard(DictationContent content) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DictationPlayerScreen(content: content),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail
                Container(
                  width: 90,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getDifficultyColor(content.difficulty).withOpacity(0.8),
                        _getDifficultyColor(content.difficulty),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: content.thumbnail != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              content.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultThumbnail(content),
                            ),
                          )
                        : _buildDefaultThumbnail(content),
                  ),
                ),
                
                // Content Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(content.difficulty)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                content.difficulty,
                                style: TextStyle(
                                  color: _getDifficultyColor(content.difficulty),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  content.durationFormatted,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            if (content.accentType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  content.accentType!,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Start Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail(DictationContent content) {
    IconData icon;
    switch (content.sourceType) {
      case 'YouTube':
        icon = Icons.play_circle_filled;
        break;
      case 'Audio':
        icon = Icons.headphones;
        break;
      default:
        icon = Icons.videocam;
    }

    return Center(
      child: Icon(
        icon,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return const Color(0xFF10B981);
      case 'Intermediate':
        return const Color(0xFFF59E0B);
      case 'Advanced':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}