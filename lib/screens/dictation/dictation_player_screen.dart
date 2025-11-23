// lib/screens/dictation/dictation_player_screen.dart
//D:\DemoDACN\wordmaster_dacn\lib\screens\dictation\dictation_player_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '/data/models/dictation_model.dart';
import 'widgets/audio_player_bar.dart' hide ResultDialog;
import 'widgets/result_dialog.dart';

class DictationPlayerScreen extends StatefulWidget {
  final DictationContent content;

  const DictationPlayerScreen({
    super.key,
    required this.content,
  });

  @override
  State<DictationPlayerScreen> createState() => _DictationPlayerScreenState();
}

class _DictationPlayerScreenState extends State<DictationPlayerScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<DictationSentence> _sentences = [];
  int _currentSentenceIndex = 0;
  bool _isPlaying = false;
  bool _showHint = false;
  bool _hasChecked = false;
  String? _feedback;
  
  // Results tracking
  int _correctAnswers = 0;
  int _totalWords = 0;
  int _correctWords = 0;
  DateTime _startTime = DateTime.now();
  
  // Audio simulation
  Timer? _playbackTimer;
  double _currentPosition = 0;
  double _totalDuration = 0;

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
    _initializeSentences();
    _totalDuration = widget.content.duration.toDouble();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animationController.dispose();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _initializeSentences() {
    // Simulate splitting transcript into sentences
    final transcript = widget.content.transcript;
    final sentenceTexts = transcript.split('. ')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.endsWith('.') ? s : '$s.')
        .toList();
    
    int startTime = 0;
    final avgTimePerSentence = widget.content.duration ~/ sentenceTexts.length;
    
    _sentences = sentenceTexts.asMap().entries.map((entry) {
      final sentence = DictationSentence(
        index: entry.key,
        text: entry.value,
        startTime: startTime,
        endTime: startTime + avgTimePerSentence,
      );
      startTime += avgTimePerSentence;
      return sentence;
    }).toList();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _startPlayback();
    } else {
      _pausePlayback();
    }
  }

  void _startPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentPosition += 0.1;
        if (_currentPosition >= _totalDuration) {
          _currentPosition = _totalDuration;
          _isPlaying = false;
          timer.cancel();
        }
        
        // Auto-advance sentence based on position
        for (var sentence in _sentences) {
          if (_currentPosition >= sentence.startTime && 
              _currentPosition < sentence.endTime) {
            if (_currentSentenceIndex != sentence.index) {
              _currentSentenceIndex = sentence.index;
              _resetCurrentSentence();
            }
            break;
          }
        }
      });
    });
  }

  void _pausePlayback() {
    _playbackTimer?.cancel();
  }

  void _seekTo(double position) {
    setState(() {
      _currentPosition = position;
      // Find corresponding sentence
      for (var sentence in _sentences) {
        if (position >= sentence.startTime && position < sentence.endTime) {
          if (_currentSentenceIndex != sentence.index) {
            _currentSentenceIndex = sentence.index;
            _resetCurrentSentence();
          }
          break;
        }
      }
    });
  }

  void _resetCurrentSentence() {
    _inputController.clear();
    _hasChecked = false;
    _showHint = false;
    _feedback = null;
  }

  void _checkAnswer() {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type what you hear'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }
    
    final currentSentence = _sentences[_currentSentenceIndex];
    final correct = currentSentence.text.toLowerCase().trim();
    final userInput = _inputController.text.toLowerCase().trim();
    
    // Calculate accuracy
    final correctWords = correct.split(' ');
    final userWords = userInput.split(' ');
    int matchedWords = 0;
    
    for (int i = 0; i < correctWords.length && i < userWords.length; i++) {
      if (correctWords[i] == userWords[i]) {
        matchedWords++;
      }
    }
    
    final accuracy = (matchedWords / correctWords.length) * 100;
    
    setState(() {
      _hasChecked = true;
      _totalWords += correctWords.length;
      _correctWords += matchedWords;
      
      if (accuracy >= 80) {
        _feedback = 'Great job! ${accuracy.toStringAsFixed(0)}% accurate';
        _correctAnswers++;
      } else if (accuracy >= 60) {
        _feedback = 'Good try! ${accuracy.toStringAsFixed(0)}% accurate';
      } else {
        _feedback = 'Keep practicing! ${accuracy.toStringAsFixed(0)}% accurate';
      }
    });
    
    // Vibrate effect
    _animationController.reset();
    _animationController.forward();
  }

  void _nextSentence() {
    if (_currentSentenceIndex < _sentences.length - 1) {
      setState(() {
        _currentSentenceIndex++;
        _resetCurrentSentence();
        _currentPosition = _sentences[_currentSentenceIndex].startTime.toDouble();
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _showCompletionDialog();
    }
  }

  void _previousSentence() {
    if (_currentSentenceIndex > 0) {
      setState(() {
        _currentSentenceIndex--;
        _resetCurrentSentence();
        _currentPosition = _sentences[_currentSentenceIndex].startTime.toDouble();
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showCompletionDialog() {
    final timeSpent = DateTime.now().difference(_startTime).inSeconds;
    final accuracy = (_correctWords / _totalWords * 100).toStringAsFixed(1);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(
        title: 'Dictation Complete! 🎉',
        accuracy: double.parse(accuracy),
        correctAnswers: _correctAnswers,
        totalQuestions: _sentences.length,
        timeSpent: timeSpent,
        onRetry: () {
          Navigator.pop(context);
          setState(() {
            _currentSentenceIndex = 0;
            _correctAnswers = 0;
            _totalWords = 0;
            _correctWords = 0;
            _startTime = DateTime.now();
            _currentPosition = 0;
            _resetCurrentSentence();
          });
        },
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  String _getHintText() {
    final sentence = _sentences[_currentSentenceIndex].text;
    final words = sentence.split(' ');
    if (words.length <= 3) {
      return '${words.first} ... ${words.last}';
    }
    return '${words.first} ${words[1]} ... ${words[words.length - 2]} ${words.last}';
  }

  @override
  Widget build(BuildContext context) {
    final currentSentence = _sentences.isNotEmpty 
        ? _sentences[_currentSentenceIndex] 
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.content.title,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentSentenceIndex + 1}/${_sentences.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Player Bar
          AudioPlayerBar(
            isPlaying: _isPlaying,
            currentPosition: _currentPosition,
            totalDuration: _totalDuration,
            onPlayPause: _togglePlayPause,
            onSeek: _seekTo,
            onNext: _currentSentenceIndex < _sentences.length - 1 
                ? _nextSentence 
                : null,
            onPrevious: _currentSentenceIndex > 0 
                ? _previousSentence 
                : null,
          ),
          
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Progress Indicator
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (_currentSentenceIndex + 1) / _sentences.length,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
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
                            Icons.headphones,
                            size: 48,
                            color: const Color(0xFF6366F1).withOpacity(0.8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Listen carefully and type what you hear',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sentence ${_currentSentenceIndex + 1} of ${_sentences.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasChecked 
                              ? (_feedback?.contains('Great') ?? false
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B))
                              : Colors.grey[300]!,
                          width: _hasChecked ? 2 : 1,
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
                        maxLines: 4,
                        enabled: !_hasChecked,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type what you hear...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    
                    // Hint Section
                    if (_showHint && !_hasChecked) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Hint: ${_getHintText()}',
                                style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Feedback Section
                    if (_hasChecked && _feedback != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _feedback!.contains('Great')
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _feedback!.contains('Great')
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _feedback!.contains('Great')
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color: _feedback!.contains('Great')
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _feedback!,
                                  style: TextStyle(
                                    color: _feedback!.contains('Great')
                                        ? const Color(0xFF065F46)
                                        : const Color(0xFF92400E),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (currentSentence != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Correct answer:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentSentence.text,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
                if (!_hasChecked) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleHint,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showHint ? Icons.visibility_off : Icons.lightbulb_outline,
                            color: const Color(0xFF6366F1),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showHint ? 'Hide Hint' : 'Show Hint',
                            style: const TextStyle(
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
                      onPressed: _checkAnswer,
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
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Check Answer',
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
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _hasChecked = false;
                          _feedback = null;
                          _inputController.clear();
                        });
                      },
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
                            'Try Again',
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
                      onPressed: _nextSentence,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentSentenceIndex < _sentences.length - 1
                                ? 'Next'
                                : 'Finish',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentSentenceIndex < _sentences.length - 1
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            color: Colors.white,
                            size: 20,
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