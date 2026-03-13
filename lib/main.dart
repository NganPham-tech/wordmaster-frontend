// lib/main.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart'; 
import 'services/user_service.dart'; 
import 'services/learning_session_service.dart'; 
import 'services/achievement_service.dart'; 
import 'bindings/flashcard_binding.dart';
import 'screens/main_scaffold.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize notification service first
    await NotificationService.instance.initialize();
  } catch (e) {
    print('Failed to initialize notifications: $e');
    // Continue without notifications
  }
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Failed to load .env file: $e');
    // Continue without .env
  }
  
  // Initialize services
  Get.put(ApiService.instance);
  Get.put(AuthService()); 
  Get.put(UserService());
  Get.put(LearningSessionService()); 
  Get.put(AchievementService()); 
  runApp(const WordMasterApp());
}

class WordMasterApp extends StatelessWidget {
  const WordMasterApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WordMaster',
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
      
      // Initial binding
      initialBinding: FlashcardBinding(),
      
      // GetX config
      defaultTransition: Transition.cupertino,
      enableLog: true,
    );
  }
}