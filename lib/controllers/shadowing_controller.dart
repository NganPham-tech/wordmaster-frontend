import 'package:get/get.dart';
import '../data/models/shadowing_model.dart';
import '../services/api_service.dart';

class ShadowingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observables
  final RxList<ShadowingContent> shadowingList = <ShadowingContent>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedDifficulty = 'all'.obs;
  final RxString selectedAccent = 'all'.obs;
  final RxString selectedSpeechRate = 'all'.obs;
  final RxString selectedSourceType = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShadowingContent();
  }

  // Fetch shadowing content from API
  Future<void> fetchShadowingContent({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        error.value = '';
      }

      final result = await _apiService.getShadowingContents(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        difficulty: selectedDifficulty.value != 'all'
            ? selectedDifficulty.value
            : null,
        accent: selectedAccent.value != 'all' ? selectedAccent.value : null,
        speechRate: selectedSpeechRate.value != 'all'
            ? selectedSpeechRate.value
            : null,
        sourceType: selectedSourceType.value != 'all'
            ? selectedSourceType.value
            : null,
        page: page,
        limit: limit,
      );

      final List<ShadowingContent> newContent =
          result['contents'] as List<ShadowingContent>;
      final pagination = result['pagination'];

      if (loadMore) {
        shadowingList.addAll(newContent);
      } else {
        shadowingList.value = newContent;
      }

      currentPage.value = pagination['page'];
      totalPages.value = pagination['totalPages'];
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  // Load more content (pagination)
  Future<void> loadMore() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await fetchShadowingContent(page: currentPage.value + 1, loadMore: true);
    }
  }

  // Refresh content
  Future<void> refresh() async {
    currentPage.value = 1;
    await fetchShadowingContent();
  }

  // Apply filters
  void applyFilters({
    String? search,
    String? difficulty,
    String? accent,
    String? speechRate,
    String? sourceType,
  }) {
    if (search != null) searchQuery.value = search;
    if (difficulty != null) selectedDifficulty.value = difficulty;
    if (accent != null) selectedAccent.value = accent;
    if (speechRate != null) selectedSpeechRate.value = speechRate;
    if (sourceType != null) selectedSourceType.value = sourceType;

    currentPage.value = 1;
    fetchShadowingContent();
  }

  // Reset filters
  void resetFilters() {
    searchQuery.value = '';
    selectedDifficulty.value = 'all';
    selectedAccent.value = 'all';
    selectedSpeechRate.value = 'all';
    selectedSourceType.value = 'all';
    currentPage.value = 1;
    fetchShadowingContent();
  }

  // Get content detail by ID
  Future<ShadowingContentDetail?> getContentDetail(int id) async {
    try {
      isLoading.value = true;
      final content = await _apiService.getShadowingContentById(id);
      isLoading.value = false;
      return content;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      Get.snackbar(
        'Lỗi',
        'Không thể tải nội dung: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return null;
    }
  }
}
