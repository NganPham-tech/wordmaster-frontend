import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'vi';

  final List<Map<String, String>> _languages = [
    {
      'code': 'vi',
      'name': 'Tiếng Việt',
      'nativeName': 'Tiếng Việt',
      'flag': '🇻🇳',
    },
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': '🇺🇸'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어', 'flag': '🇰🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'vi';
    });
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  void _showChangeLanguageDialog(String languageCode, String languageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thay đổi'),
        content: Text('Bạn có muốn chuyển sang $languageName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveLanguage(languageCode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã chuyển sang $languageName'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd63384),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt ngôn ngữ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header Section
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
            child: const Row(
              children: [
                Icon(Icons.language, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chọn ngôn ngữ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Thay đổi ngôn ngữ hiển thị của ứng dụng',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Current Language
          const Text(
            'Ngôn ngữ hiện tại',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFd63384),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFd63384).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFd63384).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _languages.firstWhere(
                    (lang) => lang['code'] == _selectedLanguage,
                  )['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _languages.firstWhere(
                        (lang) => lang['code'] == _selectedLanguage,
                      )['nativeName']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _languages.firstWhere(
                        (lang) => lang['code'] == _selectedLanguage,
                      )['name']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.check_circle, color: Color(0xFFd63384)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Available Languages
          const Text(
            'Ngôn ngữ có sẵn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFd63384),
            ),
          ),
          const SizedBox(height: 12),

          ..._languages.map((language) => _buildLanguageItem(language)),

          const SizedBox(height: 32),

          // Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lưu ý',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thay đổi ngôn ngữ sẽ áp dụng cho toàn bộ ứng dụng. Một số từ vựng có thể cần thời gian để cập nhật.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, String> language) {
    final isSelected = language['code'] == _selectedLanguage;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: isSelected
            ? const Color(0xFFd63384).withValues(alpha: 0.1)
            : Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFFd63384) : Colors.transparent,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFd63384)
                    : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                language['flag']!,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            language['nativeName']!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFd63384) : null,
            ),
          ),
          subtitle: Text(
            language['name']!,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFd63384).withValues(alpha: 0.8)
                  : Colors.grey.shade600,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Color(0xFFd63384))
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
          onTap: isSelected
              ? null
              : () => _showChangeLanguageDialog(
                  language['code']!,
                  language['nativeName']!,
                ),
        ),
      ),
    );
  }
}
