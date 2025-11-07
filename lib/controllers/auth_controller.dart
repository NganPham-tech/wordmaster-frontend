import 'package:get/get.dart';
import '../data/models/user.dart';

class AuthController extends GetxController {
  final _user = Rx<User?>(null);
  final _isLoading = false.obs;
  final _error = Rx<String?>(null);

  User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  // In-memory storage cho user
  final Map<String, Map<String, dynamic>> _users = {};

  Future<void> login(String email, String password) async {
    _isLoading.value = true;
    _error.value = null;

    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay

    try {
      final userData = _users[email];
      if (userData == null || userData['password'] != password) {
        throw 'Email hoặc mật khẩu không đúng';
      }

      final user = User.fromMap(userData);
      _user.value = user;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register(String email, String fullName, String password) async {
    _isLoading.value = true;
    _error.value = null;

    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay

    try {
      if (_users.containsKey(email)) {
        throw 'Email đã được sử dụng';
      }

      final newUser = User(
        email: email,
        fullName: fullName,
        password: password,
        createdAt: DateTime.now(),
      );

      _users[email] = newUser.toMap();
      _user.value = newUser;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading.value = true;
    _error.value = null;

    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay

    try {
      if (!_users.containsKey(email)) {
        throw 'Email không tồn tại';
      }
      // Trong thực tế, gửi email reset password
      print('Đã gửi email reset password tới: $email');
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  void logout() {
    _user.value = null;
  }

  void clearError() {
    _error.value = null;
  }
}
