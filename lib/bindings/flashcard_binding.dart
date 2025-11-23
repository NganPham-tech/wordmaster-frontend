import 'package:get/get.dart';
import '../controllers/vocabulary_deck_controller.dart';
import '../controllers/grammar_deck_controller.dart';
import '../controllers/flashcard_controller.dart';
import '../controllers/grammar_controller.dart';

class FlashcardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VocabularyDeckController>(() => VocabularyDeckController());
    Get.lazyPut<GrammarDeckController>(() => GrammarDeckController());
    Get.lazyPut<FlashcardController>(() => FlashcardController());
    Get.lazyPut<GrammarController>(() => GrammarController());
  }
}