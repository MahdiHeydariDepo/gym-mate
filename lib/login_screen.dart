import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo-login.png', height: 100),
            
            const SizedBox(height: 40),

            // Email field
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                hintText: 'Enter your email address',
                hintStyle: const TextStyle(color: Colors.white54),

                // Default border
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),

                // Orange border when focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 235, 94, 40), width: 2),
                ),

                // Optional: Orange border when enabled but not focused
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Password field
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
                           decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.password, color: Colors.white),
                hintText: 'Enter your email address',
                hintStyle: const TextStyle(color: Colors.white54),

                // Default border
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),

                // Orange border when focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 235, 94, 40), width: 2),
                ),

                // Optional: Orange border when enabled but not focused
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),

            
            Row(
              children: [
                // Just makes it a bit smaller
                Checkbox(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  shape: CircleBorder(
                  
                  ),
                  side: const BorderSide(
                    color:Color.fromARGB(255, 235, 94, 40),
                    width: 2,
                  ), // Keeps border always
                  // // Black background
                activeColor: Color.fromARGB(255, 235, 94, 40),
                  checkColor: Colors.black, // Orange check
                ),

                const SizedBox(width: 8),
                const Text(
                  "Remember me",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Log in button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 235, 94, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 16,
                ),
                fixedSize: Size(274, 55)
              ),
              child: const Text("Log in", style: TextStyle(fontSize: 18,
              color: Colors.white)),
            ),
            const SizedBox(height: 16),

            // Create New Account button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 235, 94, 40),
                side: const BorderSide(color: Color.fromARGB(255, 235, 94, 40)),
                fixedSize: Size(274, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text(
                "Create New Account",
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Forget password?",
              style: TextStyle(color: Color.fromARGB(255, 235, 94, 40)),
            ),
          ],
        ),
      ),
    );
  }
}
