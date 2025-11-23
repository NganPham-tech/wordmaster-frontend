import 'package:get/get.dart';
import '../data/models/flashcard_model.dart';
import '../services/api_service.dart';

class FlashcardController extends GetxController {
  final ApiService _apiService = ApiService.instance;

  // Observables
  final RxList<Flashcard> flashcards = <Flashcard>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt knownCount = 0.obs;
  final RxInt unknownCount = 0.obs;

  // Current flashcard
  Flashcard? get currentCard {
    if (flashcards.isEmpty || currentIndex.value >= flashcards.length) {
      return null;
    }
    return flashcards[currentIndex.value];
  }

  // Progress
  double get progress {
    if (flashcards.isEmpty) return 0;
    return (currentIndex.value + 1) / flashcards.length;
  }

  // Fetch flashcards by deck
  Future<void> fetchFlashcardsByDeck(int deckId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final result = await _apiService.getFlashcardsByDeck(deckId);
      flashcards.value = result;
      
      // Reset counters
      currentIndex.value = 0;
      knownCount.value = 0;
      unknownCount.value = 0;
      
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
  void nextCard(bool known) {
    if (known) {
      knownCount.value++;
    } else {
      unknownCount.value++;
    }

    if (currentIndex.value < flashcards.length - 1) {
      currentIndex.value++;
    } else {
      // Completed - navigate to result
      Get.back();
      Get.snackbar(
        'Hoàn thành! 🎉',
        'Đã nhớ: ${knownCount.value}/${flashcards.length}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Reset
  void reset() {
    currentIndex.value = 0;
    knownCount.value = 0;
    unknownCount.value = 0;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}