// lib/config/env_config.dart
import 'package:flutter/foundation.dart';
import 'dart:io';

class EnvConfig {
 
  static const String LAPTOP_IP = '192.168.0.4'; 
  
  /// Backend port
  static const int PORT = 3000;
  
 
  
  static const String ENV_EMULATOR = 'emulator';
  static const String ENV_DEVICE = 'device';
  static const String ENV_PRODUCTION = 'production';

  static String get CURRENT_ENV => isEmulator ? ENV_EMULATOR : ENV_DEVICE; 
  

  static bool get isEmulator {
    if (kIsWeb) return false;
    
    try {
      if (Platform.isAndroid) {
    
        return Platform.environment.containsKey('ANDROID_EMULATOR') ||
               Platform.environment['ANDROID_PRODUCT_MODEL']?.contains('sdk') == true;
      }
    } catch (e) {
      print(' Could not detect emulator: $e');
    }
    
    return false;
  }
  

  
  static String get baseUrl {
    switch (CURRENT_ENV) {
      case ENV_EMULATOR:
        return emulatorUrl;
      
      case ENV_DEVICE:
        return deviceUrl;
      
      case ENV_PRODUCTION:
        return productionUrl;
      
      default:
        return emulatorUrl;
    }
  }
  
  /// URL for Android Emulator
  static String get emulatorUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$PORT/api';
    }
    // iOS Simulator can use localhost
    return 'http://localhost:$PORT/api';
  }
  

  static String get deviceUrl {
    return 'http://$LAPTOP_IP:$PORT/api';
  }
  
  /// URL for Production
  static String get productionUrl {
    return 'https://your-production-api.com/api';
  }
  

  
  /// Get full URL for specific endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Print current configuration (for debugging)
  static void printConfig() {
    print('\n╔════════════════════════════════════════╗');
    print('║      API CONFIGURATION              ║');
    print('╠════════════════════════════════════════╣');
    print('║ Environment: $CURRENT_ENV              ');
    print('║ Base URL: $baseUrl');
    print('║ Laptop IP: $LAPTOP_IP                 ');
    print('║ Port: $PORT                            ');
    print('╚════════════════════════════════════════╝\n');
  }
  
  // ============================================================
  // AUDIO UPLOAD CONFIGURATION
  // ============================================================
  
  /// Max file size for audio uploads (in bytes)
  static const int MAX_AUDIO_SIZE = 50 * 1024 * 1024; // 50MB
  
  /// Request timeout for audio uploads
  static const Duration uploadTimeout = Duration(seconds: 60);
  
  /// Request timeout for regular API calls
  static const Duration defaultTimeout = Duration(seconds: 30);
}

// ============================================================
// QUICK SWITCH HELPER
// ============================================================

/// Quick switch between environments
/// Usage in main.dart:
/// 
/// void main() {
///   EnvConfig.useEmulator();  // or useDevice() or useProduction()
///   runApp(MyApp());
/// }
extension EnvSwitch on EnvConfig {
  static void useEmulator() {
    print(' Switched to EMULATOR mode');
  }
  
  static void useDevice() {
    print(' Switched to DEVICE mode');
  }
  
  static void useProduction() {
    print(' Switched to PRODUCTION mode');
  }
}