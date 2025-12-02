// lib/screens/flashcard/study_vocab_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/flashcard_controller.dart';
import '../../services/tts_service.dart';
import 'result_screen.dart';
import '../../controllers/session_controller.dart';

class StudyVocabScreen extends StatefulWidget {
  final int deckId;
  final String deckName;

  const StudyVocabScreen({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  State<StudyVocabScreen> createState() => _StudyVocabScreenState();
}

class _StudyVocabScreenState extends State<StudyVocabScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final RxBool _isFlipped = false.obs;

  late FlashcardController flashcardController;
  final sessionController = Get.put(SessionController());
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controller
    flashcardController = Get.put(FlashcardController());
    
    // Initialize TTS service
    TtsService.initialize();
    
    // Fetch flashcards for this deck
    flashcardController.fetchFlashcardsByDeck(widget.deckId);
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // 🆕 START SESSION
    _initializeSession();
  }
  
  // 🆕 INITIALIZE SESSION
  Future<void> _initializeSession() async {
    // Đợi cards load xong
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (flashcardController.flashcards.isNotEmpty) {
      await sessionController.startSession(
        contentType: 'Flashcard',
        contentId: widget.deckId,
        contentTitle: widget.deckName,
        mode: 'Learn',
        totalItems: flashcardController.flashcards.length,
      );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    TtsService.stop();
    super.dispose();
  }

  void _playAudio() {
    final currentCard = flashcardController.currentCard;
    if (currentCard != null && currentCard.question.isNotEmpty) {
      TtsService.speak(currentCard.question);
    }
  }

  void _flipCard() {
    if (_isFlipped.value) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isFlipped.value = !_isFlipped.value;
  }

  void _nextCard(bool known) {
    HapticFeedback.mediumImpact();
    
    final isLastCard = flashcardController.currentIndex.value >= 
        flashcardController.flashcards.length - 1;

    // 🆕 UPDATE SESSION - thêm điểm nếu biết từ
    if (known) {
      sessionController.incrementCompleted(scoreIncrement: 10.0);
    } else {
      sessionController.incrementCompleted(scoreIncrement: 0);
    }

    if (isLastCard) {
      _showCompletionDialog();
    } else {
      flashcardController.nextCard(known);
      _isFlipped.value = false;
      _controller.reset();
    }
  }

  void _showCompletionDialog() async {
    // 🆕 COMPLETE SESSION
    await sessionController.completeSession();
    
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
              'Bạn đã hoàn thành bộ từ vựng "${widget.deckName}"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Đã nhớ', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${flashcardController.knownCount.value}',
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
                    const Text('Chưa nhớ', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${flashcardController.unknownCount.value}',
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
            // 🆕 HIỂN THỊ ĐIỂM
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Điểm đạt được',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sessionController.currentScore.toInt()} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Back to list
              sessionController.endSession(); // 🆕 END SESSION
            },
            child: const Text('Về danh sách'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.off(() => ResultScreen(
                title: widget.deckName,
                totalCards: flashcardController.flashcards.length,
                knownCards: flashcardController.knownCount.value,
                unknownCards: flashcardController.unknownCount.value,
                type: 'vocabulary',
              ));
              sessionController.endSession(); // 🆕 END SESSION
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Xem kết quả', style: TextStyle(color: Colors.white)),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đang học: ${widget.deckName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 16,
              ),
            ),
            // 🆕 HIỂN THỊ ĐIỂM REAL-TIME
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Kết thúc học?'),
                  content: const Text('Tiến độ của bạn sẽ được lưu lại.'), // 🆕 UPDATED
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Ở lại'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // 🆕 COMPLETE SESSION khi thoát giữa chừng
                        await sessionController.completeSession();
                        Get.back(); // Close dialog
                        Get.back(); // Back to list
                        sessionController.endSession();
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
        if (flashcardController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (flashcardController.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  flashcardController.error.value,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => flashcardController.fetchFlashcardsByDeck(widget.deckId),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (flashcardController.flashcards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.style_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Bộ từ vựng này chưa có thẻ nào',
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

        final currentCard = flashcardController.currentCard;
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
                          '${flashcardController.currentIndex.value + 1}/${flashcardController.flashcards.length} từ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(flashcardController.progress * 100).toInt()}%',
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
                        value: flashcardController.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1),
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
                                    'Chưa nhớ',
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
                                    'Đã nhớ',
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
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Color(0xFF6366F1),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Nhấn vào thẻ để lật',
                              style: TextStyle(
                                color: Color(0xFF6366F1),
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
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'VOCABULARY',
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
                card.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            // Speaker button on front
            GestureDetector(
              onTap: _playAudio,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(24),
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Word
            Text(
              card.question,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            
            // Phonetic
            if (card.phonetic != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.phonetic,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Color(0xFF6366F1)),
                    onPressed: _playAudio,
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Meaning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Nghĩa',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.answer,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Example
            if (card.example != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ví dụ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card.example,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}