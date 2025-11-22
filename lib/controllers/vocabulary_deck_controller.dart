import 'package:get/get.dart';
import '../data/models/deck_model.dart';
import '../services/api_service.dart';

class VocabularyDeckController extends GetxController {
  final ApiService _apiService = ApiService.instance;

  final RxList<Deck> decks = <Deck>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  List<Deck> get filteredDecks {
    if (searchQuery.value.isEmpty) return decks;
    
    return decks.where((deck) {
      final query = searchQuery.value.toLowerCase();
      return deck.name.toLowerCase().contains(query) ||
             (deck.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDecks();
  }

  Future<void> fetchDecks() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final result = await _apiService.getVocabularyDecks();
      decks.value = result;
      
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

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> refresh() async {
    await fetchDecks();
  }
}