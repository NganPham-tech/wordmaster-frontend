// lib/screens/dictation/dictation_full_screen.dart


import 'package:flutter/material.dart';
import '/data/models/dictation_model.dart';
import 'widgets/real_audio_player.dart';
import 'widgets/result_dialog.dart';
import 'package:get/get.dart';
import '../../controllers/session_controller.dart'; 

class DictationFullScreen extends StatefulWidget {
  final DictationContent content;

  const DictationFullScreen({
    super.key,
    required this.content,
  });

  @override
  State<DictationFullScreen> createState() => _DictationFullScreenState();
}

class _DictationFullScreenState extends State<DictationFullScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _showTranscript = false;
  bool _hasSubmitted = false;
  DateTime _startTime = DateTime.now();
  
  //
  final sessionController = Get.put(SessionController());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    await sessionController.startSession(
      contentType: 'Dictation',
      contentId: int.parse(widget.content.id),
      contentTitle: widget.content.title,
      mode: 'Practice',
      totalItems: 1, // 1 bài dictation
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTranscript() {
    setState(() {
      _showTranscript = !_showTranscript;
    });
  }

  void _submitAnswer() async {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung bạn nghe được'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }
    
    final timeSpent = DateTime.now().difference(_startTime).inSeconds;
    
    // Calculate accuracy
    final result = _calculateAccuracy(
      widget.content.transcript, 
      _inputController.text
    );
    
   
    final accuracy = result['accuracy'] as int;
    final scoreEarned = _calculateScore(accuracy);
    
    
    await sessionController.completeSession();
    
    setState(() {
      _hasSubmitted = true;
    });
    
    _showResultDialog(result, timeSpent, scoreEarned);
  }

 
  double _calculateScore(int accuracy) {
    // Base score: 100 points
    // Accuracy multiplier
    double baseScore = 100.0;
    double accuracyMultiplier = accuracy / 100.0;
    
    // Time bonus (if completed quickly)
    // final timeBonus = _calculateTimeBonus();
    
    return baseScore * accuracyMultiplier;
  }

  Map<String, dynamic> _calculateAccuracy(String original, String userInput) {
    String normalize(String text) {
      return text
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }
    
    final originalNorm = normalize(original);
    final userNorm = normalize(userInput);
    
    final originalWords = originalNorm.split(' ').where((w) => w.isNotEmpty).toList();
    final userWords = userNorm.split(' ').where((w) => w.isNotEmpty).toList();
    
    if (originalWords.isEmpty) {
      return {
        'accuracy': 0,
        'totalWords': 0,
        'correctWords': 0,
        'missingWords': 0,
        'extraWords': 0,
      };
    }
    
    // Simple word matching
    int correctWords = 0;
    for (final word in originalWords) {
      if (userWords.contains(word)) {
        correctWords++;
      }
    }
    
    final accuracy = (correctWords / originalWords.length) * 100;
    final missingWords = originalWords.length - correctWords;
    final extraWords = (userWords.length - correctWords).clamp(0, double.infinity).toInt();
    
    return {
      'accuracy': accuracy.round(),
      'totalWords': originalWords.length,
      'correctWords': correctWords,
      'missingWords': missingWords,
      'extraWords': extraWords,
    };
  }

  void _showResultDialog(Map<String, dynamic> result, int timeSpent, double scoreEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(
        title: 'Hoàn Thành Bài Nghe!',
        accuracy: result['accuracy'].toDouble(),
        correctAnswers: result['correctWords'],
        totalQuestions: result['totalWords'],
        timeSpent: timeSpent,
        scoreEarned: scoreEarned.toInt(), 
        onRetry: () {
          Navigator.pop(context);
          _restartPractice();
        },
        onClose: () {
          sessionController.endSession(); 
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _restartPractice() {
    setState(() {
      _inputController.clear();
      _hasSubmitted = false;
      _showTranscript = false;
      _startTime = DateTime.now();
    });
    _animationController.reset();
    _animationController.forward();
    
    
    _initializeSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nghe Toàn Bài',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
            
            Obx(() => Text(
              '${sessionController.currentScore.toInt()} XP',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            )),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () async {
        
            if (!_hasSubmitted) {
              await sessionController.completeSession();
            }
            sessionController.endSession();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF6366F1)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hướng Dẫn'),
                  content: const Text(
                    '1. Nhấn play để nghe toàn bộ audio\n'
                    '2. Gõ lại tất cả nội dung bạn nghe được\n'
                    '3. Nhấn "Nộp Bài" để kiểm tra kết quả\n'
                    '4. Bạn có thể xem transcript nếu cần hỗ trợ',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đã hiểu'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Player
          Container(
            child: widget.content.audioURL != null
                ? RealAudioPlayer(
                    audioUrl: widget.content.audioURL,
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_outlined, 
                            color: Colors.orange, size: 32),
                        const SizedBox(height: 8),
                        const Text('Không có file âm thanh',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Audio path: ${widget.content.audioPath ?? "null"}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
          ),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Instruction Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.hearing,
                            size: 48,
                            color: const Color(0xFF6366F1).withOpacity(0.8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nghe kỹ và gõ lại toàn bộ nội dung',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bài tập có ${widget.content.effectiveWordCount} từ - Thời lượng: ${widget.content.durationFormatted}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Transcript Toggle
                    if (!_hasSubmitted) ...[
                      Container(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _toggleTranscript,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFF6366F1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            _showTranscript ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF6366F1),
                            size: 20,
                          ),
                          label: Text(
                            _showTranscript ? 'Ẩn Transcript' : 'Hiện Transcript',
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Transcript (Conditional)
                    if (_showTranscript && !_hasSubmitted) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFBBF24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B)),
                                SizedBox(width: 8),
                                Text(
                                  'Transcript (Gợi ý)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.content.transcript,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF92400E),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Input Field
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasSubmitted 
                              ? const Color(0xFF10B981)
                              : Colors.grey[300]!,
                          width: _hasSubmitted ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _inputController,
                        maxLines: null,
                        expands: true,
                        enabled: !_hasSubmitted,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: _hasSubmitted 
                              ? 'Bài làm của bạn đã được nộp'
                              : 'Gõ nội dung bạn nghe được vào đây...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Word Count
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Số từ đã nhập:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_inputController.text.split(' ').where((word) => word.isNotEmpty).length} từ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (!_hasSubmitted) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _restartPractice,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Color(0xFF6366F1), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Làm Lại',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Nộp Bài',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _restartPractice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Luyện Tập Lại',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}