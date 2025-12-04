import 'package:get/get.dart';
import '../data/models/grammar_card_model.dart';
import '../services/api_service.dart';

class GrammarController extends GetxController {
  final ApiService _apiService = ApiService.instance;

  // Observables
  final RxList<GrammarCard> grammarCards = <GrammarCard>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt understoodCount = 0.obs;
  final RxInt notUnderstoodCount = 0.obs;

  // Current card
  GrammarCard? get currentCard {
    if (grammarCards.isEmpty || currentIndex.value >= grammarCards.length) {
      return null;
    }
    return grammarCards[currentIndex.value];
  }

  // Progress
  double get progress {
    if (grammarCards.isEmpty) return 0;
    return (currentIndex.value + 1) / grammarCards.length;
  }

  // Fetch grammar cards by deck
  Future<void> fetchGrammarCardsByDeck(int deckId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final result = await _apiService.getGrammarCardsByDeck(deckId);
      grammarCards.value = result;
      
      // Reset counters
      currentIndex.value = 0;
      understoodCount.value = 0;
      notUnderstoodCount.value = 0;
      
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Next card
  void nextCard(bool understood) {
    if (understood) {
      understoodCount.value++;
      print('Understood count: ${understoodCount.value}');
    } else {
      notUnderstoodCount.value++;
      print('Not understood count: ${notUnderstoodCount.value}');
    }

    print('Total cards: ${grammarCards.length}, Current: ${currentIndex.value + 1}');

    if (currentIndex.value < grammarCards.length - 1) {
      currentIndex.value++;
    } else {
      // Completed - DON'T auto close here, let UI handle it
      print('Study session completed');
    }
  }

  // Reset
  void reset() {
    currentIndex.value = 0;
    understoodCount.value = 0;
    notUnderstoodCount.value = 0;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}