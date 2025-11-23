import 'package:get/get.dart';
import '../data/models/deck_model.dart';
import '../services/api_service.dart';

class CategoryController extends GetxController {
  final ApiService _apiService = ApiService.instance;

  // Observables
  final RxList<Deck> decks = <Deck>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString currentCategory = ''.obs;

  // Computed - filtered decks
  List<Deck> get filteredDecks {
    var deckList = decks;
    
    // Filter by category if specified
    if (currentCategory.value.isNotEmpty) {
      deckList = deckList.where((deck) => 
        deck.category?.contentType == currentCategory.value).toList().obs;
    }
    
    // Filter by search query
    if (searchQuery.value.isEmpty) return deckList;
    
    return deckList.where((deck) {
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

  // Fetch all decks
  Future<void> fetchDecks() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Fetching decks for category: ${currentCategory.value}');
      final result = await _apiService.getDecks();
      print('Received ${result.length} decks');
      
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

  // Set category filter
  void setCategory(String category) {
    currentCategory.value = category;
    refresh();
  }

  // Get deck by ID
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

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Refresh
  Future<void> refresh() async {
    await fetchDecks();
  }
}