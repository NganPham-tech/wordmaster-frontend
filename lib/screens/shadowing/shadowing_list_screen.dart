import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/data/models/shadowing_model.dart';
import '/controllers/shadowing_controller.dart';
import 'shadowing_player_screen.dart';

class ShadowingListScreen extends StatelessWidget {
  const ShadowingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller using GetX
    final controller = Get.put(ShadowingController());
    final searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shadowing Practice',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6366F1),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _showPracticeHistory(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Column(
          children: [
            // Search and filters section
            _buildSearchFilters(controller, searchController),

            // Content list with Obx for reactive updates
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value.isNotEmpty) {
                  return _buildErrorState(controller);
                }

                if (controller.shadowingList.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildContentList(controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilters(
    ShadowingController controller,
    TextEditingController searchController,
  ) {
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
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bài luyện...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        controller.applyFilters(search: '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (value) => controller.applyFilters(search: value),
          ),

          const SizedBox(height: 12),

          // Filter row
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildFilterDropdown(
                    value: controller.selectedDifficulty.value,
                    items: const [
                      'all',
                      'Beginner',
                      'Intermediate',
                      'Advanced',
                    ],
                    label: 'Mức độ',
                    onChanged: (value) =>
                        controller.applyFilters(difficulty: value!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildFilterDropdown(
                    value: controller.selectedAccent.value,
                    items: const ['all', 'American', 'British'],
                    label: 'Giọng',
                    onChanged: (value) =>
                        controller.applyFilters(accent: value!),
                  ),
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
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item == 'all' ? 'Tất cả' : item,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có shadowing content nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ShadowingController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Đã có lỗi xảy ra',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.error.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(ShadowingController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.shadowingList.length,
      itemBuilder: (context, index) {
        final content = controller.shadowingList[index];
        return _buildContentCard(content, controller);
      },
    );
  }

  Widget _buildContentCard(
    ShadowingContent content,
    ShadowingController controller,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToPlayer(content, controller),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (content.description != null &&
                            content.description!.isNotEmpty)
                          Text(
                            content.description!,
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
                ],
              ),

              const SizedBox(height: 16),

              // Tags và metadata
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildInfoChip(
                    content.difficulty,
                    _getDifficultyColor(content.difficulty),
                  ),
                  _buildInfoChip(content.accentType, Colors.blue),
                  if (content.duration != null)
                    _buildInfoChip(
                      '${content.duration! ~/ 60} phút',
                      Colors.green,
                    ),
                  if (content.segmentCount != null)
                    _buildInfoChip(
                      '${content.segmentCount} câu',
                      Colors.orange,
                    ),
                  ...content.tagList
                      .take(2)
                      .map((tag) => _buildInfoChip(tag, Colors.purple)),
                ],
              ),

              const SizedBox(height: 16),

              // Footer
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${content.viewCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () => _navigateToPlayer(content, controller),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text(
                      'Bắt đầu luyện tập',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  void _navigateToPlayer(
    ShadowingContent content,
    ShadowingController controller,
  ) async {
    try {
      // Load full content detail with segments using GetX
      final detailContent = await controller.getContentDetail(content.id);

      if (detailContent != null) {
        Get.to(() => ShadowingPlayerScreen(content: detailContent));
      }
    } catch (e) {
      // Error already handled in controller
    }
  }

  void _showPracticeHistory(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Lịch sử luyện tập'),
        content: const Text('Tính năng đang được phát triển...'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
        ],
      ),
    );
  }
}
