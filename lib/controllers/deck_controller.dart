import 'package:get/get.dart';
import '../data/models/deck_model.dart';
import '../services/api_service.dart';

class DeckController extends GetxController {
  final ApiService _apiService = ApiService.instance;

  // Observables
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
      
      print('Fetching vocabulary decks...');
      final result = await _apiService.getVocabularyDecks();
      print('Received ${result.length} vocabulary decks');
      
      decks.value = result;
      
    } catch (e) {
      print('Error fetching decks: $e');
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


  Future<Deck?> getDeckById(int id) async {
    try {
      return await _apiService.getDeckById(id);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }


  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }


  Future<void> refresh() async {
    await fetchDecks();
  }
}