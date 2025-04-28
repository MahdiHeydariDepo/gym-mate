import 'dart:convert'; // for jsonDecode/jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gymmate/login_screen.dart';
import 'package:gymmate/email_verify_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
// <-- You'll need to create this screen if not already

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  //final TextEditingController firstnameController = TextEditingController();
  //final TextEditingController lastnameController = TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool isLoading = false; // NEW: Loading state

 Future<void> _signUp() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    _showSnackBar('Please fill in all fields');
    return;
  }

  if (password != confirmPassword) {
    _showSnackBar('Passwords do not match');
    return;
  }

  setState(() {
    isLoading = true;
  });

  final url = Uri.parse('https://your-backend-url.com/signup'); // your actual backend signup API

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', token);

        // Go to Email Verify Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: email),
          ),
        );
      } else {
        _showSnackBar('Signup successful but no token received.');
      }
    } else {
      final data = jsonDecode(response.body);
      String errorMessage = data['error'] ?? 'Something went wrong.';
      _showSnackBar(errorMessage);
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    _showSnackBar('Network error. Please try again.');
  }
}


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
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

              const SizedBox(height: 150),
              Image.asset('assets/images/signup-logo.png', height: 100),

              const SizedBox(height: 40),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Email Address'),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Enter your email address',
                    icon: Icons.email_outlined,
                  ),
                ],
              ),




              const SizedBox(height: 20),
              
              

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Password'),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                    icon: Icons.password,
                    obscureText: !passwordVisible,
                    toggleVisibility: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    isPassword: true,
                    isVisible: passwordVisible,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Confirm Password'),
                  _buildTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm your password',
                    icon: Icons.password,
                    obscureText: !confirmPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        confirmPasswordVisible = !confirmPasswordVisible;
                      });
                    },
                    isPassword: true,
                    isVisible: confirmPasswordVisible,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Sign Up Button
              isLoading
                ? const CircularProgressIndicator(color: Color.fromARGB(255, 235, 94, 40))
                : ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 94, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                      fixedSize: const Size(274, 55),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  "I Already Have Account",
                  style: TextStyle(color: Color.fromARGB(255, 235, 94, 40)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Label
  Widget _buildTextFieldLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
      ],
    );
  }

  // Helper: Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        prefixIcon: Icon(icon, color: Colors.white),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}
