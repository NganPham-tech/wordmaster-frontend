// lib/flashcard/flashcard_deck_list_screen.dart
import 'package:flutter/material.dart';
import '../../data/flashcard_api.dart';
import '../../models/category.dart';
import '../../models/deck.dart';
import 'flashcard_study_screen.dart';

class FlashcardDeckListScreen extends StatefulWidget {
  final Category category;

  const FlashcardDeckListScreen({super.key, required this.category});

  @override
  State<FlashcardDeckListScreen> createState() =>
      _FlashcardDeckListScreenState();
}

class _FlashcardDeckListScreenState extends State<FlashcardDeckListScreen> {
  List<Deck> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    try {
      final decks = await FlashcardAPI.getDecksByCategory(widget.category.id);
      setState(() {
        _decks = decks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading decks: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _decks.isEmpty
          ? const Center(child: Text('Chưa có deck nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _decks.length,
              itemBuilder: (context, index) {
                return _buildDeckCard(_decks[index]);
              },
            ),
    );
  }

  Widget _buildDeckCard(Deck deck) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'images/timo.jpg',
                width: 80,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 16),

            // Deck Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deck.description ?? 'Không có mô tả',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Progress and Stats
                  Row(
                    children: [
                      _buildProgressIndicator(deck.progress),
                      const SizedBox(width: 8),
                      Text(
                        '${deck.learnedCards}/${deck.totalCards}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            deck.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Start Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardStudyScreen(deck: deck),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Học'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Expanded(
      flex: 2,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(
          progress > 0.7 ? Colors.green : Colors.blueAccent,
        ),
        minHeight: 6,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
