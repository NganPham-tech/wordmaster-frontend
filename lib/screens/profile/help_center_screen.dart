import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung tâm trợ giúp'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFd63384), Color(0xFFe85aa1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_center, color: Colors.white, size: 32),
                SizedBox(height: 12),
                Text(
                  'Chúng tôi ở đây để giúp bạn!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tìm câu trả lời cho các câu hỏi thường gặp hoặc liên hệ với chúng tôi.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // FAQ Section
          _buildSectionHeader('Câu hỏi thường gặp'),
          const SizedBox(height: 16),
          _buildFAQItem(
            'Làm thế nào để tạo flashcard mới?',
            'Vào mục "Bộ thẻ", chọn một bộ thẻ, sau đó nhấn nút "+" để thêm flashcard mới. Nhập từ vựng ở mặt trước và nghĩa ở mặt sau.',
          ),
          _buildFAQItem(
            'Tôi có thể học offline không?',
            'Có! Tất cả flashcard đã tải về sẽ có thể học offline. Tuy nhiên, một số tính năng như đồng bộ dữ liệu cần kết nối internet.',
          ),
          _buildFAQItem(
            'Làm sao để theo dõi tiến độ học tập?',
            'Vào mục "Trang chủ" để xem tổng quan tiến độ. Bạn có thể xem số từ đã học, streak hiện tại và điểm số.',
          ),
          _buildFAQItem(
            'Tôi quên mật khẩu, phải làm sao?',
            'Ở màn hình đăng nhập, chọn "Quên mật khẩu" và nhập email. Chúng tôi sẽ gửi link reset mật khẩu cho bạn.',
          ),
          _buildFAQItem(
            'Làm thế nào để thay đổi thông tin cá nhân?',
            'Vào mục "Profile" → "Thông tin cá nhân" để chỉnh sửa tên và các thông tin khác.',
          ),

          const SizedBox(height: 32),

          // Contact Section
          _buildSectionHeader('Liên hệ hỗ trợ'),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.email_outlined,
            'Email hỗ trợ',
            'support@wordmaster.com',
            () => _launchEmail('support@wordmaster.com'),
          ),
          _buildContactItem(
            Icons.phone_outlined,
            'Hotline',
            '1900 123 456',
            () => _launchPhone('19001123456'),
          ),
          _buildContactItem(
            Icons.chat_bubble_outline,
            'Chat trực tuyến',
            'Có sẵn 8:00 - 22:00',
            () => _showChatDialog(context),
          ),

          const SizedBox(height: 32),

          // Quick Actions
          _buildSectionHeader('Hành động nhanh'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  Icons.bug_report_outlined,
                  'Báo lỗi',
                  () => _showBugReportDialog(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  Icons.lightbulb_outline,
                  'Đề xuất',
                  () => _showSuggestionDialog(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Version Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'WordMaster v1.0.0',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cập nhật lần cuối: 11/10/2024',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFd63384),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFd63384).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFd63384)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFd63384).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFd63384), size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=WordMaster Support',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat hỗ trợ'),
        content: const Text(
          'Tính năng chat trực tuyến sẽ sớm có sẵn. Hiện tại, vui lòng liên hệ qua email hoặc hotline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo lỗi'),
        content: const Text(
          'Để báo cáo lỗi, vui lòng gửi email cho chúng tôi với mô tả chi tiết về lỗi và các bước tái hiện.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail('support@wordmaster.com');
            },
            child: const Text('Gửi email'),
          ),
        ],
      ),
    );
  }

  void _showSuggestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi đề xuất'),
        content: const Text(
          'Chúng tôi luôn chào đón ý kiến đóng góp! Vui lòng gửi email với đề xuất của bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail('support@wordmaster.com');
            },
            child: const Text('Gửi email'),
          ),
        ],
      ),
    );
  }
}
