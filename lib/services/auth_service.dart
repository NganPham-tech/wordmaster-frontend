// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Lấy Firebase UID của user hiện tại
  String? getCurrentUserUID() {
    final user = _auth.currentUser;
    return user?.uid;
  }
  
  // Lấy thông tin đầy đủ của user
  Map<String, dynamic>? getCurrentUserInfo() {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return {
      'firebaseUid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? 'User',
      'photoUrl': user.photoURL ?? 'default-avatar.png',
    };
  }
  
  // Lắng nghe thay đổi auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}