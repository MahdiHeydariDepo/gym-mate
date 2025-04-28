import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  bool isLoading = false;

  Future<void> _resetPassword() async {
    final code = codeController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:5000/api/UsersApi/reset-password'); // 👈 Update your real endpoint

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "code": code,
          "newPassword": newPassword,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        _showSnackBar('Password reset successful!', isSuccess: true);
        Navigator.pop(context); // go back to login or previous page
      } else {
        final data = jsonDecode(response.body);
        String errorMessage = data['message'] ?? 'Failed to reset password.';
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 20),
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the verification code sent to\n${widget.email}',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Code Input
              _buildTextField(
                controller: codeController,
                hintText: 'Enter verification code',
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 20),

              // New Password Input
              _buildTextField(
                controller: newPasswordController,
                hintText: 'Enter new password',
                prefixIcon: Icons.password_outlined,
                isPassword: true,
                isVisible: newPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    newPasswordVisible = !newPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Confirm Password Input
              _buildTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm new password',
                prefixIcon: Icons.password_outlined,
                isPassword: true,
                isVisible: confirmPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    confirmPasswordVisible = !confirmPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              isLoading
                  ? const CircularProgressIndicator(color: Color.fromARGB(255, 235, 94, 40))
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 235, 94, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fixedSize: const Size(274, 55),
                      ),
                      child: const Text(
                        "Reset Password",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        prefixIcon: Icon(prefixIcon, color: Colors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color.fromARGB(255, 235, 94, 40), width: 2),
        ),
      ),
    );
  }
}
