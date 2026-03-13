import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/srs_controller.dart';

class SrsSettingsScreen extends StatelessWidget {
  const SrsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SrsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cài đặt ôn tập',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Content Mode Section
          _buildSection(
            title: 'Chế độ ôn tập',
            child: Obx(() => Column(
              children: [
                _buildRadioTile(
                  title: 'Từ vựng',
                  subtitle: 'Chỉ ôn tập flashcard từ vựng',
                  value: 'Flashcard',
                  groupValue: controller.contentMode.value,
                  onChanged: (val) => controller.contentMode.value = val!,
                  icon: Icons.style,
                  color: const Color(0xFF6366F1),
                ),
                const SizedBox(height: 12),
                _buildRadioTile(
                  title: 'Ngữ pháp',
                  subtitle: 'Chỉ ôn tập các điểm ngữ pháp',
                  value: 'Grammar',
                  groupValue: controller.contentMode.value,
                  onChanged: (val) => controller.contentMode.value = val!,
                  icon: Icons.school,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                _buildRadioTile(
                  title: 'Tổng hợp',
                  subtitle: 'Ôn tập cả từ vựng và ngữ pháp',
                  value: 'Mixed',
                  groupValue: controller.contentMode.value,
                  onChanged: (val) => controller.contentMode.value = val!,
                  icon: Icons.all_inclusive,
                  color: const Color(0xFFFF6B6B),
                ),
              ],
            )),
          ),

          const SizedBox(height: 24),

          // Daily Limits Section
          _buildSection(
            title: 'Giới hạn hàng ngày',
            child: Obx(() => Column(
              children: [
                _buildSliderSetting(
                  label: 'Số thẻ mới tối đa',
                  value: controller.maxNewCardsPerDay.value.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  onChanged: (val) => controller.maxNewCardsPerDay.value = val.toInt(),
                  icon: Icons.fiber_new,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Số thẻ mới mỗi ngày: ${controller.maxNewCardsPerDay.value}',
                  'Đây là số lượng thẻ mới tối đa bạn có thể học mỗi ngày.',
                  Icons.info_outline,
                  Colors.blue,
                ),
              ],
            )),
          ),

          const SizedBox(height: 24),

          // Display Options Section
          _buildSection(
            title: 'Tùy chọn hiển thị',
            child: Obx(() => Column(
              children: [
                _buildSwitchTile(
                  title: 'Hiển thị ví dụ',
                  subtitle: 'Hiển thị câu ví dụ khi lật thẻ',
                  value: controller.showExamples.value,
                  onChanged: (val) => controller.showExamples.value = val,
                  icon: Icons.format_quote,
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  title: 'Tự động phát âm',
                  subtitle: 'Tự động phát âm khi lật thẻ từ vựng',
                  value: controller.autoPlayAudio.value,
                  onChanged: (val) => controller.autoPlayAudio.value = val,
                  icon: Icons.volume_up,
                ),
              ],
            )),
          ),

          const SizedBox(height: 24),

          // Algorithm Info Section
          _buildSection(
            title: 'Thuật toán',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.psychology,
                              color: Colors.purple[700],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'SM-2 Algorithm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hệ thống sử dụng thuật toán SM-2 (SuperMemo 2) để tối ưu hóa việc ôn tập. Thẻ sẽ xuất hiện lại dựa trên độ khó của bạn đánh giá.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAlgorithmInfo('Quên', 'Ôn lại sau 1 ngày', Colors.red),
                      const SizedBox(height: 6),
                      _buildAlgorithmInfo('Khó', 'Ôn lại sau 1-3 ngày', Colors.orange),
                      const SizedBox(height: 6),
                      _buildAlgorithmInfo('Tốt', 'Ôn lại sau 6+ ngày', Colors.blue),
                      const SizedBox(height: 6),
                      _buildAlgorithmInfo('Dễ', 'Ôn lại sau 10+ ngày', Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Statistics Section
          _buildSection(
            title: 'Thống kê học tập',
            child: Obx(() => Column(
              children: [
                _buildStatRow(
                  icon: Icons.schedule,
                  label: 'Thẻ đến hạn hôm nay',
                  value: '${controller.dueCount.value}',
                  color: Colors.orange,
                ),
                const Divider(height: 24),
                _buildStatRow(
                  icon: Icons.check_circle,
                  label: 'Đã ôn tập hôm nay',
                  value: '${controller.reviewedToday.value}',
                  color: Colors.green,
                ),
                const Divider(height: 24),
                _buildStatRow(
                  icon: Icons.fiber_new,
                  label: 'Thẻ mới chờ học',
                  value: '${controller.newCount.value}',
                  color: Colors.blue,
                ),
              ],
            )),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = value == groupValue;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? color : Colors.grey[600], size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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

  Widget _buildAlgorithmInfo(String level, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              children: [
                TextSpan(
                  text: '$level: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}