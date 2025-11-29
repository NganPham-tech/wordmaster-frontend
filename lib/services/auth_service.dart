// lib/services/auth_service.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AuthService extends GetxController {
  static AuthService get instance => Get.find();
  
  final _storage = GetStorage();
  final _apiService = ApiService.instance;
  
  // Simple initialization (version 6.x)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'], 
);
  
  // Observable state
  final Rx<bool> isLoggedIn = false.obs;
  final Rx<String?> token = Rx<String?>(null);
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);
  final Rx<bool> isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }
  
  void _checkLoginStatus() {
    final savedToken = _storage.read('auth_token');
    final savedUser = _storage.read('current_user');
    
    if (savedToken != null && savedUser != null) {
      token.value = savedToken;
      currentUser.value = Map<String, dynamic>.from(savedUser);
      isLoggedIn.value = true;
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final int? status = response.statusCode;
      final body = response.body;

      if (status != null && status >= 200 && status < 300 && body != null) {
        if (body is Map && body['success'] == true) {
          final authToken = body['token'];
          final user = body['user'];

          await _storage.write('auth_token', authToken);
          await _storage.write('current_user', user);

          token.value = authToken;
          currentUser.value = Map<String, dynamic>.from(user ?? {});
          isLoggedIn.value = true;

          return true;
        }
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Đăng nhập bằng Google (Version 6.x - Simple!)
  Future<bool> loginWithGoogle() async {
    try {
      isLoading.value = true;
      
      // Step 1: Sign in to Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled
        print('Google sign in cancelled');
        return false;
      }

      print('Google user signed in: ${googleUser.email}');

      // Step 2: Get authentication tokens
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        print('Failed to get idToken');
        await _googleSignIn.signOut();
        return false;
      }

      print('Got tokens - idToken: ${idToken.substring(0, 20)}...');
      print('accessToken: ${accessToken?.substring(0, 20) ?? "null"}...');

      // Step 3: Send tokens to backend
      final response = await _apiService.post('/auth/google', {
        'idToken': idToken,
        'accessToken': accessToken ?? '',
      });

      final int? status = response.statusCode;
      final body = response.body;

      print('Backend response: $status - $body');

      if (status != null && status >= 200 && status < 300 && body != null) {
        if (body is Map && body['success'] == true) {
          final authToken = body['token'];
          final user = body['user'];

          await _storage.write('auth_token', authToken);
          await _storage.write('current_user', user);

          token.value = authToken;
          currentUser.value = Map<String, dynamic>.from(user ?? {});
          isLoggedIn.value = true;

          print('Google login successful!');
          return true;
        } else {
          print('Backend error: ${body['message'] ?? 'Unknown error'}');
        }
      } else {
        print('Backend HTTP error: $status');
      }

      // Clean up if backend fails
      await _googleSignIn.signOut();
      return false;

    } catch (e, stackTrace) {
      print('Google login error: $e');
      print('Stack trace: $stackTrace');
      
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Error during cleanup: $e');
      }
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> loginWithFacebook() async {
    try {
      isLoading.value = true;
      
      Get.snackbar(
        'Thông báo',
        'Tính năng đăng nhập Facebook đang được phát triển',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      
      return false;
    } catch (e) {
      print('Facebook login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });

      final int? status = response.statusCode;
      final body = response.body;

      if (status != null && status >= 200 && status < 300 && body != null) {
        if (body is Map && body['success'] == true) {
          return await login(email, password);
        }
      }

      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    isLoading.value = true;
    
    // Sign out from Google
    try {
      final bool isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut();
        print('Signed out from Google');
      }
    } catch (e) {
      print('Google sign out error: $e');
    }
    
    // Clear local storage
    await _storage.remove('auth_token');
    await _storage.remove('current_user');
    
    // Reset state
    token.value = null;
    currentUser.value = null;
    isLoggedIn.value = false;
    
    isLoading.value = false;
  }
  
  // Getters
  String get userName {
    if (currentUser.value != null) {
      final firstName = currentUser.value!['firstName'] ?? '';
      final lastName = currentUser.value!['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return '';
  }
  
  String get userEmail {
    return currentUser.value?['email'] ?? '';
  }
  
  String? get userAvatar {
    return currentUser.value?['avatar'] ?? currentUser.value?['avatarUrl'];
  }
  
  int get userLevel {
    return currentUser.value?['level'] ?? 1;
  }
  
  int get userPoints {
    return currentUser.value?['totalPoints'] ?? 0;
  }
  
  int get userStreak {
    return currentUser.value?['currentStreak'] ?? 0;
  }
  
  int get userId {
    return currentUser.value?['id'] ?? 0;
  }
}