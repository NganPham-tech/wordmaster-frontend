import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechApi {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  // Khởi tạo TTS
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Cấu hình cơ bản
      await _flutterTts.setLanguage("en-US"); // Tiếng Anh
      await _flutterTts.setSpeechRate(0.5); // Tốc độ nói (0.0 - 1.0)
      await _flutterTts.setVolume(1.0); // Âm lượng (0.0 - 1.0)
      await _flutterTts.setPitch(1.0); // Cao độ giọng nói (0.0 - 2.0)

      _isInitialized = true;
      print("TTS initialized successfully");
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  // Phát âm từ/câu
  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      // Dừng phát âm hiện tại nếu có
      await _flutterTts.stop();

      // Phát âm text mới
      await _flutterTts.speak(text);
      print("Speaking: $text");
    } catch (e) {
      print("Error speaking text: $e");
    }
  }

  // Dừng phát âm
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Error stopping TTS: $e");
    }
  }

  // Tạm dừng phát âm
  static Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print("Error pausing TTS: $e");
    }
  }

  // Thiết lập ngôn ngữ
  static Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
    } catch (e) {
      print("Error setting language: $e");
    }
  }

  // Thiết lập tốc độ nói
  static Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      print("Error setting speech rate: $e");
    }
  }

  // Lấy danh sách ngôn ngữ có sẵn
  static Future<List<String>> getLanguages() async {
    try {
      List<dynamic> languages = await _flutterTts.getLanguages;
      return languages.cast<String>();
    } catch (e) {
      print("Error getting languages: $e");
      return [];
    }
  }

  // Lấy danh sách giọng nói có sẵn
  static Future<List<String>> getVoices() async {
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      return voices.cast<String>();
    } catch (e) {
      print("Error getting voices: $e");
      return [];
    }
  }

  // Kiểm tra trạng thái TTS
  static Future<bool> isPlaying() async {
    try {
      return await _flutterTts.isLanguageAvailable("en-US");
    } catch (e) {
      return false;
    }
  }

  // Cleanup khi không sử dụng
  static void dispose() {
    _flutterTts.stop();
  }
}
