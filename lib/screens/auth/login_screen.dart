// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'register_screen.dart';
// import 'forgot_password_screen.dart';
// import '../../controllers/auth_controller.dart';
// import '../main_scaffold.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;

//   bool _rememberMe = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   final AuthController authController = Get.find<AuthController>();

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     try {
//       await authController.login(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       if (authController.user != null) {
//         Get.offAll(() => const MainScaffold());
//       } else if (authController.error != null) {
//         Get.snackbar(
//           'Lỗi đăng nhập',
//           authController.error!,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withOpacity(0.9),
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Lỗi',
//         'Đã xảy ra lỗi trong quá trình đăng nhập: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withOpacity(0.9),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color(0xFF6366F1).withOpacity(0.1),
//               const Color(0xFF818CF8).withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 40),
//                   // Logo Section
//                   Center(
//                     child: Column(
//                       children: [
//                         Container(
//                           width: 120,
//                           height: 120,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(24),
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.school,
//                             color: Colors.white,
//                             size: 60,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'WordMaster',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF6366F1),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Học tiếng Anh thông minh',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 48),
//                   // Login Form
//                   Card(
//                     elevation: 8,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Đăng nhập',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             // Email Field
//                             TextFormField(
//                               controller: _emailController,
//                               keyboardType: TextInputType.emailAddress,
//                               decoration: InputDecoration(
//                                 labelText: 'Địa chỉ email',
//                                 prefixIcon: const Icon(Icons.email_outlined),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFFd63384),
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Vui lòng nhập email';
//                                 }
//                                 if (!RegExp(
//                                   r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
//                                 ).hasMatch(value)) {
//                                   return 'Email không hợp lệ';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             // Password Field
//                             TextFormField(
//                               controller: _passwordController,
//                               obscureText: !_isPasswordVisible,
//                               decoration: InputDecoration(
//                                 labelText: 'Mật khẩu',
//                                 prefixIcon: const Icon(Icons.lock_outlined),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _isPasswordVisible
//                                         ? Icons.visibility
//                                         : Icons.visibility_off,
//                                   ),
//                                   onPressed: () {
//                                     setState(() {
//                                       _isPasswordVisible = !_isPasswordVisible;
//                                     });
//                                   },
//                                   splashRadius: 20, // nhỏ gọn hơn
//                                   padding: EdgeInsets
//                                       .zero, // loại bỏ padding dư thừa
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFFd63384),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                   horizontal: 12,
//                                 ), // giúp icon không bị tràn
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Vui lòng nhập mật khẩu';
//                                 }
//                                 if (value.length < 6) {
//                                   return 'Mật khẩu phải có ít nhất 6 ký tự';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             // Remember Me & Forgot Password
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Checkbox(
//                                       value: _rememberMe,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _rememberMe = value ?? false;
//                                         });
//                                       },
//                                       activeColor: const Color(0xFF6366F1),
//                                     ),
//                                     const Text('Ghi nhớ đăng nhập'),
//                                   ],
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     Get.to(() => const ForgotPasswordScreen());
//                                   },
//                                   child: const Text(
//                                     'Quên mật khẩu?',
//                                     style: TextStyle(color: Color(0xFF6366F1)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 24),
//                             // Login Button
//                             SizedBox(
//                               width: double.infinity,
//                               height: 50,
//                               child: ElevatedButton(
//                                 onPressed: authController.isLoading
//                                     ? null
//                                     : _login,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF6366F1),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: Obx(
//                                   () => authController.isLoading
//                                       ? const CircularProgressIndicator(
//                                           color: Colors.white,
//                                         )
//                                       : const Text(
//                                           'Đăng nhập',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             // Social Login Divider
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Divider(color: Colors.grey[300]),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                   ),
//                                   child: Text(
//                                     'Hoặc đăng nhập bằng',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Divider(color: Colors.grey[300]),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 24),
//                             // Social Login Buttons
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: OutlinedButton.icon(
//                                     onPressed: () {
//                                       // TODO: Implement Google login
//                                     },
//                                     icon: Icon(
//                                       Icons.g_mobiledata,
//                                       color: Color(0xFF6366F1),
//                                     ),
//                                     label: const Text('Google'),
//                                     style: OutlinedButton.styleFrom(
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 12,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       side: BorderSide(color: Colors.red[600]!),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: OutlinedButton.icon(
//                                     onPressed: () {
//                                       // TODO: Implement Facebook login
//                                     },
//                                     icon: Icon(
//                                       Icons.facebook,
//                                       color: Colors.blue[600],
//                                     ),
//                                     label: const Text('Facebook'),
//                                     style: OutlinedButton.styleFrom(
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 12,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       side: BorderSide(
//                                         color: Colors.blue[600]!,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   // Register Link
//                   Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Chưa có tài khoản? '),
//                         TextButton(
//                           onPressed: () {
//                             Get.to(() => const RegisterScreen());
//                           },
//                           child: const Text(
//                             'Đăng ký ngay',
//                             style: TextStyle(
//                               color: Color(0xFF6366F1),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../controllers/auth_controller.dart';
import '../main_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final AuthController authController = Get.find<AuthController>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (authController.user != null) {
        Get.offAll(() => const MainScaffold());
      } else if (authController.error != null) {
        Get.snackbar(
          'Lỗi đăng nhập',
          authController.error!,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi trong quá trình đăng nhập: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              const Color(0xFF818CF8).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                            ),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'WordMaster',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Học tiếng Anh thông minh',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Login Form
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Địa chỉ email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFd63384),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                if (!RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(value)) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  splashRadius: 20, // nhỏ gọn hơn
                                  padding: const EdgeInsets.all(
                                    8,
                                  ), // tránh padding=0 gây overflow
                                ),
                                // đảm bảo icon có khung tối thiểu để không bị tràn ra ngoài
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFd63384),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                if (value.length < 6) {
                                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF6366F1),
                                    ),
                                    const Text('Ghi nhớ đăng nhập'),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.to(() => const ForgotPasswordScreen());
                                  },
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(color: Color(0xFF6366F1)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Obx(
                                  () => authController.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Social Login Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[300]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'Hoặc đăng nhập bằng',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[300]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Social Login Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // TODO: Implement Google login
                                    },
                                    icon: Icon(
                                      Icons.g_mobiledata,
                                      color: Color(0xFF6366F1),
                                    ),
                                    label: const Text('Google'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: BorderSide(color: Colors.red[600]!),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.facebook,
                                      color: Colors.blue[600],
                                    ),
                                    label: const Text('Facebook'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: BorderSide(
                                        color: Colors.blue[600]!,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Register Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Chưa có tài khoản? '),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const RegisterScreen());
                          },
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
