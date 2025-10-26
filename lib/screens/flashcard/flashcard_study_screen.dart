// lib/flashcard/flashcard_study_screen.dart
import 'package:flutter/material.dart';
import '../../data/flashcard_api.dart';
import '../../models/deck.dart';
import '../../models/flashcard.dart';
import '../../services/tts_service.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final Deck deck;

  const FlashcardStudyScreen({super.key, required this.deck});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  double _progress = 0.0;
  late AnimationController _flipController;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadFlashcards();
    // TTS đã được khởi tạo trong main.dart
  }

  Future<void> _loadFlashcards() async {
    try {
      final cards = await FlashcardAPI.getFlashcardsByDeck(widget.deck.id);
      setState(() {
        _flashcards = cards;
        _isLoading = false;
        _updateProgress();
      });

      // Tự động phát âm thẻ đầu tiên nếu là vocabulary
      if (_flashcards.isNotEmpty && _flashcards[0].type == 'vocabulary') {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _speakText();
        });
      }
    } catch (e) {
      print('Error loading flashcards: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateProgress() {
    setState(() {
      _progress = _currentIndex / _flashcards.length;
    });
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFront = true;
        _flipController.reset();
        _updateProgress();
      });

      // Tự động phát âm từ mới nếu là vocabulary
      if (isVocabulary) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _speakText();
        });
      }
    } else {
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFront = true;
        _flipController.reset();
        _updateProgress();
      });

      // Tự động phát âm từ nếu là vocabulary
      if (isVocabulary) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _speakText();
        });
      }
    }
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;
  }

  void _markAsRemembered() {
    // TODO: Implement API call to update learning progress
    // final card = _flashcards[_currentIndex];
    // FlashcardAPI.updateLearningProgress(LearningUpdate(
    //   userId: 1,
    //   flashcardId: card.id,
    //   status: 'Mastered',
    //   remembered: true,
    // ));
    _nextCard();
  }

  void _markForReview() {
    // final card = _flashcards[_currentIndex];
    // FlashcardAPI.updateLearningProgress(LearningUpdate(
    //   userId: 1,
    //   flashcardId: card.id,
    //   status: 'Learning',
    //   remembered: false,
    // ));
    _nextCard();
  }

  void _speakText() {
    if (_flashcards[_currentIndex].type == 'vocabulary') {
      print(
        'DEBUG: Attempting to speak: ${_flashcards[_currentIndex].question}',
      );
      print('DEBUG: TTS initialized: ${TtsService.isInitialized}');
      TtsService.speak(_flashcards[_currentIndex].question);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chúc mừng!'),
        content: const Text('Bạn đã hoàn thành deck này.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool get isVocabulary =>
      _flashcards.isNotEmpty && _flashcards[_currentIndex].type == 'vocabulary';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.name)),
        body: const Center(child: Text('Không có thẻ nào trong deck.')),
      );
    }

    final currentCard = _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        actions: [
          if (isVocabulary)
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: _speakText,
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1}/${_flashcards.length}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}% hoàn thành',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Flashcard
          Expanded(
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipController,
                builder: (context, child) {
                  final angle = _flipController.value * 3.14159;

                  // Hiển thị mặt trước khi góc nhỏ hơn 90 độ (pi/2)
                  final showFront = angle < 1.5708;

                  // Tạo transform với góc xoay phù hợp
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(showFront ? angle : angle - 3.14159);

                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: showFront
                        ? _buildFrontCard(currentCard)
                        : _buildBackCard(currentCard),
                  );
                },
              ),
            ),
          ),

          // Control Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Trước'),
                      onPressed: _previousCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.flip),
                      label: const Text('Lật thẻ'),
                      onPressed: _flipCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Sau'),
                      onPressed: _nextCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Remember/Review Buttons (only show when card is flipped)
                if (!_isFront)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Cần ôn lại'),
                        onPressed: _markForReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Đã nhớ'),
                        onPressed: _markAsRemembered,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard(Flashcard card) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isVocabulary ? Colors.white : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isVocabulary && card.imagePath != null)
              Image.asset(
                'images/timo.jpg',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              card.question,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),

            if (isVocabulary && card.phonetic != null) ...[
              const SizedBox(height: 8),
              Text(
                card.phonetic!,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],

            if (isVocabulary && card.wordType != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  card.wordType!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              'Chạm để xem nghĩa',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(Flashcard card) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isVocabulary ? Colors.white : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.answer,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),

              if (card.example != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ví dụ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(card.example!, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                'Chạm để xem từ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    TtsService.stop();
    super.dispose();
  }
}
