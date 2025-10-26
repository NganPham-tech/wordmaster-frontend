// lib/flashcard/flashcard_overview_screen.dart
import 'package:flutter/material.dart';
import '../../data/flashcard_api.dart';
import '../../models/category.dart';
import '../../themes/app_theme.dart';
import 'flashcard_deck_list_screen.dart';

class FlashcardOverviewScreen extends StatefulWidget {
  const FlashcardOverviewScreen({super.key});

  @override
  State<FlashcardOverviewScreen> createState() =>
      _FlashcardOverviewScreenState();
}

class _FlashcardOverviewScreenState extends State<FlashcardOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _vocabCategories = [];
  List<Category> _grammarCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final vocabCats = await FlashcardAPI.getCategories(type: 'vocabulary');
      final grammarCats = await FlashcardAPI.getCategories(type: 'grammar');

      setState(() {
        _vocabCategories = vocabCats;
        _grammarCategories = grammarCats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Từ vựng'),
            Tab(text: 'Ngữ pháp'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryGrid(_vocabCategories),
                _buildCategoryGrid(_grammarCategories),
              ],
            ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có chủ đề nào',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardDeckListScreen(category: category),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _parseColor(category.colorCode).withOpacity(0.1),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _parseColor(category.colorCode).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.deckCount} deck',
                    style: TextStyle(
                      fontSize: 12,
                      color: _parseColor(category.colorCode),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book, // Default icon
                      size: 32,
                      color: _parseColor(category.colorCode),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description ?? 'Không có mô tả',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorCode) {
    try {
      return Color(
        int.parse(colorCode.substring(1, 7), radix: 16) + 0xFF000000,
      );
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
