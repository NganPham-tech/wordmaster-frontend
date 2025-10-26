import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'study_vocab_screen.dart';

// Model cho Vocabulary Deck
class VocabDeck {
  final String id;
  final String name;
  final String description;
  final int totalCards;
  final int learnedCards;
  final String emoji;
  final Color color;

  VocabDeck({
    required this.id,
    required this.name,
    required this.description,
    required this.totalCards,
    required this.learnedCards,
    required this.emoji,
    required this.color,
  });

  double get progress => totalCards > 0 ? learnedCards / totalCards : 0;
}

class VocabListScreen extends StatefulWidget {
  const VocabListScreen({super.key});

  @override
  State<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends State<VocabListScreen> {
  String _searchQuery = '';
  
  // Dữ liệu mẫu
  final List<VocabDeck> _vocabDecks = [
    VocabDeck(
      id: '1',
      name: 'Animals',
      description: 'Từ vựng về động vật, thú nuôi',
      totalCards: 50,
      learnedCards: 30,
      emoji: '🐾',
      color: const Color(0xFF6366F1),
    ),
    VocabDeck(
      id: '2',
      name: 'Technology',
      description: 'Thuật ngữ công nghệ hiện đại',
      totalCards: 60,
      learnedCards: 15,
      emoji: '💻',
      color: const Color(0xFF8B5CF6),
    ),
    VocabDeck(
      id: '3',
      name: 'Daily Activities',
      description: 'Hoạt động hàng ngày',
      totalCards: 40,
      learnedCards: 40,
      emoji: '🏃',
      color: const Color(0xFF10B981),
    ),
    VocabDeck(
      id: '4',
      name: 'Food & Drink',
      description: 'Món ăn và đồ uống',
      totalCards: 55,
      learnedCards: 20,
      emoji: '🍔',
      color: const Color(0xFFF59E0B),
    ),
    VocabDeck(
      id: '5',
      name: 'Travel',
      description: 'Du lịch và địa điểm',
      totalCards: 45,
      learnedCards: 10,
      emoji: '✈️',
      color: const Color(0xFFEF4444),
    ),
    VocabDeck(
      id: '6',
      name: 'Business',
      description: 'Thuật ngữ kinh doanh',
      totalCards: 70,
      learnedCards: 0,
      emoji: '💼',
      color: const Color(0xFF06B6D4),
    ),
  ];

  List<VocabDeck> get filteredDecks {
    if (_searchQuery.isEmpty) return _vocabDecks;
    return _vocabDecks.where((deck) =>
      deck.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      deck.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Bộ từ vựng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Add new deck
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bộ từ vựng...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Deck list
          Expanded(
            child: filteredDecks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy bộ từ vựng',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredDecks.length,
                    itemBuilder: (context, index) {
                      return _buildDeckCard(filteredDecks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCard(VocabDeck deck) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyVocabScreen(deckId: deck.id, deckName: deck.name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with emoji
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: deck.color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  deck.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      deck.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deck.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    
                    // Progress
                    Text(
                      '${deck.learnedCards}/${deck.totalCards} từ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: deck.progress,
                        minHeight: 3,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(deck.color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudyVocabScreen(
                                deckId: deck.id,
                                deckName: deck.name,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deck.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                          minimumSize: const Size.fromHeight(28),
                        ),
                        child: const Text(
                          'Học ngay',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}