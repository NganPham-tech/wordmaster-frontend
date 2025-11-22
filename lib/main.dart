import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'bindings/flashcard_binding.dart';
import 'screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  // Initialize API service
  Get.put(ApiService.instance);
  
  runApp(const WordMasterApp());
}

class WordMasterApp extends StatelessWidget {
  const WordMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // ← Đổi từ MaterialApp
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