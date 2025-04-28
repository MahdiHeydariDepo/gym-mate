import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gymmate/reset_password_screen.dart'; 
import 'package:http/http.dart' as http;

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendResetRequest() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:5000/api/UsersApi/forgot-password'); // 👈 UPDATE to your real endpoint

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        _showSnackBar('Reset code sent to your email!', isSuccess: true);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        String errorMessage = data['message'] ?? 'Failed to send reset code.';
        _showSnackBar(errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Network error. Please try again.');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100),
            const SizedBox(height: 16),
            const Text(
              'Forget Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please enter your email address to reset your password.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                hintText: 'Enter your email address',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 235, 94, 40),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator(color: Color.fromARGB(255, 235, 94, 40))
                : ElevatedButton(
                    onPressed: _sendResetRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 94, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      fixedSize: const Size(274, 55),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
