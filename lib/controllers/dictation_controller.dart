import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/models/dictation_model.dart';
import '../services/api_service.dart';

class DictationController extends GetxController {
  final ApiService _apiService = ApiService.instance;

  // Observables
  final RxList<DictationContent> dictationList = <DictationContent>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedDifficulty = 'All'.obs;
  final RxString selectedSourceType = 'All'.obs;
  final RxString selectedAccent = 'All'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  // Computed - filtered content
  List<DictationContent> get filteredContent {
    return dictationList.where((content) {
      bool matchesSearch = true;
      bool matchesDifficulty = true;
      bool matchesSourceType = true;
      bool matchesAccent = true;

      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        matchesSearch = content.title.toLowerCase().contains(query) ||
            content.description.toLowerCase().contains(query);
      }

      if (selectedDifficulty.value != 'All') {
        matchesDifficulty = content.difficulty == selectedDifficulty.value;
      }

      if (selectedSourceType.value != 'All') {
        matchesSourceType = content.sourceType == selectedSourceType.value;
      }

      if (selectedAccent.value != 'All') {
        matchesAccent = content.accentType == selectedAccent.value;
      }

      return matchesSearch && matchesDifficulty && matchesSourceType && matchesAccent;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDictationContent();
  }

  // Fetch dictation content from API
  Future<void> fetchDictationContent({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        error.value = '';
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }
      if (selectedDifficulty.value != 'All') {
        queryParams['difficulty'] = selectedDifficulty.value;
      }
      if (selectedSourceType.value != 'All') {
        queryParams['sourceType'] = selectedSourceType.value;
      }
      if (selectedAccent.value != 'All') {
        queryParams['accent'] = selectedAccent.value;
      }

      final response = await _apiService.getDictationContent(queryParams);

      if (response.isNotEmpty) {
        final List<DictationContent> newContent = response
            .map((json) {
              print('📋 Raw JSON for content: ${json['title']}');
              print('📋 Segments in JSON: ${json['segments']?.length ?? 0} segments');
              
              final content = DictationContent.fromJson(json);
              
              print('📋 Parsed content - hasSegments: ${content.hasSegments}');
              print('📋 Parsed content - segments count: ${content.segments?.length ?? 0}');
              
              return content;
            })
            .toList();

        if (loadMore) {
          dictationList.addAll(newContent);
        } else {
          dictationList.value = newContent;
        }

        currentPage.value = page;
        // Note: You may need to update API to return pagination info
        // For now, assume there might be more if we got a full page
        totalPages.value = newContent.length == limit ? page + 1 : page;
      }
    } catch (e) {
      print('Error fetching dictation content: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load dictation content',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get single dictation content by ID
  Future<DictationContent?> getDictationById(int id) async {
    try {
      final response = await _apiService.getDictationById(id);
      if (response != null) {
        return DictationContent.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching dictation by ID: $e');
      Get.snackbar(
        'Error',
        'Failed to load dictation content',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Add YouTube video
  Future<bool> addYouTubeVideo({
    required int userId,
    required String sourceURL,
    required String difficulty,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _apiService.addYouTubeVideo(
        userId: userId,
        sourceURL: sourceURL,
        difficulty: difficulty,
      );

      if (response['success'] == true) {
        // Refresh the list
        await fetchDictationContent();
        Get.snackbar(
          'Success',
          response['message'] ?? 'Video added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding YouTube video: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add video',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Submit dictation result
  Future<Map<String, dynamic>?> submitResult({
    required int contentId,
    required int userId,
    required String userTranscript,
    int? timeSpent,
  }) async {
    try {
      final response = await _apiService.submitDictationResult(
        contentId: contentId,
        userId: userId,
        userTranscript: userTranscript,
        timeSpent: timeSpent,
      );

      if (response['success'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('Error submitting result: $e');
      Get.snackbar(
        'Error',
        'Failed to submit result',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update filters
  void updateDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
    fetchDictationContent(); // Refresh with new filter
  }

  void updateSourceType(String sourceType) {
    selectedSourceType.value = sourceType;
    fetchDictationContent(); // Refresh with new filter
  }

  void updateAccent(String accent) {
    selectedAccent.value = accent;
    fetchDictationContent(); // Refresh with new filter
  }

  // Refresh content
  Future<void> refresh() async {
    currentPage.value = 1;
    await fetchDictationContent();
  }

  // Load more content
  Future<void> loadMore() async {
    if (currentPage.value < totalPages.value) {
      await fetchDictationContent(
        page: currentPage.value + 1,
        loadMore: true,
      );
    }
  }
}