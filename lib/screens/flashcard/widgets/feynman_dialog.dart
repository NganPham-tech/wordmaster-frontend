import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/feynman_controller.dart';

class FeynmanDialog extends StatefulWidget {
  final String cardType; 
  final int cardId;
  final String cardTitle;
  final VoidCallback? onSaved;

  const FeynmanDialog({
    Key? key,
    required this.cardType,
    required this.cardId,
    required this.cardTitle,
    this.onSaved,
  }) : super(key: key);

  @override
  State<FeynmanDialog> createState() => _FeynmanDialogState();
}

class _FeynmanDialogState extends State<FeynmanDialog> {
  final TextEditingController _textController = TextEditingController();
  final feynmanController = Get.put(FeynmanController());

  @override
  void initState() {
    super.initState();
    _loadExistingNote();
  }

  Future<void> _loadExistingNote() async {
    await feynmanController.loadNote(
      cardType: widget.cardType,
      cardId: widget.cardId,
    );
    
    // Nếu đã có note cũ, điền vào text field
    if (feynmanController.currentNote.value != null) {
      _textController.text = feynmanController.currentNote.value!.textNote;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_textController.text.trim().isEmpty) {
      Get.snackbar(
        'Lưu ý',
        'Vui lòng nhập giải thích của bạn',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await feynmanController.saveNote(
      cardType: widget.cardType,
      cardId: widget.cardId,
      textNote: _textController.text.trim(),
    );

    if (success) {
      widget.onSaved?.call();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.cardType == 'Flashcard'
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF10B981), const Color(0xFF059669)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Giải thích bằng lời của bạn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.cardTitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instruction
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, 
                              color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hãy giải thích bằng chính lời của bạn để hiểu sâu hơn!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Text field
                    Obx(() => feynmanController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : TextField(
                            controller: _textController,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: widget.cardType == 'Flashcard'
                                  ? 'Ví dụ:\n- Từ này có nghĩa là...\n- Tôi có thể dùng nó trong tình huống...\n- Một câu ví dụ của tôi: ...'
                                  : 'Ví dụ:\n- Ngữ pháp này được dùng khi...\n- Công thức: ...\n- Một câu mà tôi tự nghĩ ra: ...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: widget.cardType == 'Flashcard'
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFF10B981),
                                  width: 2,
                                ),
                              ),
                            ),
                          )),

                    const SizedBox(height: 16),

                    // Tips
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tips_and_updates, 
                                  color: Colors.amber[700], size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Gợi ý:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Giải thích như thể bạn đang dạy người khác\n'
                            '• Dùng ví dụ từ cuộc sống hàng ngày\n'
                            '• Viết bằng ngôn ngữ đơn giản, dễ hiểu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[900],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Bỏ qua'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                          onPressed: feynmanController.isSaving.value
                              ? null
                              : _saveNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.cardType == 'Flashcard'
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: feynmanController.isSaving.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Lưu giải thích',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}