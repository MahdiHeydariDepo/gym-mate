import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gymmate/forget_password_screen.dart';
import 'package:gymmate/profile_screen.dart';
import 'package:gymmate/signup_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both username and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:5000/api/UsersApi/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email, // توجه: اگر بک‌اند از username به‌جای email استفاده می‌کند
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'];

        if (token == null || token.isEmpty) {
          _showErrorDialog('Token not found in response.');
          return;
        }

        // ذخیره توکن در SharedPreferences فقط در صورت تیک Remember Me
        if (_rememberMe) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwtToken', token);
        }

        // می‌تونی نام کاربر یا اطلاعات دیگر را هم ذخیره کنی اگر نیاز بود

        // رفتن به صفحه بعدی
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      } else {
        final errorMessage = responseData['message'] ?? 'Login failed. Please try again.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Could not connect to server. Please check your internet connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Error', style: TextStyle(color: Colors.redAccent)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Image.asset('assets/images/logo-login.png', height: 100),
              const SizedBox(height: 40),
              _buildTextField('Email Address', emailController, Icons.email_outlined, false),
              const SizedBox(height: 20),
              _buildTextField('Password', passwordController, Icons.lock_outline, true),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    shape: const CircleBorder(),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 235, 94, 40),
                      width: 2,
                    ),
                    activeColor: const Color.fromARGB(255, 235, 94, 40),
                    checkColor: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  const Text("Remember me", style: TextStyle(color: Colors.white)),
                ],
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const CircularProgressIndicator(color: Color.fromARGB(255, 235, 94, 40))
                  : ElevatedButton(
                onPressed: loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 235, 94, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fixedSize: const Size(274, 55),
                ),
                child: const Text(
                  "Log in",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 235, 94, 40),
                  side: const BorderSide(color: Color.fromARGB(255, 235, 94, 40)),
                  fixedSize: const Size(274, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Create New Account", style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()));
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Color.fromARGB(255, 235, 94, 40)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[900],
            prefixIcon: Icon(icon, color: Colors.white),
            hintText: 'Enter your $label',
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color.fromARGB(255, 235, 94, 40), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
