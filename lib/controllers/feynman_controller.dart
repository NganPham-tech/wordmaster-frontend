import 'package:get/get.dart';
import '../data/models/feynman_note_model.dart';
import '../services/feynman_service.dart';

class FeynmanController extends GetxController {
  final FeynmanService _service = FeynmanService();
  
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<FeynmanNote?> currentNote = Rx<FeynmanNote?>(null);
  final RxString error = ''.obs;

  
  Future<void> loadNote({
    required String cardType,
    required int cardId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final note = await _service.getNote(
        cardType: cardType,
        cardId: cardId,
      );
      
      currentNote.value = note;
    } catch (e) {
      error.value = 'Không thể tải ghi chú: $e';
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> saveNote({
    required String cardType,
    required int cardId,
    required String textNote,
  }) async {
    try {
      isSaving.value = true;
      error.value = '';
      
      final note = await _service.saveNote(
        cardType: cardType,
        cardId: cardId,
        textNote: textNote,
      );
      
      if (note != null) {
        currentNote.value = note;
        Get.snackbar(
          'Thành công',
          'Đã lưu ghi chú của bạn',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        throw Exception('Failed to save note');
      }
    } catch (e) {
      error.value = 'Không thể lưu ghi chú: $e';
      Get.snackbar(
        'Lỗi',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

 
  void clearNote() {
    currentNote.value = null;
  }
}