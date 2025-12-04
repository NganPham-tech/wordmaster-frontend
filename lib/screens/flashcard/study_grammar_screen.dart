import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/grammar_controller.dart';
import '../../services/learning_session_service.dart';
import 'result_screen.dart';
import 'widgets/feynman_dialog.dart';
import 'widgets/feynman_note_display.dart';
class StudyGrammarScreen extends StatefulWidget {
  final int topicId;
  final String topicName;

  const StudyGrammarScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<StudyGrammarScreen> createState() => _StudyGrammarScreenState();
}

class _StudyGrammarScreenState extends State<StudyGrammarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final RxBool _isFlipped = false.obs;

  final grammarController = Get.find<GrammarController>();
  final _sessionService = LearningSessionService.instance;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    
    // Fetch grammar cards for this deck
    grammarController.fetchGrammarCardsByDeck(widget.topicId).then((_) {
      // Start learning session sau khi load cards thành công
      _startLearningSession();
    });
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _startLearningSession() async {
    _sessionId = await _sessionService.startSession(
      contentType: 'Grammar',
      contentId: widget.topicId,
      mode: 'Flashcard Study',
      totalItems: grammarController.grammarCards.length,
    );
  }

  Future<void> _completeSession() async {
    if (_sessionId != null) {
      final score = grammarController.grammarCards.isNotEmpty 
          ? (grammarController.understoodCount.value / grammarController.grammarCards.length * 100)
          : 0.0;
          
      await _sessionService.completeSession(
        sessionId: _sessionId,
        completedItems: grammarController.currentIndex.value + 1, // +1 vì index bắt đầu từ 0
        score: score,
      );
      _sessionId = null; // Clear session ID
    }
  }

  void _updateSessionProgress() {
    if (_sessionId != null) {
      final score = grammarController.grammarCards.isNotEmpty 
          ? (grammarController.understoodCount.value / grammarController.grammarCards.length * 100)
          : 0.0;
          
      _sessionService.updateProgress(
        sessionId: _sessionId,
        completedItems: grammarController.currentIndex.value + 1,
        score: score,
      );
    }
  }

  @override
  void dispose() {
    // Complete session nếu chưa complete
    _completeSession();
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped.value) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isFlipped.value = !_isFlipped.value;
  }

  void _nextCard(bool understood) {
  HapticFeedback.mediumImpact();
  
  final currentCard = grammarController.currentCard;
  final isLastCard = grammarController.currentIndex.value >= 
      grammarController.grammarCards.length - 1;

  // LUÔN update count trước khi hiển thị dialog
  grammarController.nextCard(understood);
  
  // Update session progress
  _updateSessionProgress();
  
  if (isLastCard) {
    // Hiển thị completion dialog sau khi đã update count
    _showCompletionDialog();
  } else {
    // Reset UI cho card tiếp theo
    _isFlipped.value = false;
    _controller.reset();
    
    // Kiểm tra điều kiện hiển thị Feynman dialog
    // Trigger Feynman sau mỗi 5 thẻ "hiểu rồi"
    final shouldShowFeynman = understood && 
        grammarController.understoodCount.value > 0 && 
        grammarController.understoodCount.value % 5 == 0;
    
    if (shouldShowFeynman && currentCard != null) {
      print('Triggering Feynman after ${grammarController.understoodCount.value} understood cards');
      _showFeynmanDialog(currentCard);
    }
  }
}

void _showFeynmanDialog(dynamic card) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => FeynmanDialog(
      cardType: 'Grammar',
      cardId: card.id,
      cardTitle: card.title,
      onSaved: () {
        // Sau khi lưu xong, không cần làm gì thêm vì đã nextCard() rồi
        print('Feynman note saved for card: ${card.title}');
      },
    ),
  );
}

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Hoàn thành!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bạn đã hoàn thành chủ đề "${widget.topicName}"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Hiểu rồi', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${grammarController.understoodCount.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Chưa hiểu', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${grammarController.notUnderstoodCount.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () async {
              // Complete session trước khi về danh sách
              await _completeSession();
              Get.back(); // Close dialog
              Get.back(); // Back to list
            },
            child: const Text('Về danh sách'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Complete session trước khi xem kết quả
              await _completeSession();
              Get.back(); // Close dialog
              Get.off(() => ResultScreen(
                title: widget.topicName,
                totalCards: grammarController.grammarCards.length,
                knownCards: grammarController.understoodCount.value,
                unknownCards: grammarController.notUnderstoodCount.value,
                type: 'grammar',
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Xem kết quả'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Đang học: ${widget.topicName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Kết thúc học?'),
                  content: const Text('Tiến độ của bạn sẽ không được lưu.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Ở lại'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Back to list
                      },
                      child: const Text(
                        'Kết thúc',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (grammarController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (grammarController.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  grammarController.error.value,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => grammarController.fetchGrammarCardsByDeck(widget.topicId),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (grammarController.grammarCards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chủ đề này chưa có thẻ ngữ pháp nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          );
        }

        final currentCard = grammarController.currentCard;
        if (currentCard == null) {
          return const Center(child: Text('Không có thẻ nào'));
        }

        return SafeArea(
          child: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${grammarController.currentIndex.value + 1}/${grammarController.grammarCards.length} thẻ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(grammarController.progress * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: grammarController.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Flashcard
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value * math.pi;
                      final isFront = angle < math.pi / 2;
                      
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isFront
                            ? _buildCardFront(currentCard)
                            : Transform(
                                transform: Matrix4.identity()..rotateY(math.pi),
                                alignment: Alignment.center,
                                child: _buildCardBack(currentCard),
                              ),
                      );
                    },
                  ),
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Obx(() => _isFlipped.value
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _nextCard(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Chưa hiểu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _nextCard(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hiểu rồi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Nhấn vào thẻ để xem giải thích',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCardFront(dynamic card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GRAMMAR',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: Text(
                card.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 40),
            if (card.structure != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  card.structure,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 40),
            const Icon(
              Icons.flip_camera_ios,
              color: Colors.white70,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(dynamic card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                card.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, 
                          color: Color(0xFF10B981), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Giải thích',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.explanation,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Structure
            if (card.structure != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.functions, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Công thức',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        card.structure,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Example
            if (card.example != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, 
                            color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ví dụ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card.example,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[900],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Usage Note
            if (card.usageNote != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, 
                            color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Lưu ý',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card.usageNote,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue[900],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
             FeynmanNoteDisplay(
              cardType: 'Grammar',
              cardId: card.id,
              accentColor: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }
}