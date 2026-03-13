import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  static FlutterTts? _flutterTts;
  static bool _isInitialized = false;
  static bool _isSpeaking = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    try {
      
      await _flutterTts!.awaitSpeakCompletion(true);

      
      _flutterTts!.setStartHandler(() {
        _isSpeaking = true;
        print('TTS: started speaking');
      });

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
        print('TTS: completed speaking');
      });

      _flutterTts!.setErrorHandler((msg) {
        _isSpeaking = false;
        print('TTS Error Handler: $msg');
      });

      // Small pause to let engine finish binding on some devices/emulators
      await Future.delayed(const Duration(milliseconds: 150));
      // Cấu hình TTS
      await _flutterTts!.setLanguage('en-US'); // Tiếng Anh Mỹ
      await _flutterTts!.setSpeechRate(0.5); // Tốc độ vừa phải
      await _flutterTts!.setVolume(1.0); // Âm lượng tối đa
      await _flutterTts!.setPitch(1.0); // Tông giọng bình thường

      // Cấu hình cho iOS
      if (!kIsWeb) {
        await _flutterTts!.setSharedInstance(true);
        await _flutterTts!.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      }

      _isInitialized = true;
      print('TTS Service initialized successfully');
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  // Phát âm từ/cụm từ
  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null) {
      print('TTS not initialized');
      return;
    }

    try {
    
      if (_isSpeaking) {
        print(
          'TTS: already speaking, stopping previous utterance before starting new one',
        );
        await _flutterTts!.stop();
        
        await Future.delayed(const Duration(milliseconds: 100));
      }

      
      try {
        await _flutterTts!.setLanguage('en-US');
      } catch (_) {}

      print('TTS speaking: $text');
      var result = await _flutterTts!.speak(text);

  
      print('TTS speak result: $result');
    } catch (e) {
      _isSpeaking = false;
      print('Error speaking text: $e');
    }
  }


  static Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
  }

 
  static Future<void> pause() async {
    if (_flutterTts != null) {
      await _flutterTts!.pause();
    }
  }


  static Future<void> setLanguage(String language) async {
    if (_flutterTts != null) {
      await _flutterTts!.setLanguage(language);
    }
  }


  static Future<void> setSpeechRate(double rate) async {
    if (_flutterTts != null) {
      print('TTS: Setting speech rate to $rate');
      await _flutterTts!.setSpeechRate(rate);
      print('TTS: Speech rate set successfully');
    } else {
      print('TTS: Cannot set speech rate - TTS not initialized');
    }
  }


  static Future<void> setVolume(double volume) async {
    if (_flutterTts != null) {
      await _flutterTts!.setVolume(volume);
    }
  }

  // Lấy danh sách ngôn ngữ có sẵn
  static Future<List<dynamic>> getLanguages() async {
    if (_flutterTts != null) {
      return await _flutterTts!.getLanguages;
    }
    return [];
  }

  // Kiểm tra trạng thái
  static bool get isInitialized => _isInitialized;
  static bool get isSpeaking => _isSpeaking;

  // Cleanup
  static void dispose() {
    _flutterTts = null;
    _isInitialized = false;
  }
}
