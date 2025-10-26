import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider with ChangeNotifier {
  SharedPreferences? _prefs;

  // TTS Settings
  double _speechRate = AppConstants.defaultSpeechRate;
  double _volume = AppConstants.defaultVolume;
  double _pitch = AppConstants.defaultPitch;
  String _language = 'en-US';

  // Study Settings
  int _studySessionSize = AppConstants.defaultStudySessionSize;
  bool _autoPlay = true;
  bool _showExample = true;
  bool _vibrationEnabled = true;

  // UI Settings
  bool _isDarkMode = false;
  String _fontFamily = 'Inter';
  double _fontSize = 16.0;

  // Getters
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get language => _language;
  int get studySessionSize => _studySessionSize;
  bool get autoPlay => _autoPlay;
  bool get showExample => _showExample;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isDarkMode => _isDarkMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _speechRate =
        _prefs?.getDouble('speechRate') ?? AppConstants.defaultSpeechRate;
    _volume = _prefs?.getDouble('volume') ?? AppConstants.defaultVolume;
    _pitch = _prefs?.getDouble('pitch') ?? AppConstants.defaultPitch;
    _language = _prefs?.getString('language') ?? 'en-US';
    _studySessionSize =
        _prefs?.getInt('studySessionSize') ??
        AppConstants.defaultStudySessionSize;
    _autoPlay = _prefs?.getBool('autoPlay') ?? true;
    _showExample = _prefs?.getBool('showExample') ?? true;
    _vibrationEnabled = _prefs?.getBool('vibrationEnabled') ?? true;
    _isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    _fontFamily = _prefs?.getString('fontFamily') ?? 'Inter';
    _fontSize = _prefs?.getDouble('fontSize') ?? 16.0;
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _prefs?.setDouble('speechRate', rate);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _prefs?.setDouble('volume', volume);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _prefs?.setDouble('pitch', pitch);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await _prefs?.setString('language', language);
    notifyListeners();
  }

  Future<void> setStudySessionSize(int size) async {
    _studySessionSize = size;
    await _prefs?.setInt('studySessionSize', size);
    notifyListeners();
  }

  Future<void> setAutoPlay(bool autoPlay) async {
    _autoPlay = autoPlay;
    await _prefs?.setBool('autoPlay', autoPlay);
    notifyListeners();
  }

  Future<void> setShowExample(bool showExample) async {
    _showExample = showExample;
    await _prefs?.setBool('showExample', showExample);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _prefs?.setBool('vibrationEnabled', enabled);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs?.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  Future<void> setFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    await _prefs?.setString('fontFamily', fontFamily);
    notifyListeners();
  }

  Future<void> setFontSize(double fontSize) async {
    _fontSize = fontSize;
    await _prefs?.setDouble('fontSize', fontSize);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await _prefs?.clear();
    _loadSettings();
  }
}
