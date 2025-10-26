import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/simple_firebase_user_provider.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleFirebaseUserProvider>(
      builder: (context, userProvider, child) {
        // Show loading spinner while checking authentication state
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show error if there's an authentication error
        if (userProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi xác thực',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      userProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      userProvider.clearError();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        // If user is logged in, show main app
        if (userProvider.isLoggedIn) {
          return const HomeScreen();
        }

        // If user is not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
