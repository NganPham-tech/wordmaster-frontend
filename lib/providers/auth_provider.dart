import 'package:flutter/foundation.dart';
import '../data/models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getter
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // In-memory storage cho user
  final Map<String, Map<String, dynamic>> _users = {};

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay

    try {
      final userData = _users[email];
      if (userData == null || userData['password'] != password) {
        throw 'Email hoặc mật khẩu không đúng';
      }

      _user = User.fromMap(userData);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String fullName, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      _user = newUser;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay

    try {
      if (!_users.containsKey(email)) {
        throw 'Email không tồn tại';
      }
      // Trong thực tế, gửi email reset password
      print('Đã gửi email reset password tới: $email');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
